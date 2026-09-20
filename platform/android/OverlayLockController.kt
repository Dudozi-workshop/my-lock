package com.mylock.app.my_lock

import android.content.Context
import android.content.Intent
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PixelFormat
import android.graphics.RadialGradient
import android.graphics.Shader
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
        val patternSequence =
            preferences.getString("lock_pattern_sequence", "")
                .orEmpty()
                .split("|")
                .filter { it.isNotBlank() }
        val speedName = preferences.getString("lock_speed", "normal") ?: "normal"
        val movementArea =
            preferences.getString("lock_movement_area", "full") ?: "full"
        val movementStyle =
            preferences.getString("lock_movement_style", "floating") ?: "floating"
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

        val random = Random(SystemClock.uptimeMillis())
        val tokenIds = MutableList(objectCount) { index ->
            allowedTokens[index % allowedTokens.size]
        }.also { it.shuffle(random) }
        val moving = mutableListOf<MovingToken>()

        fun ensureNextPasswordTokens() {
            if (patternSequence.isEmpty() || moving.isEmpty()) return

            val upcoming = patternSequence
                .drop(input.size)
                .take(2)
            if (upcoming.isEmpty()) return

            val desiredCounts = upcoming
                .groupingBy { it }
                .eachCount()
            val visibleCounts = moving
                .filter { it.view.alpha > 0.05f }
                .groupingBy { it.tokenId }
                .eachCount()
                .toMutableMap()

            for ((requiredId, requiredCount) in desiredCounts) {
                while ((visibleCounts[requiredId] ?: 0) < requiredCount) {
                    val replacement = moving
                        .filter { candidate ->
                            candidate.tokenId != requiredId &&
                                (visibleCounts[candidate.tokenId] ?: 0) >
                                    (desiredCounts[candidate.tokenId] ?: 0)
                        }
                        .firstOrNull()
                        ?: moving.firstOrNull { it.tokenId != requiredId }
                        ?: break

                    val oldId = replacement.tokenId
                    visibleCounts[oldId] =
                        ((visibleCounts[oldId] ?: 1) - 1).coerceAtLeast(0)
                    replacement.tokenId = requiredId
                    replacement.view.setToken(requiredId)
                    replacement.view.alpha = 1f
                    replacement.view.scaleX = 1f
                    replacement.view.scaleY = 1f
                    visibleCounts[requiredId] =
                        (visibleCounts[requiredId] ?: 0) + 1
                }
            }
        }

        fun resetInput(message: String) {
            input.clear()
            progress.text =
                if (patternLength > 0) progressDots(0, patternLength) else ""
            subtitle.text = message
            ensureNextPasswordTokens()
        }

        fun handleToken(tokenId: String, view: View) {
            if (
                patternLength <= 0 ||
                patternHash == null ||
                input.size >= patternLength
            ) return

            view.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
            view.animate()
                .scaleX(1.28f)
                .scaleY(1.28f)
                .alpha(0f)
                .setDuration(160L)
                .withEndAction {
                    view.scaleX = 1f
                    view.scaleY = 1f
                    view.alpha = 1f
                }
                .start()

            input.add(tokenId)
            progress.text = progressDots(input.size, patternLength)

            if (input.size < patternLength) {
                ensureNextPasswordTokens()
                return
            }

            if (hashPattern(input) == patternHash) {
                markUnlocked(context, appId)
                hide()
            } else {
                resetInput("순서가 달라요. 처음부터 다시 눌러주세요.")
            }
        }

        val handler = Handler(Looper.getMainLooper())
        var lastFrame = SystemClock.uptimeMillis()

        root.addView(
            playfield,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )
        playfield.setOnTouchListener { _, event ->
            if (event.action != android.view.MotionEvent.ACTION_DOWN) {
                return@setOnTouchListener true
            }

            var closest: MovingToken? = null
            var closestDistanceSquared = Float.MAX_VALUE
            for (token in moving) {
                val dx = event.x - token.x
                val dy = event.y - token.y
                val distanceSquared = dx * dx + dy * dy
                val maxDistance = token.radius
                if (
                    distanceSquared <= maxDistance * maxDistance &&
                    distanceSquared < closestDistanceSquared
                ) {
                    closest = token
                    closestDistanceSquared = distanceSquared
                }
            }

            closest?.let { token ->
                handleToken(token.tokenId, token.view)
            }
            true
        }

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
                val view = FloatingTokenView(context, shape, tone).apply {
                    isClickable = false
                    isFocusable = false
                }
                val size = (radius * 2).toInt()
                val x = radius + random.nextFloat() * (width - radius * 2).coerceAtLeast(1f)
                val y = top + radius +
                    random.nextFloat() * (height - top - radius * 2).coerceAtLeast(1f)
                val angle = random.nextFloat() * Math.PI.toFloat() * 2f
                val styleMultiplier = if (movementStyle == "bounce") 1.32f else 1f
                val baseSpeed =
                    minOf(width, height) * 0.10f * speedMultiplier * styleMultiplier
                val token = MovingToken(
                    tokenId = tokenId,
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
            ensureNextPasswordTokens()

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
                    }

                    for (i in 0 until moving.size) {
                        for (j in i + 1 until moving.size) {
                            val first = moving[i]
                            val second = moving[j]
                            val dx = second.x - first.x
                            val dy = second.y - first.y
                            val minDistance = (first.radius + second.radius) * 0.92f
                            val distanceSquared = dx * dx + dy * dy
                            if (distanceSquared <= 0.01f || distanceSquared >= minDistance * minDistance) continue

                            val distance = kotlin.math.sqrt(distanceSquared)
                            val nx = dx / distance
                            val ny = dy / distance
                            val overlap = minDistance - distance
                            first.x -= nx * overlap * 0.5f
                            first.y -= ny * overlap * 0.5f
                            second.x += nx * overlap * 0.5f
                            second.y += ny * overlap * 0.5f

                            val firstNormal = first.vx * nx + first.vy * ny
                            val secondNormal = second.vx * nx + second.vy * ny
                            val impulse = secondNormal - firstNormal
                            first.vx += impulse * nx
                            first.vy += impulse * ny
                            second.vx -= impulse * nx
                            second.vy -= impulse * ny
                        }
                    }

                    for (token in moving) {
                        token.x = token.x.coerceIn(token.radius, width - token.radius)
                        token.y = token.y.coerceIn(top + token.radius, height - token.radius)
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
        var tokenId: String,
        val view: View,
        var x: Float,
        var y: Float,
        var vx: Float,
        var vy: Float,
        val radius: Float,
    )

    private class FloatingTokenView(
        context: Context,
        private var tokenShape: String,
        private var tone: String,
    ) : View(context) {
        private val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        private val borderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            color = Color.argb(158, 255, 255, 255)
        }
        private val highlightPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(107, 255, 255, 255)
        }

        fun setToken(tokenId: String) {
            val parts = tokenId.split("_", limit = 2)
            tone = parts.firstOrNull() ?: "pink"
            tokenShape = parts.getOrNull(1) ?: "circle"
            invalidate()
        }

        override fun onDraw(canvas: Canvas) {
            super.onDraw(canvas)
            val cx = width / 2f
            val cy = height / 2f
            val radius = minOf(width, height) * 0.38f
            val path = tokenPath(tokenShape, cx, cy, radius)
            val (light, dark) = toneColors(tone)

            setLayerType(LAYER_TYPE_SOFTWARE, null)
            fillPaint.setShadowLayer(radius * 0.18f, 0f, radius * 0.08f, Color.argb(66, Color.red(dark), Color.green(dark), Color.blue(dark)))
            fillPaint.shader = RadialGradient(
                cx - radius * 0.45f,
                cy - radius * 0.55f,
                radius * 1.25f,
                intArrayOf(Color.WHITE, light, dark),
                floatArrayOf(0f, 0.35f, 1f),
                Shader.TileMode.CLAMP,
            )
            canvas.drawPath(path, fillPaint)

            fillPaint.clearShadowLayer()
            borderPaint.strokeWidth = maxOf(1.2f, radius * 0.035f)
            canvas.drawPath(path, borderPaint)
            canvas.drawOval(
                cx - radius * 0.52f,
                cy - radius * 0.40f,
                cx,
                cy - radius * 0.16f,
                highlightPaint,
            )
        }

        private fun tokenPath(shape: String, cx: Float, cy: Float, radius: Float): Path {
            return when (shape) {
                "triangle" -> Path().apply {
                    for (i in 0..2) {
                        val angle = -Math.PI / 2 + i * Math.PI * 2 / 3
                        val x = cx + cos(angle).toFloat() * radius
                        val y = cy + sin(angle).toFloat() * radius
                        if (i == 0) moveTo(x, y) else lineTo(x, y)
                    }
                    close()
                }
                "square" -> Path().apply {
                    val half = radius * 0.79f
                    addRoundRect(
                        cx - half,
                        cy - half,
                        cx + half,
                        cy + half,
                        radius * 0.32f,
                        radius * 0.32f,
                        Path.Direction.CW,
                    )
                }
                else -> Path().apply {
                    addCircle(cx, cy, radius, Path.Direction.CW)
                }
            }
        }

        private fun toneColors(tone: String): Pair<Int, Int> = when (tone) {
            "blue" -> Color.parseColor("#79BFFF") to Color.parseColor("#3F6FEA")
            "yellow" -> Color.parseColor("#FFDA72") to Color.parseColor("#F0A632")
            else -> Color.parseColor("#FF8FD1") to Color.parseColor("#E656AB")
        }
    }

    private fun progressDots(progress: Int, total: Int): String =
        List(total) { index -> if (index < progress) "●" else "○" }
            .joinToString(separator = "  ")

    private fun hashPattern(tokenIds: List<String>): String {
        val payload = tokenIds.joinToString(separator = "|")
        return MessageDigest.getInstance("SHA-256")
            .digest(payload.toByteArray(Charsets.UTF_8))
            .joinToString(separator = "") { byte -> "%02x".format(byte) }
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
