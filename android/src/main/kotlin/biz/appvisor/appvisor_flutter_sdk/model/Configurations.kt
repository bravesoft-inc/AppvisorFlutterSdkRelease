package biz.appvisor.appvisor_flutter_sdk.model

import biz.appvisor.appvisor_flutter_sdk.util.missingArg

data class Configurations(
    val channelName: String,
    val channelDescription: String?,
    val smallIconName: String,
    val largeIconName: String?,
    val defaultTitle: String,
    val richPushDialogWidth: Int?,
    val richPushDialogHeight: Int?
) {
    internal fun toMap(): Map<String, String?> {
        return mapOf(
            "channelName" to channelName,
            "channelDescription" to channelDescription,
            "smallIconName" to smallIconName,
            "largeIconName" to largeIconName,
            "defaultTitle" to defaultTitle,
            "richPushDialogWidth" to richPushDialogWidth?.toString(),
            "richPushDialogHeight" to richPushDialogHeight?.toString(),
        )
    }

    internal companion object {

        // 必須項目 (channelName / smallIconName / defaultTitle):
        //   null または空文字 / 空白のみの場合は「未指定」とみなしエラーを投げる。
        //   - channelName は Android 8.0+ で NotificationChannel 生成のため実質必須。
        //     未指定だと OS にチャンネルが登録されず通知が一切配信されない。
        //   - smallIconName / defaultTitle は Native SDK 上も required。
        // optional 項目 (channelDescription / largeIconName / richPushDialog*):
        //   空文字 / 空白のみは「未指定」と同等に扱うため null に正規化する。
        //   通知配信に影響しないため省略可能。
        fun fromMap(map: Map<String, Any?>): Configurations {
            // 必須項目は Elvis で例外スローし non-null 型に確定させる。
            // smart cast に依存せず後続の Configurations(...) 呼び出しで型が明示される。
            val channelName: String = (map["channelName"] as? String)?.takeIf { it.isNotBlank() }
                ?: throwError("channelName")
            val channelDescription = (map["channelDescription"] as? String)?.takeIf { it.isNotBlank() }
            val smallIconName: String = (map["smallIconName"] as? String)?.takeIf { it.isNotBlank() }
                ?: throwError("smallIconName")
            val largeIconName = map["largeIconName"] as? String
            val defaultTitle: String = (map["defaultTitle"] as? String)?.takeIf { it.isNotBlank() }
                ?: throwError("defaultTitle")
            val richPushDialogWidth = (map["richPushDialogWidth"] as? String)?.toIntOrNull()
            val richPushDialogHeight = (map["richPushDialogHeight"] as? String)?.toIntOrNull()

            return Configurations(
                channelName = channelName,
                channelDescription = channelDescription,
                smallIconName = smallIconName,
                largeIconName = largeIconName,
                defaultTitle = defaultTitle,
                richPushDialogWidth = richPushDialogWidth,
                richPushDialogHeight = richPushDialogHeight
            )
        }
        private fun throwError(key: String): Nothing = throw IllegalArgumentException(missingArg(key))
    }
}