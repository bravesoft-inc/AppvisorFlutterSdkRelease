class NotificationConfiguration {
  String channelName;
  String? channelDescription;
  String smallIconName;
  String? largeIconName;

  NotificationConfiguration({
    required this.channelName,
    this.channelDescription,
    required this.smallIconName,
    this.largeIconName
  });
}