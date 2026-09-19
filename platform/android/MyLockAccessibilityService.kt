package com.mylock.app.my_lock

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.provider.Settings
import android.view.accessibility.AccessibilityEvent

class MyLockAccessibilityService : AccessibilityService() {
    companion object {
        private const val preferencesName = "my_lock_native"
        private const val protectedAppsKey = "protected_apps"
        private const val relockPolicyKey = "relock_policy"
        private const val lastUnlockedAppKey = "last_unlocked_app"
        private const val lastUnlockedAtKey = "last_unlocked_at"
        private const val lastProtectedExitAppKey = "last_protected_exit_app"
        private const val lastProtectedExitAtKey = "last_protected_exit_at"
        private const val lastScreenOffAtKey = "last_screen_off_at"
    }

    private var lastPackageName: String? = null

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val packageName = event?.packageName?.toString()
        if (packageName.isNullOrBlank()) return
        if (packageName == this.packageName) return
        if (packageName == lastPackageName) return

        val previousPackage = lastPackageName
        lastPackageName = packageName

        val protectedApps = protectedApps()
        if (previousPackage != null && protectedApps.contains(previousPackage)) {
            markProtectedAppExited(previousPackage)
            MainActivity.emitProtectedAppExited(previousPackage)
        }

        if (!protectedApps.contains(packageName)) return
        if (!Settings.canDrawOverlays(this)) return
        if (!shouldLock(packageName)) return

        val delivered = MainActivity.emitProtectedAppEntered(packageName)
        if (!delivered || !LockActivity.lockUiVisible) {
            LockActivity.launch(this, packageName)
        }
    }

    override fun onInterrupt() = Unit

    override fun onServiceConnected() {
        super.onServiceConnected()
        lastPackageName = null
    }

    private fun protectedApps(): Set<String> {
        return getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .getStringSet(protectedAppsKey, emptySet())
            ?.toSet()
            .orEmpty()
    }

    private fun markProtectedAppExited(appId: String) {
        getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .edit()
            .putString(lastProtectedExitAppKey, appId)
            .putLong(lastProtectedExitAtKey, System.currentTimeMillis())
            .apply()
    }

    private fun shouldLock(appId: String): Boolean {
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
}
