//
//  AvpMethod.swift
//  appvisor_flutter_sdk
//
//  Created by Kevin on 2024/05/24.
//

enum PlatformMethod: String {
    case GetDeviceId
    case IsPushEnabled
    case Init
    case Configure
    case TogglePush
    case RequestAppReview
    case SetCustomProperty
    case SyncCustomProperties
    case GetCustomProperty
    case GetNotices
    case GetConfig
    case CheckForUpdate
    case MarkNoticeAsRead
}
