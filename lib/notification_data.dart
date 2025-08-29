
class NotificationData {
  final String? title;
  final String message;
  final String? w;
  final String? x;
  final String? y;
  final String? z;

  NotificationData({
    required this.message,
    this.title,
    this.w,
    this.x,
    this.y,
    this.z,
  });

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      title: map['title'],
      message: map['message'],
      w: map['w'],
      x: map['x'],
      y: map['y'],
      z: map['z'],
    );
  }

  @override
  String toString() {
    return 'NotificationData{title: $title, message: $message, w: $w, x: $x, y: $y, z: $z}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationData &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          message == other.message &&
          w == other.w &&
          x == other.x &&
          y == other.y &&
          z == other.z;

  @override
  int get hashCode =>
      title.hashCode ^
      message.hashCode ^
      w.hashCode ^
      x.hashCode ^
      y.hashCode ^
      z.hashCode;
}
