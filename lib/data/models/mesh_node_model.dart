import '../../domain/entities/mesh_node_entity.dart';

class MeshNodeModel extends MeshNodeEntity {
  const MeshNodeModel({
    required super.id,
    required super.deviceId,
    required super.nodeName,
    required super.nodeType,
    required super.protocol,
    required super.rssi,
    required super.hopCount,
    required super.status,
    required super.xPos,
    required super.yPos,
    required super.updatedAt,
  });

  factory MeshNodeModel.fromMap(Map<String, dynamic> map) {
    return MeshNodeModel(
      id: map['id'] as String,
      deviceId: map['device_id'] as String,
      nodeName: map['node_name'] as String,
      nodeType: map['node_type'] as String,
      protocol: map['protocol'] as String,
      rssi: map['rssi'] as int? ?? -50,
      hopCount: map['hop_count'] as int? ?? 1,
      status: map['status'] as String? ?? 'active',
      xPos: (map['x_pos'] as num?)?.toDouble() ?? 0.5,
      yPos: (map['y_pos'] as num?)?.toDouble() ?? 0.5,
      updatedAt:
          map['updated_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'node_name': nodeName,
      'node_type': nodeType,
      'protocol': protocol,
      'rssi': rssi,
      'hop_count': hopCount,
      'status': status,
      'x_pos': xPos,
      'y_pos': yPos,
      'updated_at': updatedAt,
    };
  }

  factory MeshNodeModel.fromEntity(MeshNodeEntity entity) {
    return MeshNodeModel(
      id: entity.id,
      deviceId: entity.deviceId,
      nodeName: entity.nodeName,
      nodeType: entity.nodeType,
      protocol: entity.protocol,
      rssi: entity.rssi,
      hopCount: entity.hopCount,
      status: entity.status,
      xPos: entity.xPos,
      yPos: entity.yPos,
      updatedAt: entity.updatedAt,
    );
  }
}
