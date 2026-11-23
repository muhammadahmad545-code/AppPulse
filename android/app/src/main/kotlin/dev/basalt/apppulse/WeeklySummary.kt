package dev.basalt.apppulse

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import org.json.JSONObject
import java.util.Calendar

/**
 * Optional Monday-morning notification with last week's total, the daily average, the change from the
 * week before and the top app. Scheduled with AlarmManager so it fires with the app closed; rescheduled
 * after each run, after a reboot and after an app update.
 */
object WeeklySummary {
    private const val HOUR = 9
    private const val NOTIFY_ID = 4001

    private fun prefs(ctx: Context) = ctx.getSharedPreferences("clocked_weekly", Context.MODE_PRIVATE)

    fun enabled(ctx: Context) = prefs(ctx).getBoolean("enabled", true)

    /** Stores the setting and weekly totals from the app's history (Monday key -> ms), then (re)schedules. */
    fun configure(ctx: Context, enabled: Boolean, weeksJson: String?) {
        val edit = prefs(ctx).edit().putBoolean("enabled", enabled)
        if (weeksJson != null) edit.putString("weeks", weeksJson)
        edit.apply()
        schedule(ctx)
    }

    private fun intent(ctx: Context): PendingIntent =
        PendingIntent.getBroadcast(
            ctx,
            71,
            Intent(ctx, WeeklySummaryReceiver::class.java).setAction(ACTION),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

    const val ACTION = "dev.basalt.apppulse.WEEKLY_SUMMARY"

    /** Next Monday at 09:00 local time (today if it is Monday before 09:00). */
    fun nextRun(now: Long): Long {
        val c = Calendar.getInstance()
        c.timeInMillis = now
        c.set(Calendar.HOUR_OF_DAY, HOUR)
        c.set(Calendar.MINUTE, 0)
        c.set(Calendar.SECOND, 0)
        c.set(Calendar.MILLISECOND, 0)
        while (c.get(Calendar.DAY_OF_WEEK) != Calendar.MONDAY || c.timeInMillis <= now) {
            c.add(Calendar.DAY_OF_MONTH, 1)
        }
        return c.timeInMillis
    }

    fun schedule(ctx: Context) {
        val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi = intent(ctx)
        am.cancel(pi)
        if (!enabled(ctx)) return
        // Inexact but Doze-friendly; a few minutes late on a Monday morning is fine.
        am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, nextRun(System.currentTimeMillis()), pi)
    }

    /** Monday 00:00 of the week containing [t]. */
    private fun weekStart(t: Long): Long {
        val c = Calendar.getInstance()
        c.timeInMillis = Usage.startOfDay(t)
        while (c.get(Calendar.DAY_OF_WEEK) != Calendar.MONDAY) c.add(Calendar.DAY_OF_MONTH, -1)
        return c.timeInMillis
    }

    private fun addDays(t: Long, days: Int): Long {
        val c = Calendar.getInstance()
        c.timeInMillis = t
        c.add(Calendar.DAY_OF_MONTH, days)
        return c.timeInMillis
    }

    class Summary(val title: String, val text: String)

    /** Builds the summary of the last complete Monday–Sunday week, or null when there is nothing to say. */
    fun build(ctx: Context, now: Long = System.currentTimeMillis()): Summary? {
        if (!Usage.hasAccess(ctx)) return null
        val thisWeek = weekStart(now)
        val lastWeek = addDays(thisWeek, -7)
        val beforeKey = Usage.dayKey(addDays(lastWeek, -7))
        val perApp = HashMap<String, Long>()
        var total = 0L
        var daysWithData = 0
        var day = lastWeek
        while (day < thisWeek) {
            val next = addDays(day, 1)
            val totals = Usage.appTotals(ctx, day, next)
            val sum = totals.values.sum()
            if (sum > 0) daysWithData++
            total += sum
            for ((p, ms) in totals) perApp[p] = (perApp[p] ?: 0L) + ms
            day = next
        }
        if (total < 60_000L) return null
        val p = prefs(ctx)
        p.edit().putLong("native_${Usage.dayKey(lastWeek)}", total).apply()
        val weeks = runCatching { JSONObject(p.getString("weeks", "{}") ?: "{}") }.getOrDefault(JSONObject())
        val before = p.getLong("native_$beforeKey", 0L).takeIf { it > 0 } ?: weeks.optLong(beforeKey, 0L)
        // Android keeps about a week of records; average over the days it still has.
        val average = total / maxOf(1, if (daysWithData < 7) daysWithData else 7)
        val change = Usage.change(total, before, "the week before")
        val top = perApp.maxByOrNull { it.value }
        val text = buildString {
            append("Daily average ${Usage.fmt(average)}.")
            if (change != null) append(" ${change.replaceFirstChar { it.uppercase() }}.")
            if (top != null) append(" Most used: ${Usage.label(ctx, top.key)} (${Usage.fmt(top.value)}).")
        }
        return Summary("Last week: ${Usage.fmt(total)} of screen time", text)
    }

    /** Posts the summary now (the scheduled run and the "Send a preview" button in Settings). */
    fun post(ctx: Context): Boolean {
        val s = build(ctx) ?: return false
        Notifier.post(ctx, NOTIFY_ID, Notifier.builder(ctx, Notifier.WEEKLY, s.title, s.text))
        return true
    }

    fun previewOrExplain(ctx: Context): Boolean {
        if (post(ctx)) return true
        Notifier.post(
            ctx,
            NOTIFY_ID,
            Notifier.builder(ctx, Notifier.WEEKLY, "Weekly summary", "Not enough usage recorded last week yet. Your first summary arrives on a Monday morning."),
        )
        return false
    }

    /** The Monday the last summary was sent for, so a late or repeated alarm never sends it twice. */
    fun runScheduled(ctx: Context) {
        val now = System.currentTimeMillis()
        val key = Usage.dayKey(weekStart(now))
        val p = prefs(ctx)
        if (enabled(ctx) && p.getString("sent", null) != key) {
            if (post(ctx)) p.edit().putString("sent", key).apply()
        }
        schedule(ctx)
    }
}

class WeeklySummaryReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val ctx = context.applicationContext
        val pending = goAsync()
        Thread {
            try {
                when (intent.action) {
                    WeeklySummary.ACTION -> WeeklySummary.runScheduled(ctx)
                    else -> {
                        // Boot or app update: alarms are gone, so set them again.
                        WeeklySummary.schedule(ctx)
                        LimitScheduler.schedule(ctx)
                    }
                }
            } catch (_: Exception) {
            } finally {
                pending.finish()
            }
        }.start()
    }
}
