//
//  UpdateMapper.swift
//  appvisor_flutter_sdk
//
//  Created by Kevin on 2024/06/04.
//
import AppVisorSDK

extension AVPAppUpdateResponse {
    func toMap() -> [String: Any] {
        return [
            "storeUrl": storeUrl,
            "optional": updateOptionalFlg
        ]
    }
}
