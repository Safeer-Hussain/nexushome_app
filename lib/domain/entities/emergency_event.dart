enum EmergencyType { smoke, waterLeak, coAlarm, intrusion }

enum EmergencySeverity { critical, high, warning }

class EmergencyEvent {
  final String id;
  final EmergencyType type;
  final EmergencySeverity severity;
  final String sourceDeviceId;
  final String sourceDeviceName;
  final String room;
  final String description;
  final int timestamp;
  final bool isResolved;
  final List<String> actionsExecuted;

  const EmergencyEvent({
    required this.id,
    required this.type,
    required this.severity,
    required this.sourceDeviceId,
    required this.sourceDeviceName,
    required this.room,
    required this.description,
    required this.timestamp,
    this.isResolved = false,
    required this.actionsExecuted,
  });

  EmergencyEvent copyWith({
    String? id,
    EmergencyType? type,
    EmergencySeverity? severity,
    String? sourceDeviceId,
    String? sourceDeviceName,
    String? room,
    String? description,
    int? timestamp,
    bool? isResolved,
    List<String>? actionsExecuted,
  }) {
    return EmergencyEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      sourceDeviceName: sourceDeviceName ?? this.sourceDeviceName,
      room: room ?? this.room,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isResolved: isResolved ?? this.isResolved,
      actionsExecuted: actionsExecuted ?? this.actionsExecuted,
    );
  }
}
