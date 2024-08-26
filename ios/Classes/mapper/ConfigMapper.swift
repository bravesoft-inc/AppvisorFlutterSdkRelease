//
//  ConfigMapper.swift
//  appvisor_flutter_sdk
//
//  Created by Kevin on 2024/06/04.
//

import AppVisorSDK
extension [String: JSONValue] {
    func toMap() -> [String: Any] {
        var map = [String: Any]()
        for (key, value) in self {
            map[key] = value.toAny()
        }
        return map
    }
}


private extension JSONValue {
    func toAny()-> Any? {
        switch self {
        case .string(let string):
            return string
        case .double(let d):
            return d
        case .bool(let b):
            return b
        case .array(let array):
            return array.map { $0.toAny() }
        case .object(let object):
            return object.toMap()
        case .null:
            return nil
        case .int(let i):
            return i
        @unknown default:
            return nil
        }
    }
}
