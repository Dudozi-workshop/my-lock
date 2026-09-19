package com.mylock.app.my_lock

import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class LockActivity : FlutterActivity() {
    companion object {
        private const val channelName = "com.mylock.app/lock"
        private const val preferencesName = "my_lock_native"
        private const val targetAppExtra = "lock_target_app"
        const val deviceScreenAppId = "__device_screen__"

        @Volatile
        var lockUiVisible: Boolean = false

        fun launch(context: Context, appId: String): Boolean {
            if (appId.isBlank()) return false
            if (lockUiVisible) return true

            lockUiVisible = true
            val intent = Intent(context, LockActivity::class.java).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_NO_ANIMATION,
                )
                putExtra(targetAppExtra, appId)
            }

            return runCatching {
                context.startActivity(intent)
                true
            }.getOrElse {
                lockUiVisible = false
                false
            }
        }
    }

    private var targetAppId: String? = null

    override fun getDartEntrypointFunctionName(): String = "lockMain"

    override fun onCreate(savedInstanceState: Bundle?) {
        targetAppId = intent?.getStringExtra(targetAppExtra)
        if (targetAppId == deviceScreenAppId) {
            setShowWhenLocked(true)
        }
        lockUiVisible = true
        super.onCreate(savedInstanceState)

        @Suppress("DEPRECATION")
        overridePendingTransition(0, 0)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getLockTarget" -> {
                    result.success(targetAppId)
                }

                "unlockGranted" -> {
                    val appId = call.argument<String>("appId") ?: targetAppId
                    if (appId.isNullOrBlank()) {
                        result.error(
                            "invalid_lock_target",
                            "A lock target is required.",
                            null,
                        )
                    } else {
                        completeUnlock(appId)
                        result.success(null)
                    }
                }

                "dismissLock" -> {
                    dismissLock()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onStop() {
        if (!isChangingConfigurations && lockUiVisible) {
            lockUiVisible = false
            LockMonitorService.resetForegroundTracking()
        }
        super.onStop()
    }

    override fun onDestroy() {
        lockUiVisible = false
        super.onDestroy()
    }

    private fun completeUnlock(appId: String) {
        getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .edit()
            .putString("last_unlocked_app", appId)
            .putLong("last_unlocked_at", System.currentTimeMillis())
            .apply()

        if (appId == deviceScreenAppId) {
            setShowWhenLocked(false)
        }

        MainActivity.emitLockActivityUnlocked(appId)
        lockUiVisible = false
        finishLockActivity()
    }

    private fun dismissLock() {
        if (targetAppId == deviceScreenAppId) {
            setShowWhenLocked(false)
        }
        lockUiVisible = false
        finishLockActivity()
    }

    private fun finishLockActivity() {
        finishAndRemoveTask()
        @Suppress("DEPRECATION")
        overridePendingTransition(0, 0)
    }
}
