package dev.basalt.apppulse

import android.content.Context
import androidx.core.app.NotificationCompat
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import java.text.DateFormat
import java.util.Date
import java.util.concurrent.TimeUnit

/** Focus session notifications: a quiet countdown while it runs and a heads-up when it ends. */
object Focus {
    private const val WORK = "apppulse-focus-end"

    fun start(ctx: Context, endAt: Long, minutes: Int) {
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
    }

    fun stop(ctx: Context) {
        Notifier.cancel(ctx, Notifier.FOCUS_ONGOING_ID)
        WorkManager.getInstance(ctx).cancelUniqueWork(WORK)
    }
}

class FocusEndWorker(ctx: Context, params: WorkerParameters) : Worker(ctx, params) {
    override fun doWork(): Result {
        val ctx = applicationContext
        Notifier.cancel(ctx, Notifier.FOCUS_ONGOING_ID)
        Notifier.post(
            ctx,
            Notifier.FOCUS_DONE_ID,
            Notifier.builder(ctx, Notifier.FOCUS, "Focus session complete", "Nice work. Open Clocked to see how it went."),
        )
        return Result.success()
    }
}
