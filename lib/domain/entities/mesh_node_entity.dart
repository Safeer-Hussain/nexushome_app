class MeshNodeEntity {
  final String id;
  final String deviceId;
  final String nodeName;
  final String nodeType; // 'border_router', 'router', 'end_device'
  final String protocol; // 'Thread 1.3', 'Matter over Wi-Fi', 'BLE Mesh'
  final int rssi; // e.g., -45 dBm
  final int hopCount;
  final String status; // 'active', 'degraded', 'offline'
  final double xPos; // 0.0 - 1.0 relative
  final double yPos; // 0.0 - 1.0 relative
  final int updatedAt;

  const MeshNodeEntity({
    required this.id,
    required this.deviceId,
    required this.nodeName,
    required this.nodeType,
    required this.protocol,
    required this.rssi,
    required this.hopCount,
    required this.status,
    required this.xPos,
    required this.yPos,
    required this.updatedAt,
  });

  MeshNodeEntity copyWith({
    String? id,
    String? deviceId,
    String? nodeName,
    String? nodeType,
    String? protocol,
    int? rssi,
    int? hopCount,
    String? status,
    double? xPos,
    double? yPos,
    int? updatedAt,
  }) {
    return MeshNodeEntity(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      nodeName: nodeName ?? this.nodeName,
      nodeType: nodeType ?? this.nodeType,
      protocol: protocol ?? this.protocol,
      rssi: rssi ?? this.rssi,
      hopCount: hopCount ?? this.hopCount,
      status: status ?? this.status,
      xPos: xPos ?? this.xPos,
      yPos: yPos ?? this.yPos,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
