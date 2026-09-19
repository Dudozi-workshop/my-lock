package com.mylock.app.my_lock

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val channelName = "com.mylock.app/lock"
        private const val preferencesName = "my_lock_native"
        private const val pendingLockAppKey = "pending_lock_app"

        @Volatile
        private var lockChannel: MethodChannel? = null

        @Volatile
        var lockUiVisible: Boolean = false

        fun emitProtectedAppEntered(appId: String): Boolean {
            val channel = lockChannel ?: return false
            channel.invokeMethod(
                "protectedAppEntered",
                mapOf("appId" to appId),
            )
            return true
        }

        fun emitProtectedAppExited(appId: String): Boolean {
            val channel = lockChannel ?: return false
            channel.invokeMethod(
                "protectedAppExited",
                mapOf("appId" to appId),
            )
            return true
        }

        fun emitScreenOff(): Boolean {
            val channel = lockChannel ?: return false
            channel.invokeMethod("screenOff", null)
            return true
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        )
        lockChannel = channel

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getLaunchableApps" -> {
                    val launcherIntent = Intent(Intent.ACTION_MAIN).apply {
                        addCategory(Intent.CATEGORY_LAUNCHER)
                    }
                    val apps = packageManager
                        .queryIntentActivities(launcherIntent, 0)
                        .asSequence()
                        .mapNotNull { resolveInfo ->
                            val appInfo = resolveInfo.activityInfo?.applicationInfo
                                ?: return@mapNotNull null
                            val packageId = appInfo.packageName
                            if (packageId == packageName) {
                                return@mapNotNull null
                            }
                            mapOf(
                                "id" to packageId,
                                "name" to packageManager
                                    .getApplicationLabel(appInfo)
                                    .toString(),
                            )
                        }
                        .distinctBy { it["id"] }
                        .sortedBy { it["name"]?.lowercase() }
                        .toList()

                    result.success(apps)
                }

                "getAndroidCapabilities" -> {
                    ensureMonitorServiceIfReady()
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

                "consumePendingLock" -> {
                    val preferences =
                        getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
                    val appId = preferences.getString(pendingLockAppKey, null)
                    if (appId != null) {
                        preferences.edit().remove(pendingLockAppKey).apply()
                    }
                    result.success(appId)
                }

                "presentLockScreen" -> {
                    val appId = call.argument<String>("appId")
                    if (appId.isNullOrEmpty()) {
                        result.error(
                            "invalid_app_id",
                            "A protected app id is required.",
                            null,
                        )
                    } else {
                        presentLockScreen()
                        result.success(null)
                    }
                }

                "syncProtectedApps" -> {
                    val appIds = call.argument<List<String>>("appIds").orEmpty()
                    getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
                        .edit()
                        .putStringSet("protected_apps", appIds.toSet())
                        .apply()

                    if (appIds.isEmpty()) {
                        stopService(Intent(this, LockMonitorService::class.java))
                    } else {
                        ensureMonitorServiceIfReady()
                    }
                    result.success(null)
                }

                "unlockGranted" -> {
                    val appId = call.argument<String>("appId")
                    getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
                        .edit()
                        .putString("last_unlocked_app", appId)
                        .putLong("last_unlocked_at", System.currentTimeMillis())
                        .apply()

                    lockUiVisible = false
                    result.success(null)
                    moveTaskToBack(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        lockChannel = null
        lockUiVisible = false
        super.onDestroy()
    }

    private fun presentLockScreen() {
        if (lockUiVisible) return
        lockUiVisible = true

        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT,
            )
        }
        startActivity(intent)

        @Suppress("DEPRECATION")
        overridePendingTransition(0, 0)
    }

    private fun ensureMonitorServiceIfReady() {
        val protectedApps =
            getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
                .getStringSet("protected_apps", emptySet())
                .orEmpty()

        if (
            protectedApps.isEmpty() ||
            !hasUsageAccess() ||
            !Settings.canDrawOverlays(this)
        ) {
            return
        }

        val intent = Intent(this, LockMonitorService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
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
