package biz.appvisor.appvisor_flutter_sdk

import android.annotation.SuppressLint
import android.app.Activity
import biz.appvisor.appvisor_flutter_sdk.AvpError.CheckForUpdateFailed
import biz.appvisor.appvisor_flutter_sdk.AvpError.InvalidLargeIconName
import biz.appvisor.appvisor_flutter_sdk.AvpError.InvalidSmallIconName
import biz.appvisor.appvisor_flutter_sdk.AvpError.MissingRequiredArg
import biz.appvisor.appvisor_flutter_sdk.AvpError.TestNotificationSetupInfoFailed
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
import biz.appvisor.android.sdk.AppvisorOptionParams
import biz.appvisor.android.sdk.Appvisor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FlutterMethodCallHandler : MethodCallHandler {
    private var activity: Activity? = null
    private val avp by lazy { Appvisor.getInstance(activity!!) }
    private val sharedPreferencesHelper by lazy { SharedPreferencesHelper(activity!!.applicationContext) }
    private var channel: MethodChannel? = null
    fun setActivity(activity: Activity) {
        this.activity = activity
    }

    fun setChannel(channel: MethodChannel) {
        this.channel = channel
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val method = runCatching { PlatformMethod.valueOf(call.method) }.getOrNull()
        when (method) {
            GetDeviceId -> getDeviceId(result)
            IsPushEnabled -> isPushStatus(result)
            Init -> initAvp(call, result)
            Configure -> configure(call, result)
            TestNotificationSetup -> testNotificationSetup(result)
            TogglePush -> togglePush(call, result)
            SetCustomProperty -> setCustomProperty(call, result)
            GetCustomProperty -> getCustomProperty(call, result)
            SyncCustomProperties -> syncCustomProperties(result)
            CheckForUpdate -> checkForUpdate(call, result)
            RequestAppReview -> requestAppReview(result)
            GetConfig -> getConfig(result)
            GetNotices -> getNotices(call, result)
            MarkNoticeAsRead -> markNoticeAsRead(call, result)
            null -> result.notImplemented()
        }
    }

    private fun getDeviceId(result: Result) {
        result.success(avp.deviceID)
    }

    private fun isPushStatus(result: Result) {
        result.success(avp.pushReceiveStatus)
    }

    @SuppressLint("DiscouragedApi")
    private fun initAvp(call: MethodCall, result: Result) {
        val appKey = call.argument<String>("appKey")
        val debuggable = call.argument<Boolean>("enableLogs") ?: false
        if (appKey.isNullOrBlank()) return result.error(MissingRequiredArg.name, missingArg("appKey"), null)
        val configs = sharedPreferencesHelper.getConfigurations()
            ?: return result.error(AvpError.ConfigurationsMissing)
        try {
            avp.requestNotificationPermission(activity!!)
            avp.reactivateOnce()
            avp.setAppInfo(appKey, debuggable)
            avp.setNotificationChannel(
                configs.channelName,
                configs.channelDescription
            )

            val largeIconId = if (configs.largeIconName != null) {
                activity!!.applicationContext.resources.getIdentifier(
                    configs.largeIconName, "drawable", activity!!.packageName
                )
            } else {
                null
            }

            val optionParams = AppvisorOptionParams(
                largeIcon = largeIconId,
            )
            avp.startPush(
                senderID = "not_used_in_sdk",
                title = configs.defaultTitle ?: "",
                classToCallBack = activity!!.javaClass,
                pushIconID = activity!!.applicationContext.resources.getIdentifier(
                    configs.largeIconName, "drawable", activity!!.packageName
                ),
                statusbarIconID = activity!!.applicationContext.resources.getIdentifier(
                    configs.smallIconName, "drawable", activity!!.packageName
                ),
                optionalParams = optionParams
            )
            result.success(null)
        } catch (e: Exception) {
            result.error(AvpError.InitFailed.name, e.message, e)
        }
    }

    @SuppressLint("DiscouragedApi")
    private fun configure(
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

            val smallIconId = activity!!.applicationContext.resources
                .getIdentifier(configurations.smallIconName, "drawable", activity!!.packageName)
            if (smallIconId == 0) {
                result.error(InvalidSmallIconName.name, invalid("smallIconName"), null)
                return
            }
            val largeIconId = activity!!.applicationContext.resources
                .getIdentifier(configurations.largeIconName, "drawable", activity!!.packageName)
            if (largeIconId == 0) {
                result.error(InvalidLargeIconName.name, invalid("largeIconName"), null)
                return
            }

            sharedPreferencesHelper.setConfigurations(configurations)
            result.success(null)
        } catch (e: Exception) {
            result.error(MissingRequiredArg.name, e.message, e)
        }
    }

    private fun testNotificationSetup(result: Result) {
        try {
            val setupInfo = sharedPreferencesHelper.getConfigurations()
            if (setupInfo == null) {
                result.error(TestNotificationSetupInfoFailed.name, "NotFound", null)
                return
            }
            result.success(setupInfo.toMap())
        } catch (e: Exception) {
            result.error(TestNotificationSetupInfoFailed.name, null, null)
        }
    }

    private fun togglePush(call: MethodCall, result: Result) {
        val onOff = call.argument<Boolean>("on")
        if (onOff == null) {
            result.error(MissingRequiredArg.name, missingArg("on"), null)
            return
        }

        avp.changePushReceiveStatus(onOff)
        avp.addChangePushStatusListener(
            onSuccess = {
                result.success(it)
            },
            onFailure = {
                result.error(AvpError.TogglePushFailed)
            }
        )
    }

    private fun setCustomProperty(call: MethodCall, result: Result) {
        val value = call.argument<String>("value")
        val id = call.argument<Int>("parameterId")
        if (id == null) {
            result.error(MissingRequiredArg.name, missingArg("parameterId"), null)
            return
        }
        val success = avp.setCustomProperty(parameterId = id, value = value)
        result.success(success)
    }

    private fun getCustomProperty(call: MethodCall, result: Result) {
        val id = call.argument<Int>("parameterId")
        if (id == null) {
            result.error(MissingRequiredArg.name, missingArg("parameterId"), null)
            return
        }
        val value = avp.getCustomProperty(parameterId = id)
        result.success(value)
    }

    private fun syncCustomProperties(result: Result) {
        avp.syncCustomProperties(
            onFailure = { e ->
                result.error(e.type, e.message, e.cause)
            },
            onSuccess = {
                result.success(null)
            }
        )
    }

    private fun checkForUpdate(call: MethodCall, result: Result) {
        val useSDKDialog = call.argument<Boolean>("useSDKDialog") ?: true
        avp.checkForUpdate(
            activity = activity!!,
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

    private fun requestAppReview(result: Result) {
        avp.requestAppReview(activity!!)
        result.success(null)
    }

    private fun getConfig(result: Result) {
        avp.getConfig(
            onSuccess = {
                result.success(it.toMap())
            },
            onFailure = {
                result.error(it.type, it.message, it.cause)
            }
        )
    }

    private fun getNotices(call: MethodCall, result: Result) {
        val lastKey = call.argument<Map<String, Any>?>("lastKey")?.run(::lastKeyFromMap)
        avp.getNotices(
            lastKey = lastKey,
            onSuccess = {
                result.success(it.toMap())
            },
            onFailure = {
                result.error(it.type, it.message, it.cause)
            }
        )
    }

    private fun markNoticeAsRead(call: MethodCall, result: Result) {
        val messageId = call.argument<Int>("messageId")
        if (messageId == null) {
            result.error(MissingRequiredArg.name, missingArg("messageId"), null)
            return
        }

        avp.markNoticeAsRead(
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