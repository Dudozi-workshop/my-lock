package com.mylock.app.my_lock

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.provider.Settings
import android.view.Gravity
import android.view.WindowManager
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Owns only the Android system-overlay window.
 *
 * The lock UI itself is rendered by Flutter through lockMain(), so Customize,
 * in-app lock, preview, and the real Android overlay share the exact same
 * LockModeScreen / FloatingPreview / painters / animation engine.
 */
object OverlayLockController {
    private const val channelName = "com.mylock.app/lock"
    private const val preferencesName = "my_lock_native"

    private var windowManager: WindowManager? = null
    private var overlayView: FlutterView? = null
    private var flutterEngine: FlutterEngine? = null
    private var targetAppId: String? = null
    private var currentDemoMode: Boolean = false

    val isVisible: Boolean
        get() = overlayView?.isAttachedToWindow == true

    fun currentTarget(): String? = targetAppId

    fun show(
        context: Context,
        appId: String,
        demoMode: Boolean = false,
    ): Boolean {
        if (!Settings.canDrawOverlays(context)) return false
        if (
            isVisible &&
            targetAppId == appId &&
            currentDemoMode == demoMode
        ) {
            return true
        }

        if (overlayView != null && !isVisible) {
            hide()
        }

        val appContext = context.applicationContext
        val manager =
            appContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager

        return runCatching {
            val engine = createFlutterEngine(appContext, appId, demoMode)
            val view = FlutterView(appContext).apply {
                setBackgroundColor(Color.TRANSPARENT)
                attachToFlutterEngine(engine)
            }

            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                } else {
                    @Suppress("DEPRECATION")
                    WindowManager.LayoutParams.TYPE_PHONE
                },
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = Gravity.TOP or Gravity.START
            }

            val previousManager = windowManager
            val previousView = overlayView
            val previousEngine = flutterEngine

            manager.addView(view, params)

            windowManager = manager
            overlayView = view
            flutterEngine = engine
            targetAppId = appId
            currentDemoMode = demoMode
            engine.lifecycleChannel.appIsResumed()

            if (previousManager != null && previousView != null) {
                runCatching { previousManager.removeViewImmediate(previousView) }
                runCatching { previousView.detachFromFlutterEngine() }
            }
            if (previousEngine != null) {
                runCatching { previousEngine.lifecycleChannel.appIsDetached() }
                runCatching { previousEngine.destroy() }
            }
            true
        }.getOrElse {
            false
        }
    }

    fun hide() {
        val manager = windowManager
        val view = overlayView
        val engine = flutterEngine

        windowManager = null
        overlayView = null
        flutterEngine = null
        targetAppId = null
        currentDemoMode = false

        if (manager != null && view != null) {
            runCatching { manager.removeViewImmediate(view) }
        }
        if (view != null) {
            runCatching { view.detachFromFlutterEngine() }
        }
        if (engine != null) {
            runCatching { engine.lifecycleChannel.appIsDetached() }
            runCatching { engine.destroy() }
        }
    }

    private fun createFlutterEngine(
        context: Context,
        appId: String,
        demoMode: Boolean,
    ): FlutterEngine {
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(context)
        loader.ensureInitializationComplete(context, null)

        val engine = FlutterEngine(context)

        MethodChannel(
            engine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getLockTarget" -> result.success(appId)
                "getLockDemoMode" -> result.success(demoMode)

                "unlockGranted" -> {
                    val requestedAppId = call.argument<String>("appId") ?: appId
                    if (requestedAppId.isBlank()) {
                        result.error(
                            "invalid_lock_target",
                            "A lock target is required.",
                            null,
                        )
                    } else {
                        if (!demoMode) {
                            markUnlocked(context, requestedAppId)
                        }
                        result.success(null)
                        hide()
                    }
                }

                "openAppRecovery" -> {
                    result.success(null)
                    openMyLockRecovery(context)
                }

                "dismissLock" -> {
                    result.success(null)
                    if (demoMode) {
                        hide()
                    } else {
                        exitToHome(context, appId)
                    }
                }

                else -> result.notImplemented()
            }
        }

        val entrypoint = DartExecutor.DartEntrypoint(
            loader.findAppBundlePath(),
            "lockMain",
        )
        engine.dartExecutor.executeDartEntrypoint(entrypoint)
        return engine
    }

    private fun openMyLockRecovery(context: Context) {
        hide()
        LockMonitorService.resetForegroundTracking()

        val launchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
            ?.apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP,
                )
            }
        if (launchIntent != null) {
            runCatching { context.startActivity(launchIntent) }
        }
    }

    private fun exitToHome(context: Context, appId: String) {
        forceRelock(context, appId)
        hide()
        LockMonitorService.resetForegroundTracking()

        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        runCatching { context.startActivity(homeIntent) }
    }

    private fun forceRelock(context: Context, appId: String) {
        val preferences =
            context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
        if (preferences.getString("last_unlocked_app", null) == appId) {
            preferences.edit()
                .remove("last_unlocked_app")
                .remove("last_unlocked_at")
                .apply()
        }
    }

    private fun markUnlocked(context: Context, appId: String) {
        context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .edit()
            .putString("last_unlocked_app", appId)
            .putLong("last_unlocked_at", System.currentTimeMillis())
            .apply()
        MainActivity.emitLockActivityUnlocked(appId)
    }
}
