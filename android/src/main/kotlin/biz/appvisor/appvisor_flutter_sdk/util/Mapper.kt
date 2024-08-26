package biz.appvisor.appvisor_flutter_sdk.util

import android.os.Bundle
import biz.appvisor.android.sdk.forceupdate.UpdateData
import biz.appvisor.android.sdk.notices.LastKey
import biz.appvisor.android.sdk.notices.Notice
import biz.appvisor.android.sdk.notices.NoticeList
import org.json.JSONObject
import org.json.JSONArray

internal fun UpdateData.toMap(): Map<String, Any> = mapOf(
    "storeUrl" to storeUrl,
    "optional" to isOptional,
)

internal fun JSONObject.toMap(depth: Int = 0): Map<String, Any> {
    val map = mutableMapOf<String, Any>()
    if (depth > 100) { // Prevent deep recursion
        return map
    }
    keys().forEach { key ->
        val value = this.opt(key)
        when {
            value is JSONObject -> map[key] = value.toMap(depth + 1)
            value is JSONArray -> map[key] = value.toList(depth + 1)
            value != JSONObject.NULL && value != null -> map[key] = value
        }
    }
    return map
}

private fun JSONArray.toList(depth: Int = 0): List<Any> {
    val list = mutableListOf<Any>()
    if (depth > 100) { // Prevent deep recursion
        return list
    }
    for (i in 0 until this.length()) {
        val value = this.opt(i)
        when {
            value is JSONObject -> list.add(value.toMap(depth + 1))
            value is JSONArray -> list.add(value.toList(depth + 1))
            value != JSONObject.NULL && value != null -> list.add(value)
        }
    }
    return list
}

internal fun NoticeList.toMap(): Map<String, Any?> = mapOf(
    "lastKey" to lastKey?.toMap(),
    "notices" to data.map { it.toMap() }
)


private fun LastKey.toMap(): Map<String, String> = mapOf(
    "messageId" to messageId,
    "userUUID" to userUUID,
)

private fun Notice.toMap(): Map<String, Any> = mapOf(
    "messageId" to messageId,
    "pushBody" to pushBody,
    "pushTitle" to pushTitle,
    "readStatus" to readStatus,
    "timestamp" to timestamp,
    "url" to url,
    "userUUID" to userUUID,
)

internal fun lastKeyFromMap(map: Map<String, Any>): LastKey {
    return LastKey(
        messageId = map["messageId"] as String,
        userUUID = map["userUUID"] as String,
    )
}

internal fun Bundle.toMap(): Map<String, String?> {
    val map = mutableMapOf<String, String?>()
    keySet().forEach {
        map[it] = getString(it)
    }
    return map
}