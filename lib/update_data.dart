class UpdateData {
  final String storeUrl;
  final bool optional;

  UpdateData({
    required this.storeUrl,
    required this.optional,
  });

  static UpdateData fromMap(Map<String, dynamic> map) {
    return UpdateData(
      storeUrl: map['storeUrl'] as String,
      optional: map['optional'] as bool,
    );
  }
}
