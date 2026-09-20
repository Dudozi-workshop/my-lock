package com.mylock.app.my_lock

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.HapticFeedbackConstants
import kotlin.math.cos
import kotlin.math.sin
import kotlin.random.Random
import java.security.MessageDigest
import android.provider.Settings
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.WindowManager
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
        val objectCount =
            preferences.getInt("lock_object_count", 9).coerceIn(6, 12)
        val speedName = preferences.getString("lock_speed", "normal") ?: "normal"
        val movementArea =
            preferences.getString("lock_movement_area", "full") ?: "full"
        val speedMultiplier = when (speedName) {
            "slow" -> 0.65f
            "fast" -> 1.75f
            else -> 1.15f
        }
        val input = mutableListOf<String>()

        val root = FrameLayout(context).apply {
            background = buildBackground(context)
            isClickable = true
            isFocusable = true
        }
        val playfield = FrameLayout(context)

        val subtitle = TextView(context).apply {
            text = if (patternLength > 0 && patternHash != null) {
                "도형을 순서대로 눌러 잠금을 해제하세요."
            } else {
                "비밀번호 설정이 필요합니다."
            }
            setTextColor(Color.parseColor("#FF6D647A"))
            textSize = 12f
            gravity = Gravity.CENTER
        }
        val progress = TextView(context).apply {
            text = if (patternLength > 0) progressDots(0, patternLength) else ""
            setTextColor(Color.parseColor("#FF7658D6"))
            textSize = 18f
            gravity = Gravity.CENTER
        }
        val header = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dp(64), dp(24), dp(64), dp(12))
            addView(TextView(context).apply {
                text = "MY LOCK"
                setTextColor(Color.parseColor("#FF2A2238"))
                textSize = 17f
                gravity = Gravity.CENTER
                setTypeface(typeface, android.graphics.Typeface.BOLD)
            })
            addView(subtitle)
            addView(progress)
        }

        fun resetInput(message: String) {
            input.clear()
            progress.text = if (patternLength > 0) progressDots(0, patternLength) else ""
            subtitle.text = message
        }

        fun handleToken(tokenId: String, view: View) {
            if (patternLength <= 0 || patternHash == null || input.size >= patternLength) return
            view.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
            input.add(tokenId)
            progress.text = progressDots(input.size, patternLength)
            if (input.size < patternLength) return

            if (hashPattern(input) == patternHash) {
                markUnlocked(context, appId)
                hide()
            } else {
                resetInput("순서가 달라요. 처음부터 다시 눌러주세요.")
            }
        }

        val allowedTokens = buildList {
            for (tone in listOf("pink", "blue", "yellow")) {
                if (!tones.contains(tone)) continue
                for (shape in listOf("circle", "triangle", "square")) {
                    if (shapes.contains(shape)) add("${tone}_${shape}")
                }
            }
        }.ifEmpty {
            listOf("pink_circle", "blue_triangle", "yellow_square")
        }

        // The hash intentionally does not expose the original sequence. Cycle the
        // enabled token types so the playfield remains usable without storing plaintext.
        val tokenIds = MutableList(objectCount) { index ->
            allowedTokens[index % allowedTokens.size]
        }

        val random = Random(SystemClock.uptimeMillis())
        val moving = mutableListOf<MovingToken>()
        val handler = Handler(Looper.getMainLooper())
        var lastFrame = SystemClock.uptimeMillis()

        root.addView(
            playfield,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )
        root.addView(
            header,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                dp(120),
                Gravity.TOP,
            ),
        )

        root.post {
            val width = root.width.toFloat()
            val height = root.height.toFloat()
            val top = if (movementArea == "lower") height * 0.40f else dp(120).toFloat()
            val radius = (minOf(width, height) * 0.078f).coerceIn(dp(28).toFloat(), dp(40).toFloat())

            tokenIds.forEachIndexed { index, tokenId ->
                val parts = tokenId.split("_", limit = 2)
                val tone = parts.firstOrNull() ?: "pink"
                val shape = parts.getOrNull(1) ?: "circle"
                val view = TextView(context).apply {
                    text = shapeSymbol(shape)
                    textSize = 42f
                    gravity = Gravity.CENTER
                    setTextColor(toneColor(tone))
                    isClickable = true
                    isFocusable = true
                    setOnClickListener { handleToken(tokenId, this) }
                }
                val size = (radius * 2).toInt()
                val x = radius + random.nextFloat() * (width - radius * 2).coerceAtLeast(1f)
                val y = top + radius +
                    random.nextFloat() * (height - top - radius * 2).coerceAtLeast(1f)
                val angle = random.nextFloat() * Math.PI.toFloat() * 2f
                val baseSpeed = minOf(width, height) * 0.10f * speedMultiplier
                val token = MovingToken(
                    view = view,
                    x = x,
                    y = y,
                    vx = cos(angle) * baseSpeed,
                    vy = sin(angle) * baseSpeed,
                    radius = radius,
                )
                moving.add(token)
                playfield.addView(
                    view,
                    FrameLayout.LayoutParams(size, size).apply {
                        leftMargin = (x - radius).toInt()
                        topMargin = (y - radius).toInt()
                    },
                )
            }

            val frame = object : Runnable {
                override fun run() {
                    if (overlayView !== root) return
                    val now = SystemClock.uptimeMillis()
                    val dt = ((now - lastFrame) / 1000f).coerceIn(0f, 0.035f)
                    lastFrame = now

                    for (token in moving) {
                        token.x += token.vx * dt
                        token.y += token.vy * dt
                        if (token.x - token.radius <= 0f || token.x + token.radius >= width) {
                            token.vx = -token.vx
                            token.x = token.x.coerceIn(token.radius, width - token.radius)
                        }
                        if (token.y - token.radius <= top || token.y + token.radius >= height) {
                            token.vy = -token.vy
                            token.y = token.y.coerceIn(top + token.radius, height - token.radius)
                        }
                        token.view.translationX = token.x - token.radius -
                            (token.view.layoutParams as FrameLayout.LayoutParams).leftMargin
                        token.view.translationY = token.y - token.radius -
                            (token.view.layoutParams as FrameLayout.LayoutParams).topMargin
                    }
                    handler.postDelayed(this, 16L)
                }
            }
            handler.post(frame)
        }

        val closeButton = TextView(context).apply {
            text = "×"
            setTextColor(Color.parseColor("#FF2A2238"))
            textSize = 32f
            gravity = Gravity.CENTER
            isClickable = true
            isFocusable = true
            setOnClickListener { exitToHome(context, appId) }
        }
        root.addView(
            closeButton,
            FrameLayout.LayoutParams(dp(56), dp(56), Gravity.TOP or Gravity.END).apply {
                topMargin = dp(12)
                rightMargin = dp(10)
            },
        )
        return root
    }

    private data class MovingToken(
        val view: View,
        var x: Float,
        var y: Float,
        var vx: Float,
        var vy: Float,
        val radius: Float,
    )

    private fun progressDots(progress: Int, total: Int): String =
        List(total) { index -> if (index < progress) "●" else "○" }
            .joinToString(separator = "  ")

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
