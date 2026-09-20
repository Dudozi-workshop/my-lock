package com.mylock.app.my_lock

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import java.security.MessageDigest
import android.provider.Settings
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.GridLayout

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

        val preferences =
            context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
        val patternLength = preferences.getInt("lock_pattern_length", 0)
        val patternHash = preferences.getString("lock_pattern_hash", null)
        val shapes = preferences.getStringSet(
            "lock_pattern_shapes",
            setOf("circle", "triangle", "square"),
        ).orEmpty()
        val tones = preferences.getStringSet(
            "lock_pattern_tones",
            setOf("pink", "blue", "yellow"),
        ).orEmpty()
        val input = mutableListOf<String>()

        val root = FrameLayout(context).apply {
            setPadding(dp(20), dp(20), dp(20), dp(20))
            background = buildBackground(context)
            isClickable = true
            isFocusable = true
        }

        val centerContent = LinearLayout(context).apply {
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
            text = if (patternLength > 0 && patternHash != null) {
                "설정한 순서대로 도형을 눌러주세요."
            } else {
                "비밀번호 설정이 필요합니다."
            }
            setTextColor(Color.parseColor("#FF6D647A"))
            textSize = 14f
            gravity = Gravity.CENTER
            setPadding(0, dp(12), 0, dp(12))
        }

        val progress = TextView(context).apply {
            text = if (patternLength > 0) "0 / $patternLength" else ""
            setTextColor(Color.parseColor("#FF6D647A"))
            textSize = 13f
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dp(20))
        }

        val grid = GridLayout(context).apply {
            columnCount = 3
            rowCount = 3
            alignmentMode = GridLayout.ALIGN_BOUNDS
            useDefaultMargins = true
        }

        fun resetInput(message: String? = null) {
            input.clear()
            progress.text = if (patternLength > 0) "0 / $patternLength" else ""
            if (message != null) subtitle.text = message
        }

        fun handleToken(tokenId: String) {
            if (patternLength <= 0 || patternHash == null) return
            if (input.size >= patternLength) return

            input.add(tokenId)
            progress.text = "${input.size} / $patternLength"
            if (input.size < patternLength) return

            if (hashPattern(input) == patternHash) {
                markUnlocked(context, appId)
                hide()
            } else {
                resetInput("일치하지 않습니다. 다시 입력하세요.")
            }
        }

        for (tone in listOf("pink", "blue", "yellow")) {
            if (!tones.contains(tone)) continue
            for (shape in listOf("circle", "triangle", "square")) {
                if (!shapes.contains(shape)) continue
                val tokenId = "${tone}_${shape}"
                val tokenView = TextView(context).apply {
                    text = shapeSymbol(shape)
                    textSize = 32f
                    gravity = Gravity.CENTER
                    setTextColor(toneColor(tone))
                    background = GradientDrawable().apply {
                        shape = GradientDrawable.RECTANGLE
                        cornerRadius = dp(18).toFloat()
                        setColor(Color.parseColor("#F7F5FA"))
                        setStroke(dp(1), Color.parseColor("#E3DFEA"))
                    }
                    isClickable = true
                    isFocusable = true
                    setOnClickListener { handleToken(tokenId) }
                }
                grid.addView(
                    tokenView,
                    GridLayout.LayoutParams().apply {
                        width = dp(82)
                        height = dp(82)
                        setMargins(dp(4), dp(4), dp(4), dp(4))
                    },
                )
            }
        }

        val clearButton = Button(context).apply {
            text = "다시 입력"
            textSize = 14f
            isEnabled = patternLength > 0
            setOnClickListener { resetInput("설정한 순서대로 도형을 눌러주세요.") }
        }

        val closeButton = TextView(context).apply {
            text = "×"
            setTextColor(Color.parseColor("#FF2A2238"))
            textSize = 32f
            gravity = Gravity.CENTER
            isClickable = true
            isFocusable = true
            setOnClickListener {
                exitToHome(context, appId)
            }
        }

        centerContent.addView(title)
        centerContent.addView(subtitle)
        centerContent.addView(progress)
        centerContent.addView(grid)
        centerContent.addView(
            clearButton,
            LinearLayout.LayoutParams(dp(180), dp(52)).apply {
                topMargin = dp(20)
            },
        )

        root.addView(
            centerContent,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.CENTER,
            ),
        )
        root.addView(
            closeButton,
            FrameLayout.LayoutParams(dp(56), dp(56), Gravity.TOP or Gravity.END),
        )
        return root
    }

    private fun hashPattern(tokenIds: List<String>): String {
        val payload = tokenIds.joinToString(separator = "|")
        return MessageDigest.getInstance("SHA-256")
            .digest(payload.toByteArray(Charsets.UTF_8))
            .joinToString(separator = "") { byte -> "%02x".format(byte) }
    }

    private fun shapeSymbol(shape: String): String = when (shape) {
        "triangle" -> "▲"
        "square" -> "■"
        else -> "●"
    }

    private fun toneColor(tone: String): Int = when (tone) {
        "blue" -> Color.parseColor("#3F6FEA")
        "yellow" -> Color.parseColor("#F0A632")
        else -> Color.parseColor("#E656AB")
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
