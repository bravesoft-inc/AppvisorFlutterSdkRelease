//
//  Mapper.swift
//  appvisor_flutter_sdk
//
//  Created by Kevin on 2024/06/03.
//
import AppVisorSDK

extension AppVisorSDK.AVPNoticesResponse {
    func toMap() -> [String: Any?] {
        return [
            "lastKey": lastKeyToMap(),
            "notices": data.map { $0.toMap() },
        ]
    }
}
extension AppVisorSDK.AVPNoticesResponse {
    fileprivate func lastKeyToMap() -> [String: String]? {
        guard let key = lastKey,
            let messageId = key.messageId.N,
            let userUUID = key.userUuid.S
        else { return nil }
        return [
            "messageId": messageId,
            "userUUID": userUUID,
        ]
    }
}

extension AppVisorSDK.AVPNotice {
    fileprivate func toMap() -> [String: Any?] {
        return [
            "messageId": messageId,
            "pushBody": pushBody,
            "pushTitle": pushTitle,
            "readStatus": readStatus,
            "timestamp": timestamp,
            "url": url,
            "userUUID": userUuid,
            "parameterW": parameterW,
            "parameterX": parameterX,
            "parameterY": parameterY,
            "parameterZ": parameterZ,
        ]
    }
}
