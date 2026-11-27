package dev.basalt.apppulse

import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.IBinder
import android.os.PowerManager
import android.os.SystemClock
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat

/**
 * Keeps limit reminders and downtime nudges on time.
 *
 * WorkManager alone runs "every 15 minutes" only in theory: Android delays background work by up to
 * hours for apps that are rarely opened, so a 45-minute limit could be reported at 1h 10m. While any
 * limit or downtime schedule is on, this small foreground service (with a silent notification) watches
 * for app switches every few seconds while the screen is on, and checks again exactly when the app in
 * front reaches its next threshold. With the screen off it does nothing.
 */
class LimitGuard : Service() {
    companion object {
        const val NOTIFICATION_ID = 2010
        private const val POLL_MS = 4_000L

        /** True while limits or downtime need watching and usage access is granted. */
        fun needed(ctx: Context): Boolean =
            Usage.hasAccess(ctx) && (LimitStore.limits(ctx).isNotEmpty() || Downtime.config(ctx).active)

        /** Starts or stops the service to match [needed]. Safe to call from anywhere. */
        fun sync(ctx: Context) {
            val app = ctx.applicationContext
            val intent = Intent(app, LimitGuard::class.java)
            try {
                if (needed(app)) ContextCompat.startForegroundService(app, intent) else app.stopService(intent)
            } catch (_: Exception) {
                // Android refuses to start foreground services from some background states; the
                // WorkManager check stays as the fallback and the next app open starts the service.
            }
        }
    }

    private lateinit var thread: HandlerThread
    private lateinit var handler: Handler
    private var lastPoll = 0L
    private var registered = false

    private val screen = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            handler.post {
                if (intent.action == Intent.ACTION_SCREEN_OFF) {
                    handler.removeCallbacks(poll)
                    handler.removeCallbacks(check)
                } else {
                    fullCheck()
                }
            }
        }
    }

    private val poll = object : Runnable {
        override fun run() {
            if (!interactive()) return
            val now = System.currentTimeMillis()
            val changed = try {
                Usage.changedSince(this@LimitGuard, lastPoll, now)
            } catch (_: Exception) {
                false
            }
            lastPoll = now
            if (changed) fullCheck() else handler.postDelayed(this, POLL_MS)
        }
    }

    private val check = Runnable { fullCheck() }

    override fun onCreate() {
        super.onCreate()
        thread = HandlerThread("clocked-limit-guard").also { it.start() }
        handler = Handler(thread.looper)
        promote()
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_USER_PRESENT)
            addAction(Intent.ACTION_TIME_CHANGED)
            addAction(Intent.ACTION_TIMEZONE_CHANGED)
            addAction(Intent.ACTION_DATE_CHANGED)
        }
        try {
            ContextCompat.registerReceiver(this, screen, filter, ContextCompat.RECEIVER_NOT_EXPORTED)
            registered = true
        } catch (_: Exception) {
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        promote()
        handler.post { fullCheck() }
        return START_STICKY
    }

    override fun onDestroy() {
        if (registered) {
            try {
                unregisterReceiver(screen)
            } catch (_: Exception) {
            }
        }
        handler.removeCallbacksAndMessages(null)
        thread.quitSafely()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun promote() {
        val n = Notifier.builder(
            this,
            Notifier.GUARD,
            "Watching your app limits",
            "So reminders arrive on time. Uses no internet; checks only while the screen is on.",
        )
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setStyle(null)
            .build()
        Notifier.ensureChannels(this)
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE else 0
        try {
            ServiceCompat.startForeground(this, NOTIFICATION_ID, n, type)
        } catch (_: Exception) {
            stopSelf()
        }
    }

    private fun interactive(): Boolean = (getSystemService(Context.POWER_SERVICE) as PowerManager).isInteractive

    /** Full pass over today's usage; then poll for app switches and book the next exact check. */
    private fun fullCheck() {
        handler.removeCallbacks(poll)
        handler.removeCallbacks(check)
        if (!needed(this)) {
            stopSelf()
            return
        }
        val next = try {
            LimitChecker.run(this, refreshWidget = false, scheduleFollowUp = false)
        } catch (_: Exception) {
            null
        }
        lastPoll = System.currentTimeMillis()
        if (!interactive()) return
        if (next != null) handler.postAtTime(check, SystemClock.uptimeMillis() + next.coerceAtLeast(1_000L) + 500L)
        handler.postDelayed(poll, POLL_MS)
    }
}
