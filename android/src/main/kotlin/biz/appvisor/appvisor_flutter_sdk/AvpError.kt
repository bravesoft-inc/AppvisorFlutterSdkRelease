package biz.appvisor.appvisor_flutter_sdk

import biz.appvisor.appvisor_flutter_sdk.util.invalid
import biz.appvisor.appvisor_flutter_sdk.util.missingArg
import io.flutter.plugin.common.MethodChannel

enum class AvpError(val message: String?) {
    InitFailed(null),
    ConfigurationsMissing("Configurations not found. Please call configure first."),
    MissingRequiredArg(null),
    InvalidSmallIconName(invalid("smallIconName")),
    InvalidLargeIconName(invalid("largeIconName")),
    TestNotificationSetupInfoFailed(null),
    TogglePushFailed("Failed to toggle push status."),
    SyncCustomPropertiesFailed(null),
    CheckForUpdateFailed("Failed to check for update."),
    ;
}

internal fun MethodChannel.Result.error(value: AvpError, errorDetails: Any? = null) =
    error(value.name, value.message, errorDetails)