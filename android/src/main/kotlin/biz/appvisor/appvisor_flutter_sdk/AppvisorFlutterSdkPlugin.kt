package biz.appvisor.appvisor_flutter_sdk

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
        getIntent(binding)
        callHandler.setActivity(binding.activity)
    }

    override fun onDetachedFromActivity() {
        callHandler.clearActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        getIntent(binding)
        callHandler.setActivity(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        callHandler.clearActivity()
    }

    private fun getIntent(binding: ActivityPluginBinding) {
        binding.addOnNewIntentListener {
            with(binding.activity) {
                intent = it

                val avp = Appvisor.getInstance(this)
                avp.getBundleFromAppvisor(this)?.let {
                    streamHandler.send(it.toMap())
                }
                avp.trackPushWithActivity(binding.activity)
            }

            false
        }
    }
}
