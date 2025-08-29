package biz.appvisor.appvisor_flutter_sdk

import io.flutter.plugin.common.EventChannel

class NotificationDataStreamHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private var cachedEvent: Any? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        cachedEvent?.let { event ->
            eventSink?.success(event)
            cachedEvent = null
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun send(message: Any?) {
        // Sending event
        if (eventSink != null && message != null) {
            eventSink?.success(message)

        } else if (message != null) {
            // Sink is not ready, caching event
            cachedEvent = message
        }
    }
}