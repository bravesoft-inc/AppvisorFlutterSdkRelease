class NotificationConfiguration {
  String channelName;
  String channelDescription;
  String smallIconName;
  String? largeIconName;

  NotificationConfiguration({
    required this.channelName,
    required this.channelDescription,
    required this.smallIconName,
    this.largeIconName
  });
}