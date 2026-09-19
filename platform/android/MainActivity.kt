package com.mylock.app.my_lock

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.mylock.app/lock"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAndroidCapabilities" -> {
                    result.success(
                        mapOf(
                            "usageAccessGranted" to hasUsageAccess(),
                            "overlayGranted" to Settings.canDrawOverlays(this),
                        ),
                    )
                }

                "openUsageAccessSettings" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(null)
                }

                "openOverlaySettings" -> {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName"),
                    )
                    startActivity(intent)
                    result.success(null)
                }

                "syncProtectedApps" -> {
                    val appIds = call.argument<List<String>>("appIds").orEmpty()
                    getSharedPreferences("my_lock_native", Context.MODE_PRIVATE)
                        .edit()
                        .putStringSet("protected_apps", appIds.toSet())
                        .apply()
                    result.success(null)
                }

                "unlockGranted" -> {
                    val appId = call.argument<String>("appId")
                    getSharedPreferences("my_lock_native", Context.MODE_PRIVATE)
                        .edit()
                        .putString("last_unlocked_app", appId)
                        .putLong("last_unlocked_at", System.currentTimeMillis())
                        .apply()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            packageName,
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }
}
