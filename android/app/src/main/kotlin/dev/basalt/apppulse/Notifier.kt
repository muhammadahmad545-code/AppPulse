package dev.basalt.apppulse

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

object Notifier {
    const val LIMITS = "limits"
    const val FOCUS = "focus"
    const val FOCUS_ONGOING = "focus_ongoing"
    const val DOWNTIME = "downtime"
    const val WEEKLY = "weekly"
    const val FOCUS_ONGOING_ID = 2001
    const val FOCUS_DONE_ID = 2002

    fun ensureChannels(ctx: Context) {
        val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.createNotificationChannel(
            NotificationChannel(LIMITS, "App limits", NotificationManager.IMPORTANCE_HIGH).apply {
                description = "When an app is close to or over its daily limit"
            },
        )
        nm.createNotificationChannel(
            NotificationChannel(FOCUS, "Focus sessions", NotificationManager.IMPORTANCE_DEFAULT).apply {
                description = "When a focus session ends"
            },
        )
        nm.createNotificationChannel(
            NotificationChannel(FOCUS_ONGOING, "Focus timer", NotificationManager.IMPORTANCE_LOW).apply {
                description = "Quiet countdown while a focus session runs"
                setShowBadge(false)
            },
        )
        nm.createNotificationChannel(
            NotificationChannel(DOWNTIME, "Downtime", NotificationManager.IMPORTANCE_DEFAULT).apply {
                description = "A gentle nudge when you open a downtime app inside your downtime window"
            },
        )
        nm.createNotificationChannel(
            NotificationChannel(WEEKLY, "Weekly summary", NotificationManager.IMPORTANCE_DEFAULT).apply {
                description = "Last week's screen time, every Monday morning"
            },
        )
    }

    private fun openApp(ctx: Context): PendingIntent {
        val intent = (ctx.packageManager.getLaunchIntentForPackage(ctx.packageName) ?: Intent(ctx, MainActivity::class.java))
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        return PendingIntent.getActivity(ctx, 0, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
    }

    fun builder(ctx: Context, channel: String, title: String, text: String): NotificationCompat.Builder =
        NotificationCompat.Builder(ctx, channel)
            .setSmallIcon(R.drawable.ic_stat_apppulse)
            .setColor(0xFF0369A1.toInt())
            .setContentTitle(title)
            .setContentText(text)
            .setStyle(NotificationCompat.BigTextStyle().bigText(text))
            .setContentIntent(openApp(ctx))
            .setAutoCancel(true)

    @SuppressLint("MissingPermission")
    fun post(ctx: Context, id: Int, builder: NotificationCompat.Builder) {
        ensureChannels(ctx)
        val nm = NotificationManagerCompat.from(ctx)
        if (!nm.areNotificationsEnabled()) return
        try {
            nm.notify(id, builder.build())
        } catch (_: SecurityException) {
        }
    }

    fun cancel(ctx: Context, id: Int) = NotificationManagerCompat.from(ctx).cancel(id)
}
