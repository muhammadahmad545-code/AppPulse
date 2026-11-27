package dev.basalt.apppulse

import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.PeriodicWorkRequest
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import org.json.JSONArray
import java.util.concurrent.TimeUnit

data class AppLimit(val pkg: String, val name: String, val minutes: Int)

/** Enabled limits mirrored from the Dart database, plus per-day "already told you" markers. */
object LimitStore {
    private fun prefs(ctx: Context) = ctx.getSharedPreferences("apppulse_limits", Context.MODE_PRIVATE)

    fun save(ctx: Context, json: String, overlay: Boolean) {
        prefs(ctx).edit().putString("limits", json).putBoolean("overlay", overlay).apply()
    }

    fun limits(ctx: Context): List<AppLimit> {
        val raw = prefs(ctx).getString("limits", "[]") ?: "[]"
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).map { i ->
                val o = arr.getJSONObject(i)
                AppLimit(o.getString("package"), o.optString("name", o.getString("package")), o.getInt("minutes"))
            }.filter { it.minutes > 0 }
        } catch (_: Exception) {
            emptyList()
        }
    }

    fun overlay(ctx: Context) = prefs(ctx).getBoolean("overlay", false)

    fun marked(ctx: Context, key: String, day: String) = prefs(ctx).getString(key, null) == day

    fun mark(ctx: Context, key: String, day: String) = prefs(ctx).edit().putString(key, day).apply()

    fun front(ctx: Context): String? = prefs(ctx).getString("front", null)

    fun setFront(ctx: Context, pkg: String?) {
        if (front(ctx) != pkg) prefs(ctx).edit().putString("front", pkg).apply()
    }

    fun lastOverlay(ctx: Context, pkg: String) = prefs(ctx).getLong("overlay_at_$pkg", 0L)

    fun setLastOverlay(ctx: Context, pkg: String, at: Long) = prefs(ctx).edit().putLong("overlay_at_$pkg", at).apply()
}

object LimitScheduler {
    private const val PERIODIC = "apppulse-limits"
    const val FOLLOW_UP = "apppulse-limit-followup"

    /**
     * A 15-minute check while any limit, a downtime schedule or the home-screen widget exists;
     * nothing runs in the background otherwise.
     */
    fun schedule(ctx: Context) {
        LimitGuard.sync(ctx)
        val wm = WorkManager.getInstance(ctx)
        val needed = LimitStore.limits(ctx).isNotEmpty() || Downtime.config(ctx).active || UsageWidget.installed(ctx)
        if (!needed) {
            wm.cancelUniqueWork(PERIODIC)
            wm.cancelUniqueWork(FOLLOW_UP)
            return
        }
        val request = PeriodicWorkRequest.Builder(LimitWorker::class.java, 15, TimeUnit.MINUTES).build()
        wm.enqueueUniquePeriodicWork(PERIODIC, ExistingPeriodicWorkPolicy.KEEP, request)
    }

    /** One extra check timed for when the app in front will cross a threshold. */
    fun followUp(ctx: Context, delayMs: Long) {
        val request = OneTimeWorkRequest.Builder(LimitWorker::class.java)
            .setInitialDelay(delayMs.coerceAtLeast(5_000L), TimeUnit.MILLISECONDS)
            .build()
        WorkManager.getInstance(ctx).enqueueUniqueWork(FOLLOW_UP, ExistingWorkPolicy.REPLACE, request)
    }
}

class LimitWorker(ctx: Context, params: WorkerParameters) : Worker(ctx, params) {
    override fun doWork(): Result {
        try {
            LimitChecker.run(applicationContext)
            // Restart the on-time watcher if Android stopped it (allowed only in some states; best effort).
            LimitGuard.sync(applicationContext)
        } catch (_: Exception) {
        }
        return Result.success()
    }
}

object LimitChecker {
    private const val WARN_BEFORE = 5 * 60_000L
    private const val OVERLAY_REPEAT = 10 * 60_000L

    private fun fmt(ms: Long): String {
        val m = ms / 60_000L
        return if (m >= 60) {
            if (m % 60 == 0L) "${m / 60}h" else "${m / 60}h ${m % 60}m"
        } else {
            "${maxOf(m, 1L)}m"
        }
    }

    /**
     * Limits, downtime and the widget share one pass over today's usage. The app passes
     * [refreshWidget] = false because it pushes its own numbers to the widget after a sync.
     * Returns the delay until the next check that matters (a threshold of the app in front, or the next
     * downtime nudge), or null. With [scheduleFollowUp] it also books that check with WorkManager; the
     * [LimitGuard] service books its own, exact one instead.
     */
    @Synchronized
    fun run(ctx: Context, refreshWidget: Boolean = true, scheduleFollowUp: Boolean = true): Long? {
        val limits = LimitStore.limits(ctx)
        val downtime = Downtime.config(ctx).active
        if (!Usage.hasAccess(ctx) || (limits.isEmpty() && !downtime)) {
            if (refreshWidget) safely { UsageWidget.refreshNative(ctx) }
            return null
        }
        val now = System.currentTimeMillis()
        val day = Usage.dayKey(now)
        val today = Usage.today(ctx, now)
        val front = today.foreground
        // The app that just came to the front gets the card again even if it was dismissed a minute ago.
        val cameToFront = front != null && LimitStore.front(ctx) != front
        LimitStore.setFront(ctx, front)
        var next = Long.MAX_VALUE
        for (l in limits) {
            val used = today.totals[l.pkg] ?: 0L
            val limitMs = l.minutes * 60_000L
            val remaining = limitMs - used
            val inFront = front == l.pkg
            val notifyId = 1000 + (l.pkg.hashCode() and 0xffff)
            // Markers carry the limit, so raising or lowering a limit today notifies again at the new one.
            val mark = "$day:${l.minutes}"
            if (remaining <= 0) {
                if (!LimitStore.marked(ctx, "reached_${l.pkg}", mark)) {
                    LimitStore.mark(ctx, "reached_${l.pkg}", mark)
                    Notifier.post(
                        ctx,
                        notifyId,
                        Notifier.builder(ctx, Notifier.LIMITS, "${l.name}: daily limit reached", "You've used ${l.name} for ${fmt(used)} today. Your limit is ${fmt(limitMs)}.")
                            .setPriority(NotificationCompat.PRIORITY_HIGH)
                            .setCategory(NotificationCompat.CATEGORY_REMINDER),
                    )
                }
                if (inFront && LimitStore.overlay(ctx)) {
                    val since = now - LimitStore.lastOverlay(ctx, l.pkg)
                    if (cameToFront || since >= OVERLAY_REPEAT) {
                        LimitStore.setLastOverlay(ctx, l.pkg, now)
                        Overlay.show(ctx, "Time's up for ${l.name}", "You've used it for ${fmt(used)} today. Your limit is ${fmt(limitMs)}.")
                        next = minOf(next, OVERLAY_REPEAT)
                    } else {
                        next = minOf(next, OVERLAY_REPEAT - since)
                    }
                }
                continue
            }
            val canWarn = limitMs >= 2 * WARN_BEFORE && !LimitStore.marked(ctx, "warned_${l.pkg}", mark)
            if (canWarn && remaining <= WARN_BEFORE) {
                LimitStore.mark(ctx, "warned_${l.pkg}", mark)
                Notifier.post(
                    ctx,
                    notifyId,
                    Notifier.builder(ctx, Notifier.LIMITS, "${l.name}: ${fmt(remaining)} left", "You're close to your ${fmt(limitMs)} daily limit."),
                )
            }
            if (inFront) {
                val untilWarn = remaining - WARN_BEFORE
                val wait = if (canWarn && untilWarn > 0) untilWarn else remaining
                next = minOf(next, wait)
            }
        }
        Downtime.check(ctx, now, front)?.let { next = minOf(next, it) }
        // A new day resets every limit: check right after midnight.
        next = minOf(next, Usage.startOfDay(now) + 24 * 3_600_000L + 1_000L - now)
        if (refreshWidget) safely { UsageWidget.refreshNative(ctx) }
        if (scheduleFollowUp && next != Long.MAX_VALUE) LimitScheduler.followUp(ctx, next + 2_000L)
        return next
    }

    private inline fun safely(block: () -> Unit) {
        try {
            block()
        } catch (_: Exception) {
        }
    }
}

/** Optional reminder card drawn over the app that reached its limit (needs "Display over other apps"). */
object Overlay {
    fun show(ctx: Context, title: String, body: String) {
        if (!Settings.canDrawOverlays(ctx)) return
        val app = ctx.applicationContext
        Handler(Looper.getMainLooper()).post {
            try {
                val wm = app.getSystemService(Context.WINDOW_SERVICE) as WindowManager
                val d = app.resources.displayMetrics.density
                fun dp(v: Int) = (v * d).toInt()
                val root = FrameLayout(app).apply { setPadding(dp(16), dp(16), dp(16), dp(24)) }
                val card = LinearLayout(app).apply {
                    orientation = LinearLayout.VERTICAL
                    setPadding(dp(20), dp(18), dp(20), dp(10))
                    background = GradientDrawable().apply {
                        setColor(0xFF16181D.toInt())
                        setStroke(dp(1), 0xFF2A2D34.toInt())
                        cornerRadius = 16f * d
                    }
                }
                card.addView(TextView(app).apply {
                    text = title
                    setTextColor(0xFFF3F4F6.toInt())
                    setTypeface(typeface, Typeface.BOLD)
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
                })
                card.addView(TextView(app).apply {
                    text = body
                    setTextColor(0xFFB4B8C0.toInt())
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
                    setPadding(0, dp(6), 0, dp(8))
                })
                val row = LinearLayout(app).apply {
                    orientation = LinearLayout.HORIZONTAL
                    gravity = Gravity.END
                }
                fun action(label: String, color: Int, onClick: () -> Unit) = TextView(app).apply {
                    text = label
                    setTextColor(color)
                    setTypeface(typeface, Typeface.BOLD)
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
                    setPadding(dp(14), dp(12), dp(14), dp(12))
                    setOnClickListener { onClick() }
                }
                root.addView(card)
                val params = WindowManager.LayoutParams(
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                    PixelFormat.TRANSLUCENT,
                ).apply {
                    gravity = Gravity.BOTTOM
                    setTitle("ClockedLimitCard")
                }
                var removed = false
                fun remove(v: View) {
                    if (removed) return
                    removed = true
                    try {
                        wm.removeView(v)
                    } catch (_: Exception) {
                    }
                }
                row.addView(action("Dismiss", 0xFFB4B8C0.toInt()) { remove(root) })
                row.addView(action("Go to home screen", 0xFF38BDF8.toInt()) {
                    remove(root)
                    try {
                        app.startActivity(Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    } catch (_: Exception) {
                    }
                })
                card.addView(row)
                wm.addView(root, params)
                Handler(Looper.getMainLooper()).postDelayed({ remove(root) }, 20_000L)
            } catch (_: Exception) {
            }
        }
    }
}
