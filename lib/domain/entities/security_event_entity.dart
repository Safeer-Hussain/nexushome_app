class SecurityEventEntity {
  final String id;
  final String title;
  final String deviceId;
  final String deviceName;
  final String room;
  final String severity; // 'info', 'warning', 'alert'
  final int timestamp;

  const SecurityEventEntity({
    required this.id,
    required this.title,
    required this.deviceId,
    required this.deviceName,
    required this.room,
    required this.severity,
    required this.timestamp,
  });
}
