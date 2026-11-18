import 'dart:convert';

import '../../domain/entities/emergency_event.dart';

class EmergencyEventModel extends EmergencyEvent {
  const EmergencyEventModel({
    required super.id,
    required super.type,
    required super.severity,
    required super.sourceDeviceId,
    required super.sourceDeviceName,
    required super.room,
    required super.description,
    required super.timestamp,
    super.isResolved,
    required super.actionsExecuted,
  });

  factory EmergencyEventModel.fromMap(Map<String, dynamic> map) {
    return EmergencyEventModel(
      id: map['id'] as String,
      type: EmergencyType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => EmergencyType.smoke,
      ),
      severity: EmergencySeverity.values.firstWhere(
        (e) => e.name == map['severity'],
        orElse: () => EmergencySeverity.critical,
      ),
      sourceDeviceId: map['source_device_id'] as String,
      sourceDeviceName: map['source_device_name'] as String,
      room: map['room'] as String,
      description: map['description'] as String,
      timestamp: map['timestamp'] as int,
      isResolved: (map['is_resolved'] as int? ?? 0) == 1,
      actionsExecuted: List<String>.from(
        jsonDecode(map['actions_executed'] as String? ?? '[]') as List,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'source_device_id': sourceDeviceId,
      'source_device_name': sourceDeviceName,
      'room': room,
      'description': description,
      'timestamp': timestamp,
      'is_resolved': isResolved ? 1 : 0,
      'actions_executed': jsonEncode(actionsExecuted),
    };
  }

  factory EmergencyEventModel.fromEntity(EmergencyEvent entity) {
    return EmergencyEventModel(
      id: entity.id,
      type: entity.type,
      severity: entity.severity,
      sourceDeviceId: entity.sourceDeviceId,
      sourceDeviceName: entity.sourceDeviceName,
      room: entity.room,
      description: entity.description,
      timestamp: entity.timestamp,
      isResolved: entity.isResolved,
      actionsExecuted: entity.actionsExecuted,
    );
  }
}
