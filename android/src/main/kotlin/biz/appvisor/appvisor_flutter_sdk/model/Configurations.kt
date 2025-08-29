package biz.appvisor.appvisor_flutter_sdk.model

import biz.appvisor.appvisor_flutter_sdk.util.missingArg

data class Configurations(
    val channelName: String,
    val channelDescription: String,
    val smallIconName: String,
    val largeIconName: String?,
    val defaultTitle: String?
) {
    internal fun toMap(): Map<String, String?> {
        return mapOf(
            "channelName" to channelName,
            "channelDescription" to channelDescription,
            "smallIconName" to smallIconName,
            "largeIconName" to largeIconName,
            "defaultTitle" to defaultTitle
        )
    }

    internal companion object {

        fun fromMap(map: Map<String, Any>): Configurations {
            val channelName = map["channelName"] as? String
            if (channelName.isNullOrBlank()) {
                throwError("channelName")
            }
            val channelDescription = map["channelDescription"] as? String
            if (channelDescription.isNullOrBlank()) {
                throwError("channelDescription")
            }
            val smallIconName = map["smallIconName"] as? String
            if (smallIconName.isNullOrBlank()) {
                throwError("smallIconName")
            }
            val largeIconName = map["largeIconName"] as? String
            val title = map["defaultTitle"] as? String

            return Configurations(
                channelName = channelName,
                channelDescription = channelDescription,
                smallIconName = smallIconName,
                largeIconName = largeIconName,
                defaultTitle = title
            )
        }
        private fun throwError(key: String): Nothing = throw IllegalArgumentException(missingArg(key))
    }
}