package biz.appvisor.appvisor_flutter_sdk.util

import android.annotation.SuppressLint
import android.content.Context
import biz.appvisor.appvisor_flutter_sdk.model.Configurations
import androidx.core.content.edit
import org.json.JSONObject

private const val notificationSetupInfo = "notification_setup_info"
internal class SharedPreferencesHelper(context: Context) {
    // Leaving shared preferences name as "avp_flutter_sdk" for backward compatibility.
    private val prefs = context.getSharedPreferences("avp_flutter_sdk", Context.MODE_PRIVATE)

    @SuppressLint("ApplySharedPref")
    fun setConfigurations(notification: Configurations) {
        prefs.edit(commit = true) {
            val json = JSONObject()
            notification.toMap().forEach { (key, value) ->
                if (value != null) {
                    json.put(key, value)
                }
            }
            putString(notificationSetupInfo, json.toString())
        }
    }

    fun getConfigurations(): Configurations? {
        val str = prefs.getString(notificationSetupInfo, null) ?: return null
        if (str.isEmpty()) return null
        val map = runCatching {
            val json = JSONObject(str)
            json.keys().asSequence().associateWith { json.getString(it) }
        }.getOrNull() ?: return null
        return runCatching { Configurations.fromMap(map) }.getOrNull()
    }
}
