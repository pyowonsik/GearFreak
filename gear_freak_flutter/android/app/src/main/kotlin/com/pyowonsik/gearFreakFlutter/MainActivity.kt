package com.pyowonsik.gearFreakFlutter

import android.app.NotificationManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.gearfreak/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "cancelAllNotifications" -> {
                    cancelAllNotifications()
                    result.success(null)
                }
                "cancelNotification" -> {
                    val id = call.argument<Int>("id")
                    val tag = call.argument<String>("tag")
                    if (id != null) {
                        cancelNotification(id, tag)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Notification ID is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun cancelAllNotifications() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancelAll()
    }

    private fun cancelNotification(id: Int, tag: String?) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (tag != null) {
            notificationManager.cancel(tag, id)
        } else {
            notificationManager.cancel(id)
        }
    }
}
