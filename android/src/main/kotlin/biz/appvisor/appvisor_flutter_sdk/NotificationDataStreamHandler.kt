package biz.appvisor.appvisor_flutter_sdk

import io.flutter.plugin.common.EventChannel

class NotificationDataStreamHandler: EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun send(message: Any?) {
        eventSink?.success(message)
    }
}