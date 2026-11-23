package dev.basalt.apppulse

import android.content.Context
import org.json.JSONObject
import java.util.Calendar

/**
 * Downtime: a daily time window (it may cross midnight) and a list of apps. Opening one of those apps
 * inside the window gets a gentle notification, at most once per app per 10 minutes. Nothing is blocked.
 */
object Downtime {
    private const val REPEAT_MS = 10 * 60_000L

    class Config(val enabled: Boolean, val start: Int, val end: Int, val apps: Map<String, String>) {
        val active get() = enabled && apps.isNotEmpty() && start != end
    }

    private fun prefs(ctx: Context) = ctx.getSharedPreferences("clocked_downtime", Context.MODE_PRIVATE)

    fun save(ctx: Context, json: String) = prefs(ctx).edit().putString("config", json).apply()

    fun config(ctx: Context): Config {
        return try {
            val o = JSONObject(prefs(ctx).getString("config", "{}") ?: "{}")
            val apps = LinkedHashMap<String, String>()
            val arr = o.optJSONArray("apps")
            if (arr != null) {
                for (i in 0 until arr.length()) {
                    val a = arr.optJSONObject(i) ?: continue
                    val pkg = a.optString("package")
                    if (pkg.isNotEmpty()) apps[pkg] = a.optString("name", pkg)
                }
            }
            Config(o.optBoolean("enabled", false), o.optInt("start", 23 * 60), o.optInt("end", 7 * 60), apps)
        } catch (_: Exception) {
            Config(false, 0, 0, emptyMap())
        }
    }

    fun minuteOfDay(now: Long): Int {
        val c = Calendar.getInstance()
        c.timeInMillis = now
        return c.get(Calendar.HOUR_OF_DAY) * 60 + c.get(Calendar.MINUTE)
    }

    /** True when [minute] (0–1439) is inside [start, end), wrapping past midnight when end < start. */
    fun inWindow(minute: Int, start: Int, end: Int): Boolean = when {
        start == end -> false
        start < end -> minute in start until end
        else -> minute >= start || minute < end
    }

    private fun hhmm(m: Int) = "%02d:%02d".format(m / 60, m % 60)

    /**
     * Notifies when [foreground] is a downtime app opened inside the window. Returns the delay until the
     * next useful check (null when none is needed soon).
     */
    fun check(ctx: Context, now: Long, foreground: String?): Long? {
        val c = config(ctx)
        if (!c.active) return null
        if (!inWindow(minuteOfDay(now), c.start, c.end)) return null
        val pkg = foreground ?: return null
        val name = c.apps[pkg] ?: return null
        val p = prefs(ctx)
        val last = p.getLong("told_$pkg", 0L)
        if (now - last >= REPEAT_MS) {
            p.edit().putLong("told_$pkg", now).apply()
            Notifier.post(
                ctx,
                3000 + (pkg.hashCode() and 0xffff),
                Notifier.builder(
                    ctx,
                    Notifier.DOWNTIME,
                    "It's downtime",
                    "You set ${hhmm(c.start)}–${hhmm(c.end)} as downtime for $name. Nothing is blocked; this is just a nudge.",
                ),
            )
            return REPEAT_MS
        }
        return (REPEAT_MS - (now - last)).coerceAtLeast(30_000L)
    }
}
