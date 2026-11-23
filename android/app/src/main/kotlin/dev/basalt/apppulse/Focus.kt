package dev.basalt.apppulse

import android.content.ComponentName
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.service.quicksettings.TileService
import androidx.core.app.NotificationCompat
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import org.json.JSONArray
import org.json.JSONObject
import java.text.DateFormat
import java.util.Date
import java.util.concurrent.TimeUnit

/**
 * The running focus session, shared by the app, the Quick Settings tile and the end-of-session worker.
 *
 * The app's database keeps the history. Sessions started or ended outside the app (tile, timer) are
 * queued in [pending] until the app imports them, so nothing is lost while the app is closed.
 */
object Focus {
    private const val WORK = "apppulse-focus-end"
    const val TILE_MINUTES = 25

    /** Called on the main thread whenever a session starts or stops (MainActivity forwards it to Dart). */
    @Volatile
    var listener: (() -> Unit)? = null

    private fun prefs(ctx: Context) = ctx.getSharedPreferences("clocked_focus", Context.MODE_PRIVATE)

    class Active(val start: Long, val end: Long, val minutes: Int)

    fun active(ctx: Context): Active? {
        val p = prefs(ctx)
        if (!p.getBoolean("active", false)) return null
        return Active(p.getLong("start", 0L), p.getLong("end", 0L), p.getInt("minutes", 0))
    }

    /** Starts a session (from the app or the tile) and shows its countdown notification. */
    @Synchronized
    fun start(ctx: Context, startAt: Long, endAt: Long, minutes: Int) {
        prefs(ctx).edit()
            .putBoolean("active", true)
            .putLong("start", startAt)
            .putLong("end", endAt)
            .putInt("minutes", minutes)
            .apply()
        val until = DateFormat.getTimeInstance(DateFormat.SHORT).format(Date(endAt))
        val ongoing = Notifier.builder(ctx, Notifier.FOCUS_ONGOING, "Focus session", "$minutes min, until $until")
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setWhen(endAt)
            .setShowWhen(true)
            .setUsesChronometer(true)
            .setChronometerCountDown(true)
        Notifier.cancel(ctx, Notifier.FOCUS_DONE_ID)
        Notifier.post(ctx, Notifier.FOCUS_ONGOING_ID, ongoing)
        val delay = (endAt - System.currentTimeMillis()).coerceAtLeast(0L)
        val request = OneTimeWorkRequest.Builder(FocusEndWorker::class.java)
            .setInitialDelay(delay, TimeUnit.MILLISECONDS)
            .build()
        WorkManager.getInstance(ctx).enqueueUniqueWork(WORK, ExistingWorkPolicy.REPLACE, request)
        changed(ctx)
    }

    /** Tile tap with no session running: a [TILE_MINUTES]-minute session from now. */
    fun startFromTile(ctx: Context) {
        val now = System.currentTimeMillis()
        start(ctx, now, now + TILE_MINUTES * 60_000L, TILE_MINUTES)
    }

    /**
     * Ends the running session. When the app ended it ([fromApp]) its database already has the result;
     * otherwise the result is queued for the app to import.
     */
    @Synchronized
    fun stop(ctx: Context, at: Long = System.currentTimeMillis(), fromApp: Boolean, completed: Boolean = false) {
        val current = active(ctx)
        val edit = prefs(ctx).edit().putBoolean("active", false)
        if (current != null && !fromApp) {
            val queue = pendingArray(ctx)
            queue.put(
                JSONObject()
                    .put("start", current.start)
                    .put("plannedEnd", current.end)
                    .put("end", if (completed) current.end else minOf(at, current.end))
                    .put("status", if (completed) "completed" else "stopped"),
            )
            edit.putString("pending", queue.toString())
        }
        edit.apply()
        Notifier.cancel(ctx, Notifier.FOCUS_ONGOING_ID)
        WorkManager.getInstance(ctx).cancelUniqueWork(WORK)
        changed(ctx)
    }

    private fun pendingArray(ctx: Context): JSONArray =
        try {
            JSONArray(prefs(ctx).getString("pending", "[]") ?: "[]")
        } catch (_: Exception) {
            JSONArray()
        }

    /** Active session and queued results, as a map for the method channel. */
    fun state(ctx: Context): Map<String, Any?> {
        val a = active(ctx)
        val queue = pendingArray(ctx)
        val pending = (0 until queue.length()).mapNotNull { i ->
            val o = queue.optJSONObject(i) ?: return@mapNotNull null
            mapOf(
                "start" to o.optLong("start"),
                "plannedEnd" to o.optLong("plannedEnd"),
                "end" to o.optLong("end"),
                "status" to o.optString("status", "stopped"),
            )
        }
        return mapOf(
            "active" to (a?.let { mapOf("start" to it.start, "end" to it.end, "minutes" to it.minutes) }),
            "pending" to pending,
        )
    }

    /** Removes queued results the app has imported (matched by start time). */
    @Synchronized
    fun ack(ctx: Context, starts: List<Long>) {
        val queue = pendingArray(ctx)
        val keep = JSONArray()
        for (i in 0 until queue.length()) {
            val o = queue.optJSONObject(i) ?: continue
            if (o.optLong("start") !in starts) keep.put(o)
        }
        prefs(ctx).edit().putString("pending", keep.toString()).apply()
    }

    private fun changed(ctx: Context) {
        val app = ctx.applicationContext
        try {
            TileService.requestListeningState(app, ComponentName(app, FocusTileService::class.java))
        } catch (_: Exception) {
        }
        Handler(Looper.getMainLooper()).post { listener?.invoke() }
    }
}

class FocusEndWorker(ctx: Context, params: WorkerParameters) : Worker(ctx, params) {
    override fun doWork(): Result {
        val ctx = applicationContext
        Notifier.post(
            ctx,
            Notifier.FOCUS_DONE_ID,
            Notifier.builder(ctx, Notifier.FOCUS, "Focus session complete", "Nice work. Open Clocked to see how it went."),
        )
        val active = Focus.active(ctx)
        if (active != null) {
            // Cancels this worker's unique work too, which is harmless: the work is already done.
            Focus.stop(ctx, active.end, fromApp = false, completed = true)
        } else {
            Notifier.cancel(ctx, Notifier.FOCUS_ONGOING_ID)
        }
        return Result.success()
    }
}
