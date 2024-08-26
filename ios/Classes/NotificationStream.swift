//
//  NotificationStreamHandler.swift
//  appvisor_flutter_sdk
//
//  Created by Kevin on 2024/05/24.
//

import Flutter

class NotificationStream: NSObject, FlutterStreamHandler {
    private var sink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
    
    func send(event: Any) {
        log("NotificationStream", "Sending event")
        sink?(event)
        log("NotificationStream", "Event sent")
    }
}
