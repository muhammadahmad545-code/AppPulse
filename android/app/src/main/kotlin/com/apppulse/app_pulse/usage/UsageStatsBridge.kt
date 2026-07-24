package com.apppulse.app_pulse.usage

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.os.Process
import android.provider.Settings
import android.util.TypedValue
import android.view.Gravity
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.FileProvider
import java.io.ByteArrayOutputStream
import java.io.File

/**
 * Native bridge around [UsageStatsManager], PackageManager, and battery optimization.
 */
class UsageStatsBridge(private val context: Context) {

    fun hasUsagePermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName,
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName,
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun openUsageAccessSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    fun isIgnoringBatteryOptimizations(): Boolean {
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(context.packageName)
    }

    fun requestIgnoreBatteryOptimizations() {
        if (isIgnoringBatteryOptimizations()) return
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
            data = Uri.parse("package:${context.packageName}")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    fun openBatteryOptimizationSettings() {
        val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    fun canDrawOverlays(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else {
            true
        }
    }

    fun openOverlaySettings() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:${context.packageName}"),
        ).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    /** Brief system overlay reminder when overlay permission is granted. */
    fun canRequestPackageInstalls(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.packageManager.canRequestPackageInstalls()
        } else {
            true
        }
    }

    fun openUnknownAppSourcesSettings() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val intent = Intent(
            Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
            Uri.parse("package:${context.packageName}"),
        ).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    fun installApk(path: String) {
        val file = File(path)
        if (!file.exists()) {
            throw IllegalArgumentException("APK not found: $path")
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            !context.packageManager.canRequestPackageInstalls()
        ) {
            openUnknownAppSourcesSettings()
            throw IllegalStateException(
                "Enable “Allow from this source” for AppPulse, then tap Update again.",
            )
        }
        val uri = FileProvider.getUriForFile(
            context,
            "${context.packageName}.fileprovider",
            file,
        )
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        context.startActivity(intent)
    }

    fun showLimitOverlay(title: String, body: String) {
        if (!canDrawOverlays()) return
        val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val density = context.resources.displayMetrics.density
        val pad = (20 * density).toInt()

        val container = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(pad, pad, pad, pad)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#E6121B2E"))
                cornerRadius = 28f * density
            }
        }
        container.addView(
            TextView(context).apply {
                text = title
                setTextColor(Color.WHITE)
                setTypeface(typeface, Typeface.BOLD)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
            },
        )
        container.addView(
            TextView(context).apply {
                text = body
                setTextColor(Color.parseColor("#CCFFFFFF"))
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
                setPadding(0, (8 * density).toInt(), 0, 0)
            },
        )

        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP
            y = (48 * density).toInt()
        }

        Handler(Looper.getMainLooper()).post {
            try {
                wm.addView(container, params)
                Handler(Looper.getMainLooper()).postDelayed({
                    try {
                        wm.removeView(container)
                    } catch (_: Exception) {
                    }
                }, 6_000L)
            } catch (_: Exception) {
            }
        }
    }

    fun getForegroundApp(): String? {
        if (!hasUsagePermission()) return null
        val usm = usageStatsManager() ?: return null
        val end = System.currentTimeMillis()
        val begin = end - 60_000L
        val events = usm.queryEvents(begin, end)
        val event = UsageEvents.Event()
        var foreground: String? = null
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            when (event.eventType) {
                UsageEvents.Event.ACTIVITY_RESUMED,
                UsageEvents.Event.MOVE_TO_FOREGROUND,
                -> foreground = event.packageName
                UsageEvents.Event.ACTIVITY_PAUSED,
                UsageEvents.Event.MOVE_TO_BACKGROUND,
                -> if (foreground == event.packageName) foreground = null
            }
        }
        return foreground
    }

    fun getUsageEvents(startMs: Long, endMs: Long): List<Map<String, Any?>> {
        if (!hasUsagePermission()) return emptyList()
        val usm = usageStatsManager() ?: return emptyList()
        val events = usm.queryEvents(startMs, endMs)
        val event = UsageEvents.Event()
        val result = ArrayList<Map<String, Any?>>()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val type = event.eventType
            if (type != UsageEvents.Event.ACTIVITY_RESUMED &&
                type != UsageEvents.Event.ACTIVITY_PAUSED &&
                type != UsageEvents.Event.ACTIVITY_STOPPED &&
                type != UsageEvents.Event.MOVE_TO_FOREGROUND &&
                type != UsageEvents.Event.MOVE_TO_BACKGROUND
            ) {
                continue
            }
            val className = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                event.className
            } else {
                null
            }
            result.add(
                mapOf(
                    "packageName" to event.packageName,
                    "timestampMs" to event.timeStamp,
                    "eventType" to type,
                    "className" to className,
                ),
            )
        }
        return result
    }

    fun getUsageStats(startMs: Long, endMs: Long): List<Map<String, Any?>> {
        if (!hasUsagePermission()) return emptyList()
        val usm = usageStatsManager() ?: return emptyList()
        val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startMs, endMs)
            ?: return emptyList()
        return stats
            .filter { it.totalTimeInForeground > 0 }
            .map {
                mapOf(
                    "packageName" to it.packageName,
                    "totalTimeForegroundMs" to it.totalTimeInForeground,
                    "lastTimeUsedMs" to it.lastTimeUsed,
                    "firstTimeStampMs" to it.firstTimeStamp,
                    "lastTimeStampMs" to it.lastTimeStamp,
                )
            }
    }

    fun getInstalledApps(includeIcons: Boolean = false): List<Map<String, Any?>> {
        val pm = context.packageManager
        val launcherIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val launchables = pm.queryIntentActivities(launcherIntent, PackageManager.MATCH_ALL)
        val seen = HashSet<String>()
        val apps = ArrayList<Map<String, Any?>>()

        for (resolveInfo in launchables) {
            val packageName = resolveInfo.activityInfo.packageName ?: continue
            if (!seen.add(packageName)) continue
            try {
                apps.add(buildAppMap(pm, packageName, includeIcons))
            } catch (_: Exception) {
                // Skip apps that disappear mid-query.
            }
        }
        return apps.sortedBy { (it["appName"] as? String)?.lowercase() ?: "" }
    }

    fun getAppIcon(packageName: String): ByteArray? {
        return try {
            val drawable = context.packageManager.getApplicationIcon(packageName)
            drawableToPngBytes(drawable)
        } catch (_: Exception) {
            null
        }
    }

    private fun buildAppMap(
        pm: PackageManager,
        packageName: String,
        includeIcons: Boolean,
    ): Map<String, Any?> {
        val appInfo = pm.getApplicationInfo(packageName, 0)
        val packageInfo = pm.getPackageInfo(packageName, 0)
        val appName = pm.getApplicationLabel(appInfo).toString()
        val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
        val category = resolveCategory(packageName, appInfo)
        val installTime = packageInfo.firstInstallTime
        val updateTime = packageInfo.lastUpdateTime
        val versionName = packageInfo.versionName
        val versionCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            packageInfo.longVersionCode
        } else {
            @Suppress("DEPRECATION")
            packageInfo.versionCode.toLong()
        }

        val map = mutableMapOf<String, Any?>(
            "packageName" to packageName,
            "appName" to appName,
            "versionName" to versionName,
            "versionCode" to versionCode,
            "isSystemApp" to isSystem,
            "category" to category,
            "installTimeMs" to installTime,
            "updateTimeMs" to updateTime,
        )
        if (includeIcons) {
            map["iconPng"] = drawableToPngBytes(pm.getApplicationIcon(appInfo))
        }
        return map
    }

    private fun resolveCategory(packageName: String, appInfo: ApplicationInfo): String {
        val heuristic = heuristicCategory(packageName)
        if (heuristic != "other") return heuristic

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return when (appInfo.category) {
                ApplicationInfo.CATEGORY_GAME -> "gaming"
                ApplicationInfo.CATEGORY_AUDIO -> "music"
                ApplicationInfo.CATEGORY_VIDEO -> "entertainment"
                ApplicationInfo.CATEGORY_IMAGE -> "photography"
                ApplicationInfo.CATEGORY_SOCIAL -> "social"
                ApplicationInfo.CATEGORY_NEWS -> "news"
                ApplicationInfo.CATEGORY_MAPS -> "travel"
                ApplicationInfo.CATEGORY_PRODUCTIVITY -> "productivity"
                else -> "other"
            }
        }
        return "other"
    }

    private fun heuristicCategory(packageName: String): String {
        val p = packageName.lowercase()
        return when {
            listOf("whatsapp", "telegram", "signal", "messenger", "sms", "messages", "discord", "viber", "skype")
                .any { p.contains(it) } -> "messaging"
            listOf(
                "instagram", "facebook", "twitter", "x.com", "tiktok", "snapchat", "reddit",
                "linkedin", "pinterest", "threads", "mastodon", "bluesky",
            ).any { p.contains(it) } -> "social"
            listOf(
                "youtube", "netflix", "spotify", "twitch", "primevideo", "disney", "hotstar",
                "hulu", "crunchyroll", "sonyliv", "jiocinema",
            ).any { p.contains(it) } -> "entertainment"
            listOf("chrome", "firefox", "edge", "browser", "opera", "brave", "samsung.internet")
                .any { p.contains(it) } -> "utilities"
            listOf(
                "gmail", "outlook", "office", "docs", "sheets", "notion", "evernote", "slack",
                "teams", "trello", "asana", "jira", "zoom", "meet",
            ).any { p.contains(it) } -> "productivity"
            listOf(
                "duolingo", "khan", "coursera", "udemy", "classroom", "quizlet", "brilliant",
            ).any { p.contains(it) } -> "education"
            listOf(
                "paypal", "venmo", "bank", "wallet", "paytm", "phonepe", "revolut", "stripe",
                "wise", "cashapp", "jazzcash", "easypaisa", "binance", "coinbase",
            ).any { p.contains(it) } -> "finance"
            listOf(
                "fitbit", "myfitness", "health", "strava", "nike", "adidas", "calm", "headspace",
            ).any { p.contains(it) } -> "health"
            listOf(
                "amazon", "ebay", "shopify", "aliexpress", "walmart", "flipkart", "daraz", "etsy",
            ).any { p.contains(it) } -> "shopping"
            listOf(
                "uber", "lyft", "maps", "waze", "booking", "airbnb", "tripadvisor", "careem", "bykea",
            ).any { p.contains(it) } -> "travel"
            listOf("game", "play.games", "roblox", "minecraft", "pubg", "fortnite", "candycrush")
                .any { p.contains(it) } -> "gaming"
            listOf("camera", "photo", "gallery", "lightroom", "vsco", "snapseed")
                .any { p.contains(it) } -> "photography"
            listOf("news", "cnn", "bbc", "nytimes", "dawn", "geo.tv").any { p.contains(it) } -> "news"
            listOf(
                "food", "doordash", "ubereats", "grubhub", "swiggy", "zomato", "foodpanda",
            ).any { p.contains(it) } -> "food"
            listOf("music", "podcast", "audiomack", "soundcloud", "anghami")
                .any { p.contains(it) } -> "music"
            listOf("business", "crm", "salesforce", "hubspot").any { p.contains(it) } -> "business"
            listOf("lifestyle", "pinterest").any { p.contains(it) } -> "lifestyle"
            else -> "other"
        }
    }

    private fun drawableToPngBytes(drawable: Drawable): ByteArray? {
        return try {
            val bitmap = when (drawable) {
                is BitmapDrawable -> drawable.bitmap
                else -> {
                    val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 192
                    val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 192
                    val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                    val canvas = Canvas(bmp)
                    drawable.setBounds(0, 0, canvas.width, canvas.height)
                    drawable.draw(canvas)
                    bmp
                }
            }
            val size = 192
            val scaled = Bitmap.createScaledBitmap(bitmap, size, size, true)
            val stream = ByteArrayOutputStream()
            scaled.compress(Bitmap.CompressFormat.PNG, 90, stream)
            stream.toByteArray()
        } catch (_: Exception) {
            null
        }
    }

    private fun usageStatsManager(): UsageStatsManager? {
        return context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
    }
}
