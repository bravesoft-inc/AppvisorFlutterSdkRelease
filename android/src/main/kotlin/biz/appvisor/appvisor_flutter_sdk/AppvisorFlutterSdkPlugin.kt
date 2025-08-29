package biz.appvisor.appvisor_flutter_sdk

import android.app.Activity
import android.util.Log
import biz.appvisor.android.sdk.Appvisor
import biz.appvisor.appvisor_flutter_sdk.util.toMap
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/** AppvisorFlutterSdkPlugin */
class AppvisorFlutterSdkPlugin : FlutterPlugin, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel

    private val callHandler = FlutterMethodCallHandler()
    private val streamHandler = NotificationDataStreamHandler()
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "appvisor_flutter_sdk")
        channel.setMethodCallHandler(callHandler)
        callHandler.setChannel(channel)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "appvisor_flutter_sdk/notification")
        eventChannel.setStreamHandler(streamHandler)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        callHandler.destroy()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        getNotificationData(binding.activity)
        addOnNewIntentListener(binding)
        callHandler.setActivity(binding.activity)
    }

    override fun onDetachedFromActivity() {
        callHandler.clearActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        getNotificationData(binding.activity)
        addOnNewIntentListener(binding)
        callHandler.setActivity(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        callHandler.clearActivity()
    }

    private fun addOnNewIntentListener(binding: ActivityPluginBinding) {
        binding.addOnNewIntentListener {
            with(binding.activity) {
                intent = it

                getNotificationData(this)
            }
            false
        }
    }

    private fun getNotificationData(activity: Activity) {
        val av = Appvisor.getInstance(activity)
        av.getBundleFromAppvisor(activity)?.let {
            if (av.checkIfStartByAppvisor(activity)) {
                streamHandler.send(it.toMap())
            }
        }
        av.trackPushWithActivity(activity)
    }
}
