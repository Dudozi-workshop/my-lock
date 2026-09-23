package com.dudoziworkshop.mylock

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings

class LockMonitorService : Service() {
    companion object {
        private const val channelId = "my_lock_monitor"
        private const val notificationId = 1201
        private const val pollIntervalMs = 150L
        private const val overlayExitConfirmMs = 300L
        private val transientSystemPackages = setOf(
            "com.android.systemui",
            "com.android.launcher",
            "com.google.android.apps.nexuslauncher",
            "com.sec.android.app.launcher",
        )
        private val protectedSessionSystemPackages = setOf(
            "com.android.documentsui",
            "com.google.android.documentsui",
            "com.android.providers.media",
            "com.android.providers.media.module",
            "com.google.android.providers.media.module",
        )
        private const val preferencesName = "my_lock_native"
        private const val protectedAppsKey = "protected_apps"
        private const val experimentalScreenLockKey = "experimental_screen_lock"
        private const val relockPolicyKey = "relock_policy"
        private const val lastUnlockedAppKey = "last_unlocked_app"
        private const val lastUnlockedAtKey = "last_unlocked_at"
        private const val lastProtectedExitAppKey = "last_protected_exit_app"
        private const val lastProtectedExitAtKey = "last_protected_exit_at"
        private const val lastScreenOffAtKey = "last_screen_off_at"
        const val heartbeatKey = "monitor_heartbeat_at"

        @Volatile
        private var activeInstance: LockMonitorService? = null

        fun resetForegroundTracking() {
            activeInstance?.resetForegroundState()
        }

        fun notifyOverlayInterrupted(appId: String) {
            activeInstance?.handleOverlayInterrupted(appId)
        }

        fun notifyOverlayRecovered(appId: String) {
            activeInstance?.handleOverlayRecovered(appId)
        }

        private const val heartbeatIntervalMs = 2_000L
    }

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var usageStatsManager: UsageStatsManager

    private var lastQueryAt = 0L
    private var lastHeartbeatAt = 0L
    private var foregroundPackage: String? = null
    private var pendingOverlayExitPackage: String? = null
    private var pendingOverlayExitAt = 0L
    private var pendingOverlayExitRunnable: Runnable? = null
    private var permissionsReady = true
    private var interruptedOverlayTarget: String? = null

    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                Intent.ACTION_SCREEN_OFF -> {
                    foregroundPackage = null
                    forceRelockCurrentSession()
                    getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
                        .edit()
                        .putLong(lastScreenOffAtKey, System.currentTimeMillis())
                        .apply()
                    MainActivity.emitScreenOff()
                }
                Intent.ACTION_SCREEN_ON -> {
                    foregroundPackage = null
                    lastQueryAt = System.currentTimeMillis() - 2_000L
                    if (experimentalScreenLockEnabled()) {
                        val delivered = MainActivity.emitScreenOn()
                        if (!delivered) {
                            launchScreenLockFallback()
                        }
                    }
                }
            }
        }
    }

    private val pollRunnable = object : Runnable {
        override fun run() {
            pollForegroundApp()
            handler.postDelayed(this, pollIntervalMs)
        }
    }

    override fun onCreate() {
        super.onCreate()
        activeInstance = this
        usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        createNotificationChannel()
        startAsForeground()

        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_SCREEN_ON)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(screenReceiver, filter, RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            registerReceiver(screenReceiver, filter)
        }

        lastQueryAt = System.currentTimeMillis() - 2_000L
        writeHeartbeat(force = true)
        handler.post(pollRunnable)
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        LockActivity.lockUiVisible = false
        super.onTaskRemoved(rootIntent)
    }

    override fun onDestroy() {
        activeInstance = null
        OverlayLockController.hide()
        cancelPendingOverlayExit()
        handler.removeCallbacks(pollRunnable)
        runCatching { unregisterReceiver(screenReceiver) }
        getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .edit()
            .remove(heartbeatKey)
            .apply()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int,
    ): Int {
        return START_STICKY
    }

    private fun resetForegroundState() {
        foregroundPackage = null
        lastQueryAt = System.currentTimeMillis() - 750L
    }

    private fun startAsForeground() {
        val notification = buildNotification()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                notificationId,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(notificationId, notification)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            channelId,
            "MY LOCK 보호",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "선택한 앱의 잠금 상태를 감지합니다."
            setShowBadge(false)
        }
        manager.createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        return builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("MY LOCK 보호 중")
            .setContentText("선택한 앱의 잠금 상태를 감지하고 있습니다.")
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_SERVICE)
            .build()
    }

    private fun pollForegroundApp() {
        writeHeartbeat()

        val ready = hasUsageAccess() && Settings.canDrawOverlays(this)
        if (!ready) {
            if (permissionsReady) {
                OverlayLockController.hide()
                cancelPendingOverlayExit()
                foregroundPackage = null
            }
            permissionsReady = false
            return
        }
        if (!permissionsReady) {
            permissionsReady = true
            resetForegroundState()
        }
        if (LockActivity.lockUiVisible) {
            lastQueryAt = System.currentTimeMillis()
            return
        }

        val now = System.currentTimeMillis()
        val events = usageStatsManager.queryEvents(lastQueryAt, now)
        lastQueryAt = now

        val event = UsageEvents.Event()
        var latestPackage: String? = null
        var latestClassName: String? = null
        var latestTimestamp = Long.MIN_VALUE

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val isForeground = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                event.eventType == UsageEvents.Event.ACTIVITY_RESUMED
            } else {
                @Suppress("DEPRECATION")
                event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND
            }

            if (isForeground && event.timeStamp >= latestTimestamp) {
                latestTimestamp = event.timeStamp
                latestPackage = event.packageName
                latestClassName = event.className
            }
        }

        if (latestPackage != null) {
            handleForegroundPackage(latestPackage, latestClassName)
        }
    }

    private fun handleForegroundPackage(
        packageName: String,
        className: String?,
    ) {
        val protectedApps = protectedApps()

        if (packageName == this.packageName) {
            val previous = foregroundPackage
            if (previous != null && protectedApps.contains(previous)) {
                persistProtectedAppExit(previous)
            }
            foregroundPackage = packageName
            return
        }

        if (isProtectedSessionSystemActivity(packageName, className)) {
            return
        }

        val overlayTarget = OverlayLockController.currentTarget()

        if (OverlayLockController.isVisible && overlayTarget != null) {
            // Recents, Home, and system-bar transitions can briefly emit a
            // system package while the user is still on the protected app.
            // Keep the lock overlay alive during that transient transition.
            if (isTransientSystemPackage(packageName)) {
                return
            }

            if (packageName == overlayTarget) {
                cancelPendingOverlayExit()
                foregroundPackage = packageName
                return
            }

            if (protectedApps.contains(packageName)) {
                cancelPendingOverlayExit()
                if (overlayTarget != packageName) {
                    markProtectedAppExited(overlayTarget)
                }
                foregroundPackage = packageName
                if (shouldLockInNativeFallback(packageName)) {
                    OverlayLockController.show(this, packageName)
                } else {
                    consumeTimedRelockGrace(packageName)
                    OverlayLockController.hide()
                }
                return
            }

            scheduleOverlayExit(overlayTarget)
            foregroundPackage = packageName
            return
        }

        if (packageName == foregroundPackage) {
            if (
                protectedApps.contains(packageName) &&
                !OverlayLockController.isVisible
            ) {
                if (shouldLockInNativeFallback(packageName)) {
                    OverlayLockController.show(
                        this,
                        packageName,
                        forceRecreate = true,
                    )
                } else {
                    consumeTimedRelockGrace(packageName)
                }
            }
            return
        }

        val previous = foregroundPackage
        if (previous != null && protectedApps.contains(previous)) {
            markProtectedAppExited(previous)
        }

        foregroundPackage = packageName
        if (!protectedApps.contains(packageName)) return

        cancelPendingOverlayExit()
        if (shouldLockInNativeFallback(packageName)) {
            OverlayLockController.show(this, packageName)
        } else {
            consumeTimedRelockGrace(packageName)
        }
    }

    private fun handleOverlayInterrupted(appId: String) {
        if (OverlayLockController.currentTarget() != appId) return
        interruptedOverlayTarget = appId
    }

    private fun handleOverlayRecovered(appId: String) {
        if (interruptedOverlayTarget != appId) return
        interruptedOverlayTarget = null

        val latestForeground = latestForegroundPackage()
        if (
            protectedApps().contains(appId) &&
            latestForeground == appId &&
            OverlayLockController.currentTarget() == appId
        ) {
            OverlayLockController.show(
                this,
                appId,
                forceRecreate = true,
            )
        }
    }

    private fun isTransientSystemPackage(packageName: String): Boolean {
        return packageName in transientSystemPackages
    }

    private fun isProtectedSessionSystemActivity(
        packageName: String,
        className: String?,
    ): Boolean {
        if (
            packageName in protectedSessionSystemPackages ||
            packageName.contains("photopicker", ignoreCase = true) ||
            packageName.contains("documentsui", ignoreCase = true)
        ) {
            return true
        }

        val activity = className.orEmpty()
        if (
            packageName == "android" &&
            (
                activity.contains("chooser", ignoreCase = true) ||
                    activity.contains("resolver", ignoreCase = true)
            )
        ) {
            return true
        }

        if (packageName == "com.sec.android.gallery3d") {
            return activity.contains("picker", ignoreCase = true) ||
                activity.contains("select", ignoreCase = true) ||
                activity.contains("chooser", ignoreCase = true) ||
                activity.contains("attach", ignoreCase = true) ||
                activity.contains("external", ignoreCase = true)
        }

        return false
    }

    private fun scheduleOverlayExit(appId: String) {
        if (pendingOverlayExitPackage == appId) return

        cancelPendingOverlayExit()
        pendingOverlayExitPackage = appId
        pendingOverlayExitAt = System.currentTimeMillis()

        val runnable = Runnable {
            if (pendingOverlayExitPackage != appId) return@Runnable

            val currentTarget = OverlayLockController.currentTarget()
            val latestForeground = latestForegroundPackage()
            if (
                OverlayLockController.isVisible &&
                currentTarget == appId &&
                latestForeground != appId
            ) {
                markProtectedAppExited(appId)
                OverlayLockController.hide()
            }
            cancelPendingOverlayExit()
        }
        pendingOverlayExitRunnable = runnable
        handler.postDelayed(runnable, overlayExitConfirmMs)
    }

    private fun cancelPendingOverlayExit() {
        pendingOverlayExitRunnable?.let(handler::removeCallbacks)
        pendingOverlayExitRunnable = null
        pendingOverlayExitPackage = null
        pendingOverlayExitAt = 0L
    }

    private fun consumeTimedRelockGrace(appId: String) {
        val preferences =
            getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
        val policy = preferences.getString(relockPolicyKey, "immediate")
        if (policy != "after30Seconds" && policy != "after1Minute") {
            return
        }

        val lastExitApp = preferences.getString(lastProtectedExitAppKey, null)
        val lastExitAt = preferences.getLong(lastProtectedExitAtKey, 0L)
        val lastUnlockedAt = preferences.getLong(lastUnlockedAtKey, 0L)
        if (
            lastExitApp != appId ||
            lastExitAt <= 0L ||
            lastExitAt < lastUnlockedAt
        ) {
            return
        }

        val graceMs =
            if (policy == "after30Seconds") 30_000L else 60_000L
        if (System.currentTimeMillis() - lastExitAt >= graceMs) {
            return
        }

        preferences.edit()
            .remove(lastProtectedExitAppKey)
            .remove(lastProtectedExitAtKey)
            .apply()
    }

    private fun persistProtectedAppExit(appId: String) {
        getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .edit()
            .putString(lastProtectedExitAppKey, appId)
            .putLong(lastProtectedExitAtKey, System.currentTimeMillis())
            .apply()
    }

    private fun markProtectedAppExited(appId: String) {
        persistProtectedAppExit(appId)
        MainActivity.emitProtectedAppExited(appId)
    }

    private fun latestForegroundPackage(): String? {
        if (!hasUsageAccess()) return foregroundPackage

        val now = System.currentTimeMillis()
        val events = usageStatsManager.queryEvents(now - 1_500L, now)
        val event = UsageEvents.Event()
        var latestPackage: String? = null
        var latestTimestamp = Long.MIN_VALUE

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val isForeground = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                event.eventType == UsageEvents.Event.ACTIVITY_RESUMED
            } else {
                @Suppress("DEPRECATION")
                event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND
            }

            if (isForeground && event.timeStamp >= latestTimestamp) {
                latestTimestamp = event.timeStamp
                latestPackage = event.packageName
            }
        }

        return latestPackage ?: foregroundPackage
    }

    private fun shouldLockInNativeFallback(appId: String): Boolean {
        val preferences =
            getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
        val lastUnlockedApp = preferences.getString(lastUnlockedAppKey, null)
        val lastUnlockedAt = preferences.getLong(lastUnlockedAtKey, 0L)

        if (lastUnlockedApp != appId || lastUnlockedAt <= 0L) {
            return true
        }

        val policy = preferences.getString(relockPolicyKey, "immediate")
        val lastExitApp = preferences.getString(lastProtectedExitAppKey, null)
        val lastExitAt = preferences.getLong(lastProtectedExitAtKey, 0L)
        val leftProtectedApp = lastExitApp == appId && lastExitAt >= lastUnlockedAt

        return when (policy) {
            "after30Seconds" -> {
                leftProtectedApp &&
                    System.currentTimeMillis() - lastExitAt >= 30_000L
            }
            "after1Minute" -> {
                leftProtectedApp &&
                    System.currentTimeMillis() - lastExitAt >= 60_000L
            }
            "screenOff" -> {
                val lastScreenOffAt = preferences.getLong(lastScreenOffAtKey, 0L)
                lastScreenOffAt >= lastUnlockedAt
            }
            else -> leftProtectedApp
        }
    }

    private fun forceRelockCurrentSession() {
        getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .edit()
            .remove(lastUnlockedAppKey)
            .remove(lastUnlockedAtKey)
            .apply()
        OverlayLockController.hide()
    }

    private fun launchScreenLockFallback() {
        if (!Settings.canDrawOverlays(this)) return
        LockActivity.launch(this, LockActivity.deviceScreenAppId)
    }

    private fun experimentalScreenLockEnabled(): Boolean {
        return getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .getBoolean(experimentalScreenLockKey, false)
    }

    private fun writeHeartbeat(force: Boolean = false) {
        val now = System.currentTimeMillis()
        if (!force && now - lastHeartbeatAt < heartbeatIntervalMs) return

        lastHeartbeatAt = now
        getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .edit()
            .putLong(heartbeatKey, now)
            .apply()
    }

    private fun protectedApps(): Set<String> {
        return getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .getStringSet(protectedAppsKey, emptySet())
            ?.toSet()
            .orEmpty()
    }

    private fun hasUsageAccess(): Boolean {
        val end = System.currentTimeMillis()
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            end - 60_000L,
            end,
        )
        return !stats.isNullOrEmpty()
    }
}
