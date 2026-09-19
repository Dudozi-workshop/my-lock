package com.mylock.app.my_lock

import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.provider.Settings
import android.content.Intent
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView

object OverlayLockController {
    private const val preferencesName = "my_lock_native"

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var targetAppId: String? = null

    val isVisible: Boolean
        get() = overlayView != null

    fun currentTarget(): String? = targetAppId

    fun show(context: Context, appId: String): Boolean {
        if (!Settings.canDrawOverlays(context)) return false
        if (isVisible && targetAppId == appId) return true

        hide()

        val appContext = context.applicationContext
        val manager =
            appContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val root = buildView(appContext, appId)

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

        return runCatching {
            manager.addView(root, params)
            windowManager = manager
            overlayView = root
            targetAppId = appId
            true
        }.getOrElse {
            windowManager = null
            overlayView = null
            targetAppId = null
            false
        }
    }

    fun hide() {
        val manager = windowManager
        val view = overlayView

        overlayView = null
        targetAppId = null
        windowManager = null

        if (manager != null && view != null) {
            runCatching { manager.removeViewImmediate(view) }
        }
    }

    private fun buildView(context: Context, appId: String): View {
        val density = context.resources.displayMetrics.density
        fun dp(value: Int): Int = (value * density).toInt()

        val root = FrameLayout(context).apply {
            setPadding(dp(20), dp(20), dp(20), dp(20))
            background = buildBackground(context)
            isClickable = true
            isFocusable = true
            isFocusableInTouchMode = true
            setOnKeyListener { _, keyCode, _ ->
                keyCode == KeyEvent.KEYCODE_BACK
            }
        }

        val content = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
        }

        val title = TextView(context).apply {
            text = "MY LOCK"
            setTextColor(Color.parseColor("#FF2A2238"))
            textSize = 28f
            gravity = Gravity.CENTER
            setTypeface(typeface, android.graphics.Typeface.BOLD)
        }

        val subtitle = TextView(context).apply {
            text = "Overlay Test\n홈·최근 앱을 시도해도 잠금은 유지됩니다."
            setTextColor(Color.parseColor("#FF6D647A"))
            textSize = 14f
            gravity = Gravity.CENTER
            setPadding(0, dp(12), 0, dp(28))
        }

        val unlockButton = Button(context).apply {
            text = "테스트 해제"
            textSize = 15f
            setOnClickListener {
                markUnlocked(context, appId)
                hide()
            }
        }

        content.addView(
            title,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ),
        )
        content.addView(
            subtitle,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ),
        )
        content.addView(
            unlockButton,
            LinearLayout.LayoutParams(
                dp(180),
                dp(52),
            ),
        )

        root.addView(
            content,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )

        val closeButton = TextView(context).apply {
            text = "✕"
            setTextColor(Color.parseColor("#FF2A2238"))
            textSize = 28f
            gravity = Gravity.CENTER
            isClickable = true
            setPadding(dp(12), dp(8), dp(12), dp(8))
            setOnClickListener {
                exitToHome(context, appId)
            }
        }

        root.addView(
            closeButton,
            FrameLayout.LayoutParams(
                dp(56),
                dp(56),
                Gravity.TOP or Gravity.END,
            ),
        )

        root.post {
            root.requestFocus()
        }

        return root
    }

    private fun exitToHome(context: Context, appId: String) {
        context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .edit()
            .remove("last_unlocked_app")
            .remove("last_unlocked_at")
            .putString("last_protected_exit_app", appId)
            .putLong("last_protected_exit_at", System.currentTimeMillis())
            .apply()

        hide()

        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        runCatching { context.startActivity(homeIntent) }
        LockMonitorService.resetForegroundTracking()
    }

    private fun markUnlocked(context: Context, appId: String) {
        context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .edit()
            .putString("last_unlocked_app", appId)
            .putLong("last_unlocked_at", System.currentTimeMillis())
            .apply()
        MainActivity.emitLockActivityUnlocked(appId)
    }

    private fun buildBackground(context: Context): GradientDrawable {
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
}
