package com.mylock.app.my_lock

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.util.Base64
import java.io.ByteArrayOutputStream
import java.security.MessageDigest
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
                            "overlayGranted" to Settings.canDrawOverlays(this),
                            "monitorServiceRunning" to isMonitorServiceRunning(),
                        ),
                    )
                }

                "openUsageAccessSettings" -> {
                    openUsageAccessSettings()
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

                "syncExperimentalOverlayLock" -> {
                    val enabled = call.argument<Boolean>("enabled") == true
                    getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
                        .edit()
                        .putBoolean("experimental_overlay_lock", enabled)
                        .apply()
                    if (!enabled) {
                        OverlayLockController.hide()
                    }
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

                "syncLockPattern" -> {
                    val tokenIds = call.argument<List<String>>("tokenIds").orEmpty()
                    val shapes = call.argument<List<String>>("shapes").orEmpty()
                    val tones = call.argument<List<String>>("tones").orEmpty()
                    val preferences =
                        getSharedPreferences(preferencesName, Context.MODE_PRIVATE)

                    if (tokenIds.isEmpty()) {
                        preferences.edit()
                            .remove("lock_pattern_hash")
                            .remove("lock_pattern_length")
                            .remove("lock_pattern_required_tokens")
                            .putStringSet("lock_pattern_shapes", shapes.toSet())
                            .putStringSet("lock_pattern_tones", tones.toSet())
                            .apply()
                    } else {
                        preferences.edit()
                            .putString("lock_pattern_hash", hashPattern(tokenIds))
                            .putInt("lock_pattern_length", tokenIds.size)
                            .putStringSet("lock_pattern_required_tokens", tokenIds.toSet())
                            .putStringSet("lock_pattern_shapes", shapes.toSet())
                            .putStringSet("lock_pattern_tones", tones.toSet())
                            .apply()
                    }
                    result.success(null)
                }

                "syncLockPresentation" -> {
                    val objectCount = call.argument<Int>("objectCount") ?: 9
                    val speed = call.argument<String>("speed") ?: "normal"
                    val movementArea =
                        call.argument<String>("movementArea") ?: "full"
                    val movementStyle =
                        call.argument<String>("movementStyle") ?: "floating"
                    getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
                        .edit()
                        .putInt("lock_object_count", objectCount)
                        .putString("lock_speed", speed)
                        .putString("lock_movement_area", movementArea)
                        .putString("lock_movement_style", movementStyle)
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

    private fun hashPattern(tokenIds: List<String>): String {
        val payload = tokenIds.joinToString(separator = "|")
        return MessageDigest.getInstance("SHA-256")
            .digest(payload.toByteArray(Charsets.UTF_8))
            .joinToString(separator = "") { byte -> "%02x".format(byte) }
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

    private fun loadLockableApps(): List<Map<String, String>> {
        val launcherIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }

        val launchableActivities =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.queryIntentActivities(
                    launcherIntent,
                    PackageManager.ResolveInfoFlags.of(PackageManager.MATCH_ALL.toLong()),
                )
            } else {
                @Suppress("DEPRECATION")
                packageManager.queryIntentActivities(
                    launcherIntent,
                    PackageManager.MATCH_ALL,
                )
            }

        return launchableActivities
            .asSequence()
            .filter { it.activityInfo?.applicationInfo?.enabled == true }
            .filter { it.activityInfo?.packageName != packageName }
            .mapNotNull { resolveInfo ->
                val activityInfo = resolveInfo.activityInfo ?: return@mapNotNull null
                val packageId = activityInfo.packageName
                val name = runCatching {
                    resolveInfo.loadLabel(packageManager).toString()
                }.getOrNull()?.takeIf { it.isNotBlank() } ?: return@mapNotNull null

                val icon = runCatching {
                    encodeDrawableToBase64(resolveInfo.loadIcon(packageManager))
                }.getOrNull()

                buildMap<String, String> {
                    put("id", packageId)
                    put("name", name)
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

        val scaled = Bitmap.createScaledBitmap(bitmap, 72, 72, true)
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
