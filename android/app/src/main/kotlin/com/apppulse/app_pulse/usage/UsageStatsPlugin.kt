package com.apppulse.app_pulse.usage

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Flutter plugin exposing [UsageStatsBridge] on every FlutterEngine (UI + FGS).
 */
class UsageStatsPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private var bridge: UsageStatsBridge? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        bridge = UsageStatsBridge(binding.applicationContext)
        channel = MethodChannel(binding.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        bridge = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val bridge = bridge
        if (bridge == null) {
            result.error("unavailable", "UsageStatsBridge not ready", null)
            return
        }

        try {
            when (call.method) {
                "hasUsagePermission" -> result.success(bridge.hasUsagePermission())
                "openUsageAccessSettings" -> {
                    bridge.openUsageAccessSettings()
                    result.success(null)
                }
                "isIgnoringBatteryOptimizations" ->
                    result.success(bridge.isIgnoringBatteryOptimizations())
                "requestIgnoreBatteryOptimizations" -> {
                    bridge.requestIgnoreBatteryOptimizations()
                    result.success(null)
                }
                "openBatteryOptimizationSettings" -> {
                    bridge.openBatteryOptimizationSettings()
                    result.success(null)
                }
                "getForegroundApp" -> result.success(bridge.getForegroundApp())
                "getUsageEvents" -> {
                    val startMs = call.argument<Number>("startMs")?.toLong()
                    val endMs = call.argument<Number>("endMs")?.toLong()
                    if (startMs == null || endMs == null) {
                        result.error("bad_args", "startMs and endMs required", null)
                        return
                    }
                    result.success(bridge.getUsageEvents(startMs, endMs))
                }
                "getUsageStats" -> {
                    val startMs = call.argument<Number>("startMs")?.toLong()
                    val endMs = call.argument<Number>("endMs")?.toLong()
                    if (startMs == null || endMs == null) {
                        result.error("bad_args", "startMs and endMs required", null)
                        return
                    }
                    result.success(bridge.getUsageStats(startMs, endMs))
                }
                "getInstalledApps" -> {
                    val includeIcons = call.argument<Boolean>("includeIcons") ?: false
                    result.success(bridge.getInstalledApps(includeIcons))
                }
                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName.isNullOrBlank()) {
                        result.error("bad_args", "packageName required", null)
                        return
                    }
                    result.success(bridge.getAppIcon(packageName))
                }
                else -> result.notImplemented()
            }
        } catch (error: Exception) {
            result.error("usage_stats_error", error.message, null)
        }
    }

    companion object {
        const val CHANNEL = "com.apppulse.app_pulse/usage_stats"
    }
}
