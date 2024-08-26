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
            "lastKey": lastKey,
            "notices": data.map { $0.toMap() }
        ]
    }
}
fileprivate extension AppVisorSDK.AVPNoticesResponse {
    func lastKey() -> [String: String]? {
        guard let key = lastKey,
              let messageId = key.messageID.N,
              let userUUID = key.userUuid.S else { return nil }
        return [
            "messageId": messageId,
            "userUUID": userUUID
        ]
    }
}

fileprivate extension AppVisorSDK.AVPNotice {
    func toMap() -> [String: Any] {
        return [
            "messageId": messageId,
            "pushBody": pushBody,
            "pushTitle": pushTitle,
            "readStatus": readStatus,
            "timestamp": timestamp,
            "url": url,
            "userUUID": userUuid
        ]
    }
}
