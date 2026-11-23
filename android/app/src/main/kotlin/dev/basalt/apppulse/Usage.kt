package dev.basalt.apppulse

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Build
import android.os.Process
import java.util.Calendar

/** Reads UsageStatsManager. Every call returns empty data when usage access is not granted. */
object Usage {
    // UsageEvents.Event types (numeric so older API levels compile the same way).
    const val RESUMED = 1
    const val PAUSED = 2
    const val SCREEN_OFF = 15
    const val SCREEN_ON = 16
    const val KEYGUARD_SHOWN = 17
    const val KEYGUARD_HIDDEN = 18
    const val SHUTDOWN = 26
    const val STARTUP = 27
    private val WANTED = setOf(RESUMED, PAUSED, SCREEN_OFF, SCREEN_ON, KEYGUARD_SHOWN, KEYGUARD_HIDDEN, SHUTDOWN, STARTUP)

    fun hasAccess(ctx: Context): Boolean {
        val ops = ctx.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ops.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), ctx.packageName)
        } else {
            @Suppress("DEPRECATION")
            ops.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), ctx.packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun manager(ctx: Context) = ctx.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

    /**
     * Events between [start] and [end], packed into parallel arrays so thousands of events cross the
     * method channel cheaply: packages/classes are string tables and pkg/cls index into them.
     */
    fun packedEvents(ctx: Context, start: Long, end: Long): Map<String, Any> {
        val packages = ArrayList<String>()
        val classes = ArrayList<String>()
        val pkgIndex = HashMap<String, Int>()
        val clsIndex = HashMap<String, Int>()
        val ts = ArrayList<Long>()
        val types = ArrayList<Int>()
        val pkg = ArrayList<Int>()
        val cls = ArrayList<Int>()
        if (hasAccess(ctx)) {
            val events = manager(ctx).queryEvents(start, end)
            val e = UsageEvents.Event()
            while (events.hasNextEvent()) {
                events.getNextEvent(e)
                val type = e.eventType
                if (type !in WANTED) continue
                val p = e.packageName ?: ""
                val c = e.className ?: ""
                pkg.add(pkgIndex.getOrPut(p) { packages.add(p); packages.size - 1 })
                cls.add(clsIndex.getOrPut(c) { classes.add(c); classes.size - 1 })
                ts.add(e.timeStamp)
                types.add(type)
            }
        }
        return mapOf(
            "packages" to packages,
            "classes" to classes,
            "ts" to ts.toLongArray(),
            "types" to types.toIntArray(),
            "pkg" to pkg.toIntArray(),
            "cls" to cls.toIntArray(),
        )
    }

    /** Android's own per-app foreground totals (what Digital Wellbeing is based on), for the accuracy check. */
    fun androidTotals(ctx: Context, start: Long, end: Long): Map<String, Long> {
        if (!hasAccess(ctx)) return emptyMap()
        val out = HashMap<String, Long>()
        for ((p, stats) in manager(ctx).queryAndAggregateUsageStats(start, end)) {
            if (stats.totalTimeInForeground > 0) out[p] = stats.totalTimeInForeground
        }
        return out
    }

    fun startOfDay(now: Long): Long {
        val c = Calendar.getInstance()
        c.timeInMillis = now
        c.set(Calendar.HOUR_OF_DAY, 0)
        c.set(Calendar.MINUTE, 0)
        c.set(Calendar.SECOND, 0)
        c.set(Calendar.MILLISECOND, 0)
        return c.timeInMillis
    }

    fun dayKey(now: Long): String {
        val c = Calendar.getInstance()
        c.timeInMillis = now
        return "%04d-%02d-%02d".format(c.get(Calendar.YEAR), c.get(Calendar.MONTH) + 1, c.get(Calendar.DAY_OF_MONTH))
    }

    class Today(val totals: Map<String, Long>, val foreground: String?)

    /** Today's foreground time per package and the app in front now. */
    fun today(ctx: Context, now: Long = System.currentTimeMillis()): Today = between(ctx, startOfDay(now), now)

    /**
     * Foreground time per package in [from, to), using the same rules as the Dart reconstruction
     * (one foreground app at a time; screen off, lock and shutdown end the current session).
     * [Today.foreground] is the app still open at [to].
     */
    fun between(ctx: Context, from: Long, to: Long): Today {
        if (!hasAccess(ctx) || to <= from) return Today(emptyMap(), null)
        val events = manager(ctx).queryEvents(from - 3 * 3_600_000L, to)
        val e = UsageEvents.Event()
        val totals = HashMap<String, Long>()
        var open: String? = null
        var since = 0L
        val activities = HashSet<String>()
        fun close(at: Long) {
            val p = open ?: return
            val s = maxOf(since, from)
            val end = minOf(at, to)
            if (end > s) totals[p] = (totals[p] ?: 0L) + (end - s)
            open = null
            activities.clear()
        }
        while (events.hasNextEvent()) {
            events.getNextEvent(e)
            if (e.timeStamp > to) break
            val p = e.packageName ?: continue
            val c = e.className ?: ""
            when (e.eventType) {
                RESUMED -> {
                    if (open != p) {
                        close(e.timeStamp)
                        open = p
                        since = e.timeStamp
                    }
                    activities.add(c)
                }
                PAUSED -> if (open == p) {
                    val known = activities.remove(c)
                    if (!known || activities.isEmpty()) close(e.timeStamp)
                }
                SCREEN_OFF, KEYGUARD_SHOWN, SHUTDOWN -> close(e.timeStamp)
            }
        }
        val foreground = open
        close(to)
        return Today(totals, foreground)
    }

    /** [between] without the home screen, System UI and Clocked, like the app's own numbers. */
    fun appTotals(ctx: Context, from: Long, to: Long): Map<String, Long> {
        val excluded = Apps.excludedPackages(ctx).toSet()
        return between(ctx, from, to).totals.filterKeys { it !in excluded && it.isNotEmpty() }
    }

    fun label(ctx: Context, pkg: String): String = try {
        val pm = ctx.packageManager
        pm.getApplicationLabel(pm.getApplicationInfo(pkg, 0)).toString().ifBlank { pkg }
    } catch (_: Exception) {
        pkg.substringAfterLast('.').replaceFirstChar { it.uppercase() }
    }

    /** Compact duration like the app: `2h 5m`, `45m`, `0m`. */
    fun fmt(ms: Long): String {
        val m = ms / 60_000L
        if (m <= 0) return "0m"
        return if (m >= 60) (if (m % 60 == 0L) "${m / 60}h" else "${m / 60}h ${m % 60}m") else "${m}m"
    }

    /** "12% more than yesterday", or null when there is too little to compare with (same rule as the app). */
    fun change(now: Long, before: Long, against: String): String? {
        if (before < 60_000L) return null
        val pct = Math.round((now - before).toDouble() / before * 100).toInt()
        return when {
            pct == 0 -> "Same as $against"
            pct > 0 -> "$pct% more than $against"
            else -> "${-pct}% less than $against"
        }
    }
}
