import 'package:flutter/foundation.dart';

class NoticeList {
  final List<Notice> notices;
  final LastKey? lastKey;

  const NoticeList({
    required this.notices,
    this.lastKey,
  });

  factory NoticeList.fromMap(Map<String, dynamic> map) {
    final lastKey =
        map['lastKey'] != null ? LastKey.fromMap(map['lastKey']) : null;
    var notices = <Notice>[];
    for (var notice in map['notices']) {
      notices.add(Notice.fromMap(Map<String, dynamic>.from(notice)));
    }
    return NoticeList(notices: notices, lastKey: lastKey);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NoticeList &&
        listEquals(other.notices, notices) &&
        other.lastKey == lastKey;
  }

  @override
  int get hashCode => notices.hashCode ^ lastKey.hashCode;

  @override
  String toString() => 'NoticeList(notices: $notices, lastKey: $lastKey)';
}

class Notice {
  final int messageId;
  final String pushBody;
  final String pushTitle;
  final bool readStatus;
  final int timestamp;
  final String url;
  final String userUUID;

  const Notice({
    required this.messageId,
    required this.pushBody,
    required this.pushTitle,
    required this.readStatus,
    required this.timestamp,
    required this.url,
    required this.userUUID,
  });

  factory Notice.fromMap(Map<String, dynamic> map) {
    return Notice(
      messageId: map['messageId'],
      pushBody: map['pushBody'],
      pushTitle: map['pushTitle'],
      readStatus: map['readStatus'],
      timestamp: map['timestamp'],
      url: map['url'],
      userUUID: map['userUUID'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Notice &&
        other.messageId == messageId &&
        other.pushBody == pushBody &&
        other.pushTitle == pushTitle &&
        other.readStatus == readStatus &&
        other.timestamp == timestamp &&
        other.url == url &&
        other.userUUID == userUUID;
  }

  @override
  int get hashCode {
    return messageId.hashCode ^
        pushBody.hashCode ^
        pushTitle.hashCode ^
        readStatus.hashCode ^
        timestamp.hashCode ^
        url.hashCode ^
        userUUID.hashCode;
  }

  @override
  String toString() {
    return 'Notice(messageId: $messageId, pushBody: $pushBody, pushTitle: $pushTitle, readStatus: $readStatus, timestamp: $timestamp, url: $url, userUUID: $userUUID)';
  }
}

class LastKey {
  final String messageId;
  final String userUUID;

  const LastKey({
    required this.messageId,
    required this.userUUID,
  });

  factory LastKey.fromMap(Map<String, dynamic> map) {
    return LastKey(
      messageId: map['messageId'],
      userUUID: map['userUUID'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LastKey &&
        other.messageId == messageId &&
        other.userUUID == userUUID;
  }

  @override
  int get hashCode => messageId.hashCode ^ userUUID.hashCode;

  @override
  String toString() => 'LastKey(messageId: $messageId, userUUID: $userUUID)';

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'userUUID': userUUID,
    };
  }
}
