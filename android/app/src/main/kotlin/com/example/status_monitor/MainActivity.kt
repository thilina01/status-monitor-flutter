package com.slconsultech.statusmonitorapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.slconsultech.status_monitor/minimize"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "minimizeApp") {
                // Move the task (app) to background instead of finishing the activity.
                moveTaskToBack(true)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
