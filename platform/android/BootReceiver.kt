package com.mylock.app.my_lock

import android.app.AppOpsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Process
import android.provider.Settings

class BootReceiver : BroadcastReceiver() {
    companion object {
        private const val preferencesName = "my_lock_native"
        private const val protectedAppsKey = "protected_apps"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val supportedAction =
            intent.action == Intent.ACTION_BOOT_COMPLETED ||
                intent.action == Intent.ACTION_MY_PACKAGE_REPLACED

        if (!supportedAction || !isProtectionReady(context)) return

        val serviceIntent = Intent(context, LockMonitorService::class.java)

        runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        }
    }

    private fun isProtectionReady(context: Context): Boolean {
        val protectedApps =
            context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
                .getStringSet(protectedAppsKey, emptySet())
                .orEmpty()

        return protectedApps.isNotEmpty() &&
            hasUsageAccess(context) &&
            Settings.canDrawOverlays(context)
    }

    private fun hasUsageAccess(context: Context): Boolean {
        val appOps =
            context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            context.packageName,
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }
}
