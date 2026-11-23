package dev.basalt.apppulse

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/** Hosts the Flutter UI and the "dev.basalt.apppulse/native" method channel. */
class MainActivity : FlutterActivity() {
    private val io = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var pendingNotificationResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result -> handle(call, result) }
    }

    /** Runs [block] off the main thread (usage queries and icons can be slow) and replies on the main thread. */
    private fun background(result: MethodChannel.Result, block: () -> Any?) {
        io.execute {
            try {
                val value = block()
                main.post { result.success(value) }
            } catch (e: Exception) {
                main.post { result.error("native_error", e.message ?: e.javaClass.simpleName, null) }
            }
        }
    }

    private fun MethodCall.long(name: String): Long =
        (argument<Number>(name) ?: throw IllegalArgumentException("$name is required")).toLong()

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        val ctx = applicationContext
        try {
            when (call.method) {
                "hasUsageAccess" -> result.success(Usage.hasAccess(ctx))
                "openUsageAccess" -> {
                    openUsageAccess()
                    result.success(null)
                }
                "events" -> {
                    val start = call.long("start")
                    val end = call.long("end")
                    background(result) { Usage.packedEvents(ctx, start, end) }
                }
                "androidTotals" -> {
                    val start = call.long("start")
                    val end = call.long("end")
                    background(result) { Usage.androidTotals(ctx, start, end) }
                }
                "apps" -> {
                    val packages = call.argument<List<String>>("packages")
                    background(result) { Apps.describe(ctx, packages) }
                }
                "icon" -> {
                    val pkg = call.argument<String>("package") ?: ""
                    val size = call.argument<Int>("size") ?: 96
                    background(result) { Apps.icon(ctx, pkg, size) }
                }
                "excludedPackages" -> background(result) { Apps.excludedPackages(ctx) }
                "openAppInfo" -> {
                    val pkg = call.argument<String>("package") ?: packageName
                    startActivity(
                        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$pkg"))
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                    )
                    result.success(null)
                }
                "notificationsEnabled" -> result.success(NotificationManagerCompat.from(ctx).areNotificationsEnabled())
                "requestNotifications" -> requestNotifications(result)
                "openNotificationSettings" -> {
                    startActivity(
                        Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                            .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                    )
                    result.success(null)
                }
                "canDrawOverlays" -> result.success(Settings.canDrawOverlays(ctx))
                "openOverlaySettings" -> {
                    startActivity(
                        Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                    )
                    result.success(null)
                }
                "syncLimits" -> {
                    val json = call.argument<String>("limits") ?: "[]"
                    val overlay = call.argument<Boolean>("overlay") ?: false
                    LimitStore.save(ctx, json, overlay)
                    LimitScheduler.schedule(ctx)
                    result.success(null)
                }
                "checkLimits" -> background(result) {
                    LimitChecker.run(ctx)
                    null
                }
                "focusStart" -> {
                    Focus.start(ctx, call.long("endAt"), call.argument<Int>("minutes") ?: 0)
                    result.success(null)
                }
                "focusStop" -> {
                    Focus.stop(ctx)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("native_error", e.message ?: e.javaClass.simpleName, null)
        }
    }

    private fun openUsageAccess() {
        // Jump straight to Clocked's row where supported; fall back to the full list.
        val direct = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS, Uri.parse("package:$packageName"))
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            startActivity(direct)
        } catch (_: Exception) {
            startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        }
    }

    private fun requestNotifications(result: MethodChannel.Result) {
        val enabled = NotificationManagerCompat.from(this).areNotificationsEnabled()
        if (enabled || Build.VERSION.SDK_INT < 33) {
            result.success(enabled)
            return
        }
        if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) {
            result.success(enabled)
            return
        }
        pendingNotificationResult?.success(false)
        pendingNotificationResult = result
        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQUEST_NOTIFICATIONS)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_NOTIFICATIONS) {
            pendingNotificationResult?.success(NotificationManagerCompat.from(this).areNotificationsEnabled())
            pendingNotificationResult = null
        }
    }

    companion object {
        const val CHANNEL = "dev.basalt.apppulse/native"
        private const val REQUEST_NOTIFICATIONS = 41
    }
}
