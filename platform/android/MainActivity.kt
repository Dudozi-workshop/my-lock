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
        @Volatile
        private var lockChannel: MethodChannel? = null

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

        fun emitScreenOn(): Boolean {
            val channel = lockChannel ?: return false
            channel.invokeMethod("screenOn", null)
            return true
        }

        fun emitLockActivityUnlocked(appId: String): Boolean {
            val channel = lockChannel ?: return false
            channel.invokeMethod(
                "lockActivityUnlocked",
                mapOf("appId" to appId),
            )
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
                            "monitorServiceRunning" to isMonitorServiceRunning(),
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

                "presentLockScreen" -> {
                    val appId = call.argument<String>("appId")
                    if (appId.isNullOrEmpty()) {
                        result.error(
                            "invalid_app_id",
                            "A protected app id is required.",
                            null,
                        )
                    } else {
                        LockActivity.launch(this, appId)
                        result.success(null)
                    }
                }

                "syncProtectedApps" -> {
                    val appIds = call.argument<List<String>>("appIds").orEmpty()
                    getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
                        .edit()
                        .putStringSet("protected_apps", appIds.toSet())
                        .apply()

                    updateMonitorServiceState()
                    result.success(null)
                }

                "syncExperimentalScreenLock" -> {
                    val enabled = call.argument<Boolean>("enabled") == true
                    getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
                        .edit()
                        .putBoolean("experimental_screen_lock", enabled)
                        .apply()
                    updateMonitorServiceState()
                    result.success(null)
                }

                "syncRelockPolicy" -> {
                    val policy = call.argument<String>("policy") ?: "immediate"
                    getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
                        .edit()
                        .putString("relock_policy", policy)
                        .apply()
                    result.success(null)
                }

                "syncLockBackground" -> {
                    val background =
                        call.argument<String>("background") ?: "softGradient"
                    getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
                        .edit()
                        .putString("lock_background", background)
                        .apply()
                    result.success(null)
                }

                "unlockGranted" -> {
                    val appId = call.argument<String>("appId")
                    getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
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

    override fun onDestroy() {
        lockChannel = null
        super.onDestroy()
    }

    private fun updateMonitorServiceState() {
        val preferences =
            getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
        val protectedApps =
            preferences.getStringSet("protected_apps", emptySet()).orEmpty()
        val screenLockEnabled =
            preferences.getBoolean("experimental_screen_lock", false)
        val overlayReady = Settings.canDrawOverlays(this)
        val appProtectionReady =
            protectedApps.isNotEmpty() && hasUsageAccess() && overlayReady
        val screenProtectionReady = screenLockEnabled && overlayReady

        if (!appProtectionReady && !screenProtectionReady) {
            stopService(Intent(this, LockMonitorService::class.java))
            return
        }

        val intent = Intent(this, LockMonitorService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun ensureMonitorServiceIfReady() {
        updateMonitorServiceState()
    }

    private fun isMonitorServiceRunning(): Boolean {
        val heartbeat = getSharedPreferences(
            preferencesName,
            Context.MODE_PRIVATE,
        ).getLong(LockMonitorService.heartbeatKey, 0L)

        if (heartbeat <= 0L) return false
        return System.currentTimeMillis() - heartbeat <= 5_000L
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
