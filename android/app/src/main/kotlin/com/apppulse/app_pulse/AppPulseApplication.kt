package com.apppulse.app_pulse

import android.app.Application
import com.apppulse.app_pulse.usage.UsageStatsPlugin
import com.pravera.flutter_foreground_task.FlutterForegroundTaskPlugin
import com.pravera.flutter_foreground_task.FlutterForegroundTaskLifecycleListener
import com.pravera.flutter_foreground_task.FlutterForegroundTaskStarter
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

/**
 * Registers platform plugins on the foreground-service FlutterEngine so
 * usage tracking / Drift / path_provider work outside the UI isolate.
 */
class AppPulseApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        FlutterForegroundTaskPlugin.addTaskLifecycleListener(
            object : FlutterForegroundTaskLifecycleListener {
                override fun onEngineCreate(flutterEngine: FlutterEngine?) {
                    if (flutterEngine == null) return
                    GeneratedPluginRegistrant.registerWith(flutterEngine)
                    flutterEngine.plugins.add(UsageStatsPlugin())
                }

                override fun onTaskStart(starter: FlutterForegroundTaskStarter) = Unit

                override fun onTaskRepeatEvent() = Unit

                override fun onTaskDestroy() = Unit

                override fun onEngineWillDestroy() = Unit
            },
        )
    }
}
