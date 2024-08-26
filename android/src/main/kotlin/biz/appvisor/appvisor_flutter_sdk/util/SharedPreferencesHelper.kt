package biz.appvisor.appvisor_flutter_sdk.util

import android.annotation.SuppressLint
import android.content.Context
import biz.appvisor.appvisor_flutter_sdk.model.Configurations

private const val notificationSetupInfo = "notification_setup_info"

internal class SharedPreferencesHelper(context: Context) {
    private val prefs = context.getSharedPreferences("avp_flutter_sdk", Context.MODE_PRIVATE)

    @SuppressLint("ApplySharedPref")
    fun setConfigurations(notification: Configurations) {
        val editor = prefs.edit()
        val notificationMap = notification.toMap()
        val notificationString =
            notificationMap.entries.joinToString(separator = "|") { "${it.key}=${it.value}" }
        editor.putString(notificationSetupInfo, notificationString)
        editor.commit()
    }

    fun getConfigurations(): Configurations? {
        val str = prefs.getString(notificationSetupInfo, "") ?: return null
        val map = runCatching {
            str.split("|").associate {
                val (key, value) = it.split("=")
                key to value
            }
        }.getOrNull() ?: return null
        return Configurations.fromMap(map)
    }
}