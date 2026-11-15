import '../../domain/entities/security_event_entity.dart';

class SecurityEventModel extends SecurityEventEntity {
  const SecurityEventModel({
    required super.id,
    required super.title,
    required super.deviceId,
    required super.deviceName,
    required super.room,
    required super.severity,
    required super.timestamp,
  });

  factory SecurityEventModel.fromMap(Map<String, dynamic> map) {
    return SecurityEventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      deviceId: map['device_id'] as String,
      deviceName: map['device_name'] as String,
      room: map['room'] as String,
      severity: map['severity'] as String? ?? 'info',
      timestamp:
          map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'device_id': deviceId,
      'device_name': deviceName,
      'room': room,
      'severity': severity,
      'timestamp': timestamp,
    };
  }
}
