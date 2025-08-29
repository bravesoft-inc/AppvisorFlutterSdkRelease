package biz.appvisor.appvisor_flutter_sdk

import android.annotation.SuppressLint
import android.app.Activity
import biz.appvisor.android.sdk.Appvisor
import biz.appvisor.android.sdk.AppvisorConfigurations
import biz.appvisor.appvisor_flutter_sdk.AppvisorError.CheckForUpdateFailed
import biz.appvisor.appvisor_flutter_sdk.AppvisorError.InvalidLargeIconName
import biz.appvisor.appvisor_flutter_sdk.AppvisorError.InvalidSmallIconName
import biz.appvisor.appvisor_flutter_sdk.AppvisorError.MissingRequiredArg
import biz.appvisor.appvisor_flutter_sdk.AppvisorError.TestNotificationSetupInfoFailed
import biz.appvisor.appvisor_flutter_sdk.PlatformMethod.CheckForUpdate
import biz.appvisor.appvisor_flutter_sdk.PlatformMethod.Configure
import biz.appvisor.appvisor_flutter_sdk.PlatformMethod.GetConfig
import biz.appvisor.appvisor_flutter_sdk.PlatformMethod.GetCustomProperty
import biz.appvisor.appvisor_flutter_sdk.PlatformMethod.GetDeviceId
import biz.appvisor.appvisor_flutter_sdk.PlatformMethod.GetNotices
import biz.appvisor.appvisor_flutter_sdk.PlatformMethod.Init
import biz.appvisor.appvisor_flutter_sdk.PlatformMethod.IsPushEnabled
import biz.appvisor.appvisor_flutter_sdk.PlatformMethod.MarkNoticeAsRead
import biz.appvisor.appvisor_flutter_sdk.PlatformMethod.RequestAppReview
import biz.appvisor.appvisor_flutter_sdk.PlatformMethod.SetCustomProperty
import biz.appvisor.appvisor_flutter_sdk.PlatformMethod.SyncCustomProperties
import biz.appvisor.appvisor_flutter_sdk.PlatformMethod.TestNotificationSetup
import biz.appvisor.appvisor_flutter_sdk.PlatformMethod.TogglePush
import biz.appvisor.appvisor_flutter_sdk.model.Configurations
import biz.appvisor.appvisor_flutter_sdk.util.SharedPreferencesHelper
import biz.appvisor.appvisor_flutter_sdk.util.invalid
import biz.appvisor.appvisor_flutter_sdk.util.lastKeyFromMap
import biz.appvisor.appvisor_flutter_sdk.util.missingArg
import biz.appvisor.appvisor_flutter_sdk.util.toMap
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FlutterMethodCallHandler : MethodCallHandler {
    private var activity: Activity? = null
    private var channel: MethodChannel? = null

    fun setActivity(activity: Activity) {
        this.activity = activity
    }

    fun setChannel(channel: MethodChannel) {
        this.channel = channel
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val activityRef = this.activity
        if (activityRef != null) {
            val method = runCatching { PlatformMethod.valueOf(call.method) }.getOrNull()
            when (method) {
                GetDeviceId -> getDeviceId(activityRef, result)
                IsPushEnabled -> isPushStatus(activityRef,result)
                Init -> initAppvisor(activityRef, call, result)
                Configure -> configure(activityRef, call, result)
                TestNotificationSetup -> testNotificationSetup(activityRef, result)
                TogglePush -> togglePush(activityRef, call, result)
                SetCustomProperty -> setCustomProperty(activityRef, call, result)
                GetCustomProperty -> getCustomProperty(activityRef, call, result)
                SyncCustomProperties -> syncCustomProperties(activityRef, result)
                CheckForUpdate -> checkForUpdate(activityRef, call, result)
                RequestAppReview -> requestAppReview(activityRef, result)
                GetConfig -> getConfig(activityRef, result)
                GetNotices -> getNotices(activityRef, call, result)
                MarkNoticeAsRead -> markNoticeAsRead(activityRef, call, result)
                null -> result.notImplemented()
            }
        } else {
            result.error(
                AppvisorError.ActivityNotFound,
                null
            )
        }
    }

    private fun getDeviceId(activity: Activity, result: Result) {
        val appvisor = Appvisor.getInstance(activity)
        result.success(appvisor.deviceID)
    }

    private fun isPushStatus(activity: Activity, result: Result) {
        val appvisor = Appvisor.getInstance(activity)
        result.success(appvisor.pushReceiveStatus)
    }

    @SuppressLint("DiscouragedApi")
    private fun initAppvisor(activity: Activity, call: MethodCall, result: Result) {
        val appKey = call.argument<String>("appKey")
        val debuggable = call.argument<Boolean>("enableLogs") ?: false
        if (appKey.isNullOrBlank()) return result.error(
            MissingRequiredArg.name,
            missingArg("appKey"),
            null
        )
        val sharedPreferencesHelper = SharedPreferencesHelper(activity)
        val configs = sharedPreferencesHelper.getConfigurations()
            ?: return result.error(AppvisorError.ConfigurationsMissing)
        try {
            val appvisor = Appvisor.getInstance(activity)
            appvisor.requestNotificationPermission(activity)
            appvisor.reactivateOnce()

            val largeIconId = configs.largeIconName?.let { activity.getIcon(it) }
            val smallIconId = configs.smallIconName.let { activity.getIcon(it) }

            val avConfigs = AppvisorConfigurations(
                appKey = appKey,
                smallIcon = smallIconId,
                largeIcon = largeIconId,
                notificationChannelName = configs.channelName,
                notificationChannelDescription = configs.channelDescription,
                defaultTitle = configs.defaultTitle ?: "",
                debuggable = debuggable,
                callbackClass = activity.javaClass,
            )

            appvisor.init(avConfigs)
            result.success(null)

        } catch (e: Exception) {
            result.error(AppvisorError.InitFailed.name, e.message, e)
        }
    }

    @SuppressLint("DiscouragedApi")
    private fun Activity.getIcon(name: String): Int {
        return applicationContext
            .resources
            .getIdentifier(name, "drawable", packageName)
    }
    @SuppressLint("DiscouragedApi")
    private fun configure(
        activity: Activity,
        call: MethodCall,
        result: Result
    ) {
        try {
            val setupInfoMap = call.argument<Map<String, String>>("setupInfo")
            if (setupInfoMap == null) {
                result.error(MissingRequiredArg.name, missingArg("setupInfo"), null)
                return
            }
            val configurations = Configurations.fromMap(setupInfoMap)

            val smallIconId = activity.getIcon(configurations.smallIconName)
            if (smallIconId == 0) {
                result.error(InvalidSmallIconName.name, invalid("smallIconName"), null)
                return
            }
            val largeIconId = configurations.largeIconName?.let { activity.getIcon(it) }
            if (largeIconId == 0) {
                result.error(InvalidLargeIconName.name, invalid("largeIconName"), null)
                return
            }
            val sharedPreferencesHelper = SharedPreferencesHelper(activity)
            sharedPreferencesHelper.setConfigurations(configurations)
            result.success(null)
        } catch (e: Exception) {
            result.error(MissingRequiredArg.name, e.message, e)
        }
    }

    private fun testNotificationSetup(activity: Activity, result: Result) {
        val sharedPreferencesHelper = SharedPreferencesHelper(activity)
        val setupInfo = sharedPreferencesHelper.getConfigurations()
        if (setupInfo == null) {
            result.error(TestNotificationSetupInfoFailed, null)
            return
        }
        result.success(setupInfo.toMap())
    }

    private fun togglePush(activity: Activity, call: MethodCall, result: Result) {
        val appvisor = Appvisor.getInstance(activity)
        val onOff = call.argument<Boolean>("on")
        if (onOff == null) {
            result.error(MissingRequiredArg.name, missingArg("on"), null)
        } else {
            appvisor.changePushReceiveStatus(onOff)
            appvisor.addChangePushStatusListener(
                onSuccess = {
                    result.success(it)
                },
                onFailure = {
                    result.error(AppvisorError.TogglePushFailed)
                }
            )
        }
    }

    private fun setCustomProperty(activity: Activity, call: MethodCall, result: Result) {
        val value = call.argument<String>("value")
        val id = call.argument<Int>("parameterId")
        if (id == null) {
            result.error(MissingRequiredArg.name, missingArg("parameterId"), null)
            return
        }
        val appvisor = Appvisor.getInstance(activity)
        val success = appvisor.setCustomProperty(parameterId = id, value = value)
        result.success(success)
    }

    private fun getCustomProperty(activity: Activity, call: MethodCall, result: Result) {
        val id = call.argument<Int>("parameterId")
        if (id == null) {
            result.error(MissingRequiredArg.name, missingArg("parameterId"), null)
            return
        }
        val appvisor = Appvisor.getInstance(activity)
        val value = appvisor.getCustomProperty(parameterId = id)
        result.success(value)
    }

    private fun syncCustomProperties(activity: Activity, result: Result) {
        val appvisor = Appvisor.getInstance(activity)
        appvisor.syncCustomProperties(
            onFailure = { e ->
                result.error(e.type, e.message, e.cause)
            },
            onSuccess = {
                result.success(null)
            }
        )
    }

    private fun checkForUpdate(activity: Activity, call: MethodCall, result: Result) {
        val useSDKDialog = call.argument<Boolean>("useSDKDialog") ?: true
        val appvisor = Appvisor.getInstance(activity)
        appvisor.checkForUpdate(
            activity = activity,
            onDismiss = {
                channel?.invokeMethod(FlutterCallback.UpdateDialogOnDismiss.name, null)
            },
            useSDKDialog = useSDKDialog,
            onNavigationToStore = {
                channel?.invokeMethod(FlutterCallback.UpdateDialogOnNavigationToStore.name, null)
            },
            onSuccess = {
                result.success(it?.toMap())
            },
            onFailure = {
                result.error(CheckForUpdateFailed.name, it.message, it.cause)
            }
        )
    }

    private fun requestAppReview(activity: Activity, result: Result) {
        val appvisor = Appvisor.getInstance(activity)
        appvisor.requestAppReview(activity)
        result.success(null)
    }

    private fun getConfig(activity: Activity, result: Result) {
        val appvisor = Appvisor.getInstance(activity)
        appvisor.getConfig(
            onSuccess = {
                result.success(it.toMap())
            },
            onFailure = {
                result.error(it.type, it.message, it.cause)
            }
        )
    }

    private fun getNotices(activity: Activity, call: MethodCall, result: Result) {
        val lastKey = call.argument<Map<String, Any>?>("lastKey")?.run(::lastKeyFromMap)
        val appvisor = Appvisor.getInstance(activity)
        appvisor.getNotices(
            lastKey = lastKey,
            onSuccess = {
                result.success(it.toMap())
            },
            onFailure = {
                result.error(it.type, it.message, it.cause)
            }
        )
    }

    private fun markNoticeAsRead(activity: Activity, call: MethodCall, result: Result) {
        val messageId = call.argument<Int>("messageId")
        if (messageId == null) {
            result.error(MissingRequiredArg.name, missingArg("messageId"), null)
            return
        }

        val appvisor = Appvisor.getInstance(activity)
        appvisor.markNoticeAsRead(
            messageId = messageId,
            onSuccess = {
                result.success(null)
            },
            onFailure = {
                result.error(it.type, it.message, it.cause)
            }
        )
    }

    fun clearActivity() {
        activity = null
    }

    fun destroy() {
        clearActivity()
        channel = null
    }
}