package com.mylock.app.my_lock

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
        private const val pollIntervalMs = 350L
        private const val preferencesName = "my_lock_native"
        private const val protectedAppsKey = "protected_apps"
        private const val pendingLockAppKey = "pending_lock_app"
        const val heartbeatKey = "monitor_heartbeat_at"
        private const val heartbeatIntervalMs = 2_000L
    }

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var usageStatsManager: UsageStatsManager

    private var lastQueryAt = 0L
    private var lastHeartbeatAt = 0L
    private var foregroundPackage: String? = null

    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == Intent.ACTION_SCREEN_OFF) {
                foregroundPackage = null
                MainActivity.emitScreenOff()
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
        usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        createNotificationChannel()
        startAsForeground()

        val filter = IntentFilter(Intent.ACTION_SCREEN_OFF)
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
        MainActivity.lockUiVisible = false
        super.onTaskRemoved(rootIntent)
    }

    override fun onDestroy() {
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
        if (!hasUsageAccess()) return
        if (MainActivity.lockUiVisible) {
            lastQueryAt = System.currentTimeMillis()
            return
        }

        val now = System.currentTimeMillis()
        val events = usageStatsManager.queryEvents(lastQueryAt, now)
        lastQueryAt = now

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

        if (latestPackage != null) {
            handleForegroundPackage(latestPackage)
        }
    }

    private fun handleForegroundPackage(packageName: String) {
        if (packageName == this.packageName) return
        if (packageName == foregroundPackage) return

        val previous = foregroundPackage
        val protectedApps = protectedApps()

        if (previous != null && protectedApps.contains(previous)) {
            MainActivity.emitProtectedAppExited(previous)
        }

        foregroundPackage = packageName

        if (!protectedApps.contains(packageName)) return

        val delivered = MainActivity.emitProtectedAppEntered(packageName)
        if (!delivered) {
            launchLockFallback(packageName)
        }
    }

    private fun launchLockFallback(appId: String) {
        if (!Settings.canDrawOverlays(this)) return

        getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .edit()
            .putString(pendingLockAppKey, appId)
            .apply()

        MainActivity.lockUiVisible = true

        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT,
            )
        }

        runCatching { startActivity(intent) }
            .onFailure { MainActivity.lockUiVisible = false }
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
