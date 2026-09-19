package com.mylock.app.my_lock

import android.app.AppOpsManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.util.Base64
import java.io.ByteArrayOutputStream
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
                    result.success(loadLockableApps())
                }

                "getAndroidCapabilities" -> {
                    ensureMonitorServiceIfReady()
                    result.success(
                        mapOf(
                            "usageAccessGranted" to hasUsageAccess(),
                            "accessibilityGranted" to isAccessibilityServiceEnabled(),
                            "overlayGranted" to Settings.canDrawOverlays(this),
                            "monitorServiceRunning" to isMonitorServiceRunning(),
                        ),
                    )
                }

                "openUsageAccessSettings" -> {
                    openUsageAccessSettings()
                    result.success(null)
                }

                "openAccessibilitySettings" -> {
                    openAccessibilitySettings()
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
            protectedApps.isNotEmpty() &&
                (hasUsageAccess() || isAccessibilityServiceEnabled()) &&
                overlayReady
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

    private fun loadLockableApps(): List<Map<String, String>> {
        val intents = listOf(
            Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_LAUNCHER)
            },
            Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_LEANBACK_LAUNCHER)
            },
        )

        return intents
            .asSequence()
            .flatMap { packageManager.queryIntentActivities(it, 0).asSequence() }
            .mapNotNull { resolveInfo ->
                val appInfo = resolveInfo.activityInfo?.applicationInfo
                    ?: return@mapNotNull null
                val packageId = appInfo.packageName
                if (packageId == packageName) return@mapNotNull null

                val icon = runCatching {
                    encodeDrawableToBase64(packageManager.getApplicationIcon(appInfo))
                }.getOrNull()

                buildMap {
                    put("id", packageId)
                    put(
                        "name",
                        packageManager.getApplicationLabel(appInfo).toString(),
                    )
                    if (!icon.isNullOrBlank()) {
                        put("iconBase64", icon)
                    }
                }
            }
            .distinctBy { it["id"] }
            .sortedBy { it["name"]?.lowercase() }
            .toList()
    }

    private fun encodeDrawableToBase64(
        drawable: android.graphics.drawable.Drawable,
    ): String {
        val bitmap = if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            val width = drawable.intrinsicWidth.coerceAtLeast(1)
            val height = drawable.intrinsicHeight.coerceAtLeast(1)
            Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888).also {
                val canvas = Canvas(it)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
            }
        }

        val scaled = Bitmap.createScaledBitmap(bitmap, 96, 96, true)
        val stream = ByteArrayOutputStream()
        scaled.compress(Bitmap.CompressFormat.PNG, 90, stream)
        return Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
    }

    private fun openUsageAccessSettings() {
        val direct = Intent(
            Settings.ACTION_USAGE_ACCESS_SETTINGS,
            Uri.parse("package:$packageName"),
        )
        val fallback = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        runCatching { startActivity(direct) }
            .recoverCatching { startActivity(fallback) }
    }

    private fun openAccessibilitySettings() {
        val component =
            ComponentName(this, MyLockAccessibilityService::class.java)
        val direct = Intent("android.settings.ACCESSIBILITY_DETAILS_SETTINGS").apply {
            putExtra(
                "android.intent.extra.COMPONENT_NAME",
                component.flattenToString(),
            )
            data = Uri.parse("package:$packageName")
        }
        val fallback = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)

        runCatching {
            if (direct.resolveActivity(packageManager) != null) {
                startActivity(direct)
            } else {
                startActivity(fallback)
            }
        }.recoverCatching {
            startActivity(fallback)
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val enabled = Settings.Secure.getInt(
            contentResolver,
            Settings.Secure.ACCESSIBILITY_ENABLED,
            0,
        ) == 1
        if (!enabled) return false

        val expected =
            ComponentName(this, MyLockAccessibilityService::class.java)
                .flattenToString()
        val services = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ).orEmpty()

        return services
            .split(':')
            .any { it.equals(expected, ignoreCase = true) }
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
