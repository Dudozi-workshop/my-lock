package com.mylock.app.my_lock

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
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
                        Intent.FLAG_ACTIVITY_NO_ANIMATION or
                        Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS or
                        Intent.FLAG_ACTIVITY_NO_HISTORY,
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
        window.setBackgroundDrawable(buildImmediateBlockBackground())
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
        if (!isChangingConfigurations) {
            if (lockUiVisible) {
                lockUiVisible = false
                LockMonitorService.resetForegroundTracking()
            }
            if (!isFinishing) {
                finishAndRemoveTask()
            }
        }
        super.onStop()
    }

    override fun onDestroy() {
        lockUiVisible = false
        super.onDestroy()
    }

    private fun buildImmediateBlockBackground(): GradientDrawable {
        val background = getSharedPreferences(
            preferencesName,
            Context.MODE_PRIVATE,
        ).getString("lock_background", "softGradient")

        val colors = when (background) {
            "basicLight" -> intArrayOf(
                Color.parseColor("#FFFFFFFF"),
                Color.parseColor("#FFF4F3F8"),
            )
            "basicDark" -> intArrayOf(
                Color.parseColor("#FF17151F"),
                Color.parseColor("#FF302A46"),
            )
            "galaxy" -> intArrayOf(
                Color.parseColor("#FF1B1640"),
                Color.parseColor("#FF5F43C7"),
                Color.parseColor("#FFB675D8"),
            )
            "ocean" -> intArrayOf(
                Color.parseColor("#FFBDEBFF"),
                Color.parseColor("#FF5DA9E9"),
                Color.parseColor("#FF3566C8"),
            )
            "aurora" -> intArrayOf(
                Color.parseColor("#FFBDFBE8"),
                Color.parseColor("#FF86B6FF"),
                Color.parseColor("#FFD6A7FF"),
            )
            else -> intArrayOf(
                Color.parseColor("#FFFFF3FB"),
                Color.parseColor("#FFF3F0FF"),
                Color.parseColor("#FFEAF5FF"),
            )
        }

        return GradientDrawable(
            GradientDrawable.Orientation.TL_BR,
            colors,
        )
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
