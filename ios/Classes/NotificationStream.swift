//
//  NotificationStreamHandler.swift
//  appvisor_flutter_sdk
//
//  Created by Kevin on 2024/05/24.
//

import Flutter

fileprivate let tag = "NotificationStream"

class NotificationStream: NSObject, FlutterStreamHandler {
    private var sink: FlutterEventSink?
    private var cachedEvent: Any?
    private let flutterListenerAttachDelay: TimeInterval = 0.3
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        if let event = cachedEvent {
            log(tag, "Delaying sending cached event by 300ms")
            DispatchQueue.main.asyncAfter(deadline: .now() + flutterListenerAttachDelay) {
                log(tag, "Sending cached event after delay")
                events(event)
            }
            cachedEvent = nil
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
    
    func send(event: Any) {
        log(tag, "Sending event")
        if let sink = sink {
            sink(event)
            log(tag, "Event sent")
        } else {
            log(tag, "Sink not ready, caching event")
            cachedEvent = event
        }
    }
}
