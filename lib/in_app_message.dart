enum InAppMessageStatus {
  shown('SHOWN'),
  expired('EXPIRED'),
  notPublished('NOT_PUBLISHED'),
  notFound('NOT_FOUND');

  const InAppMessageStatus(this.value);

  final String value;

  static InAppMessageStatus fromString(String value) {
    return InAppMessageStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => InAppMessageStatus.notFound,
    );
  }
}

class InAppMessageData {
  final InAppMessageStatus status;

  const InAppMessageData({
    required this.status,
  });

  static InAppMessageData fromMap(Map<String, dynamic> map) {
    final status = map['status'];
    return InAppMessageData(
      status: InAppMessageStatus.fromString(status is String ? status : ''),
    );
  }
}
