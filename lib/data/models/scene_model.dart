import '../../domain/entities/scene_entity.dart';

class SceneModel extends SceneEntity {
  const SceneModel({
    required super.id,
    required super.title,
    required super.description,
    required super.iconName,
    required super.deviceActionsJson,
  });

  factory SceneModel.fromMap(Map<String, dynamic> map) {
    return SceneModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      iconName: map['icon_name'] as String,
      deviceActionsJson: map['device_actions_json'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_name': iconName,
      'device_actions_json': deviceActionsJson,
    };
  }
}
