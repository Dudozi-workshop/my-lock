package com.dudoziworkshop.mylock

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.provider.Settings
import android.view.Gravity
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import android.widget.FrameLayout
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
    private const val channelName = "com.dudoziworkshop.mylock/lock"
    private const val preferencesName = "my_lock_native"

    private var windowManager: WindowManager? = null
    private var overlayView: MonitoredFlutterView? = null
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
        forceRecreate: Boolean = false,
    ): Boolean {
        if (!Settings.canDrawOverlays(context)) return false
        if (
            !forceRecreate &&
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
            // Block the protected app immediately. Flutter engine startup can take
            // noticeably longer than adding a native overlay window, so waiting for
            // Flutter before attaching anything leaves a brief tap-through / reveal
            // window. Keep an existing lock overlay in place during replacements;
            // otherwise attach an opaque native blocker first.
            val blocker = if (!isVisible) {
                FrameLayout(appContext).apply {
                    background = buildOverlayBackground(appContext)
                    isClickable = true
                    isFocusable = true
                    setOnTouchListener { _, _ -> true }
                    manager.addView(this, createOverlayLayoutParams())
                    applyImmersiveSystemUi(this)
                }
            } else {
                null
            }

            try {
                val engine = createFlutterEngine(appContext, appId, demoMode)
                val view = MonitoredFlutterView(
                appContext,
                onInterrupted = { interruptedView ->
                    if (
                        !demoMode &&
                        overlayView === interruptedView &&
                        targetAppId == appId
                    ) {
                        LockMonitorService.notifyOverlayInterrupted(appId)
                    }
                },
                onRecovered = { recoveredView ->
                    if (
                        !demoMode &&
                        overlayView === recoveredView &&
                        targetAppId == appId
                    ) {
                        LockMonitorService.notifyOverlayRecovered(appId)
                    }
                },
            ).apply {
                background = buildOverlayBackground(appContext)
                attachToFlutterEngine(engine)
            }

                val params = createOverlayLayoutParams()

                val previousManager = windowManager
            val previousView = overlayView
            val previousEngine = flutterEngine

                manager.addView(view, params)
                applyImmersiveSystemUi(view)

                windowManager = manager
                overlayView = view
                flutterEngine = engine
                targetAppId = appId
                currentDemoMode = demoMode
                engine.lifecycleChannel.appIsResumed()

                if (previousManager != null && previousView != null) {
                    previousView.suppressMonitoring()
                    runCatching { previousManager.removeViewImmediate(previousView) }
                    runCatching { previousView.detachFromFlutterEngine() }
                }
                if (previousEngine != null) {
                    runCatching { previousEngine.lifecycleChannel.appIsDetached() }
                    runCatching { previousEngine.destroy() }
                }

                if (blocker != null) {
                    runCatching { manager.removeViewImmediate(blocker) }
                }
                true
            } catch (error: Throwable) {
                if (blocker != null) {
                    // Never reveal the protected app because Flutter lock UI
                    // failed to initialize. Move the user to Home first, keep
                    // the opaque blocker briefly while that transition settles,
                    // then release the emergency window.
                    exitToHome(appContext, appId)
                    blocker.postDelayed(
                        {
                            runCatching {
                                if (blocker.isAttachedToWindow) {
                                    manager.removeViewImmediate(blocker)
                                }
                            }
                        },
                        250L,
                    )
                }
                throw error
            }
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

        if (view != null) {
            view.suppressMonitoring()
        }
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

    private fun createOverlayLayoutParams(): WindowManager.LayoutParams {
        return WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            },
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
                WindowManager.LayoutParams.FLAG_FULLSCREEN,
            PixelFormat.OPAQUE,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                layoutInDisplayCutoutMode =
                    WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
        }
    }

    private fun applyImmersiveSystemUi(view: View) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            view.windowInsetsController?.let { controller ->
                controller.hide(
                    WindowInsets.Type.statusBars() or
                        WindowInsets.Type.navigationBars(),
                )
                controller.systemBarsBehavior =
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
            return
        }

        @Suppress("DEPRECATION")
        view.systemUiVisibility =
            View.SYSTEM_UI_FLAG_FULLSCREEN or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
    }

    private fun buildOverlayBackground(context: Context): GradientDrawable {
        val background = context.getSharedPreferences(
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


private class MonitoredFlutterView(
    context: Context,
    private val onInterrupted: (MonitoredFlutterView) -> Unit,
    private val onRecovered: (MonitoredFlutterView) -> Unit,
) : FlutterView(context) {
    private var monitoringEnabled = true
    private var interrupted = false

    fun suppressMonitoring() {
        monitoringEnabled = false
        interrupted = false
    }

    override fun onWindowFocusChanged(hasWindowFocus: Boolean) {
        super.onWindowFocusChanged(hasWindowFocus)
        if (!monitoringEnabled || !isAttachedToWindow) return

        if (hasWindowFocus) {
            restoreImmersiveSystemUi()
        }

        if (!hasWindowFocus) {
            reportInterrupted()
        } else {
            reportRecovered()
        }
    }

    override fun onWindowVisibilityChanged(visibility: Int) {
        super.onWindowVisibilityChanged(visibility)
        if (!monitoringEnabled || !isAttachedToWindow) return

        if (visibility != View.VISIBLE) {
            reportInterrupted()
        } else {
            reportRecovered()
        }
    }

    override fun onDetachedFromWindow() {
        val shouldReport = monitoringEnabled
        if (shouldReport) {
            reportInterrupted()
        }
        super.onDetachedFromWindow()
    }

    private fun restoreImmersiveSystemUi() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            windowInsetsController?.let { controller ->
                controller.hide(
                    WindowInsets.Type.statusBars() or
                        WindowInsets.Type.navigationBars(),
                )
                controller.systemBarsBehavior =
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
            return
        }

        @Suppress("DEPRECATION")
        systemUiVisibility =
            View.SYSTEM_UI_FLAG_FULLSCREEN or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
    }

    private fun reportInterrupted() {
        if (interrupted) return
        interrupted = true
        onInterrupted(this)
    }

    private fun reportRecovered() {
        if (!interrupted) return
        interrupted = false
        onRecovered(this)
    }
}
