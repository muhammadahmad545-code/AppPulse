package dev.basalt.apppulse

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import org.json.JSONArray
import org.json.JSONObject

/**
 * Home-screen widget: today's screen time, the change against yesterday and the top 3 apps.
 * The app pushes its own numbers after every sync; the native limit check recomputes them in between.
 */
class UsageWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val views = render(context)
        ids.forEach { manager.updateAppWidget(it, views) }
        // Fresh numbers without waiting for the next sync or check.
        WorkManager.getInstance(context).enqueueUniqueWork(
            WORK,
            ExistingWorkPolicy.REPLACE,
            OneTimeWorkRequest.Builder(WidgetWorker::class.java).build(),
        )
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        LimitScheduler.schedule(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        LimitScheduler.schedule(context)
    }

    companion object {
        private const val PREFS = "clocked_widget"
        private const val WORK = "clocked-widget-refresh"

        fun installed(ctx: Context): Boolean =
            AppWidgetManager.getInstance(ctx).getAppWidgetIds(ComponentName(ctx, UsageWidget::class.java)).isNotEmpty()

        /** Stores [json] (from the app) and redraws every placed widget. */
        fun save(ctx: Context, json: String) {
            ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString("data", json).apply()
            redraw(ctx)
        }

        /** Recomputes today's numbers natively (used by the background check). */
        fun refreshNative(ctx: Context) {
            if (!installed(ctx)) return
            val now = System.currentTimeMillis()
            val access = Usage.hasAccess(ctx)
            val data = JSONObject().put("day", Usage.dayKey(now)).put("access", access)
            if (access) {
                val today = Usage.startOfDay(now)
                val yesterdayStart = Usage.startOfDay(today - 12 * 3_600_000L)
                val totals = Usage.appTotals(ctx, today, now)
                val yesterday = Usage.appTotals(ctx, yesterdayStart, today).values.sum()
                val top = JSONArray()
                totals.entries.sortedByDescending { it.value }.take(3).forEach {
                    top.put(JSONObject().put("name", Usage.label(ctx, it.key)).put("ms", it.value))
                }
                data.put("total", totals.values.sum()).put("yesterday", yesterday).put("top", top)
            }
            save(ctx, data.toString())
        }

        private fun redraw(ctx: Context) {
            val manager = AppWidgetManager.getInstance(ctx)
            val ids = manager.getAppWidgetIds(ComponentName(ctx, UsageWidget::class.java))
            if (ids.isEmpty()) return
            val views = render(ctx)
            ids.forEach { manager.updateAppWidget(it, views) }
        }

        private fun render(ctx: Context): RemoteViews {
            val raw = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString("data", null)
            val data = raw?.let { runCatching { JSONObject(it) }.getOrNull() }
            val v = RemoteViews(ctx.packageName, R.layout.usage_widget)
            val rows = listOf(
                Triple(R.id.widget_row1, R.id.widget_app1, R.id.widget_time1),
                Triple(R.id.widget_row2, R.id.widget_app2, R.id.widget_time2),
                Triple(R.id.widget_row3, R.id.widget_app3, R.id.widget_time3),
            )
            val today = Usage.dayKey(System.currentTimeMillis())
            val fresh = data != null && data.optString("day") == today
            when {
                data != null && !data.optBoolean("access", true) -> {
                    v.setTextViewText(R.id.widget_total, "—")
                    v.setTextViewText(R.id.widget_change, "Open Clocked to allow usage access")
                    rows.forEach { v.setViewVisibility(it.first, View.GONE) }
                }
                !fresh -> {
                    v.setTextViewText(R.id.widget_total, "—")
                    v.setTextViewText(R.id.widget_change, "Open Clocked to refresh")
                    rows.forEach { v.setViewVisibility(it.first, View.GONE) }
                }
                else -> {
                    val total = data!!.optLong("total")
                    v.setTextViewText(R.id.widget_total, Usage.fmt(total))
                    v.setTextViewText(
                        R.id.widget_change,
                        Usage.change(total, data.optLong("yesterday"), "yesterday") ?: "No data for yesterday yet",
                    )
                    val top = data.optJSONArray("top") ?: JSONArray()
                    rows.forEachIndexed { i, (row, app, time) ->
                        val o = top.optJSONObject(i)
                        if (o == null) {
                            v.setViewVisibility(row, if (i == 0) View.VISIBLE else View.GONE)
                            v.setTextViewText(app, if (i == 0) "No app use yet today" else "")
                            v.setTextViewText(time, "")
                        } else {
                            v.setViewVisibility(row, View.VISIBLE)
                            v.setTextViewText(app, o.optString("name"))
                            v.setTextViewText(time, Usage.fmt(o.optLong("ms")))
                        }
                    }
                }
            }
            val open = (ctx.packageManager.getLaunchIntentForPackage(ctx.packageName) ?: Intent(ctx, MainActivity::class.java))
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            v.setOnClickPendingIntent(
                R.id.widget_root,
                PendingIntent.getActivity(ctx, 51, open, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT),
            )
            return v
        }
    }
}

class WidgetWorker(ctx: Context, params: WorkerParameters) : Worker(ctx, params) {
    override fun doWork(): Result {
        try {
            UsageWidget.refreshNative(applicationContext)
        } catch (_: Exception) {
        }
        return Result.success()
    }
}
