package biz.appvisor.appvisor_flutter_sdk

import biz.appvisor.appvisor_flutter_sdk.util.invalid
import io.flutter.plugin.common.MethodChannel

enum class AppvisorError(val message: String?) {
    InitFailed(null),
    ConfigurationsMissing("Configurations not found. Please call configure first."),
    MissingRequiredArg(null),
    InvalidSmallIconName(invalid("smallIconName")),
    InvalidLargeIconName(invalid("largeIconName")),
    TestNotificationSetupInfoFailed(null),
    TogglePushFailed("Failed to toggle push status."),
    SyncCustomPropertiesFailed(null),
    CheckForUpdateFailed("Failed to check for update."),
    ActivityNotFound("Activity not found. " +
            "Ensure this method is called after the Flutter engine is initialized and the activity is available. "
    ),
    ;
}

internal fun MethodChannel.Result.error(value: AppvisorError, errorDetails: Any? = null) =
    error(value.name, value.message, errorDetails)