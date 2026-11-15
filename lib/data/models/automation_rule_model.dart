import '../../domain/entities/automation_rule_entity.dart';

class AutomationRuleModel extends AutomationRuleEntity {
  const AutomationRuleModel({
    required super.id,
    required super.title,
    required super.triggerType,
    required super.triggerValue,
    required super.actionType,
    required super.actionTarget,
    required super.isEnabled,
    required super.createdAt,
  });

  factory AutomationRuleModel.fromMap(Map<String, dynamic> map) {
    return AutomationRuleModel(
      id: map['id'] as String,
      title: map['title'] as String,
      triggerType: map['trigger_type'] as String,
      triggerValue: map['trigger_value'] as String,
      actionType: map['action_type'] as String,
      actionTarget: map['action_target'] as String,
      isEnabled: (map['is_enabled'] as int) == 1,
      createdAt:
          map['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'trigger_type': triggerType,
      'trigger_value': triggerValue,
      'action_type': actionType,
      'action_target': actionTarget,
      'is_enabled': isEnabled ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory AutomationRuleModel.fromEntity(AutomationRuleEntity entity) {
    return AutomationRuleModel(
      id: entity.id,
      title: entity.title,
      triggerType: entity.triggerType,
      triggerValue: entity.triggerValue,
      actionType: entity.actionType,
      actionTarget: entity.actionTarget,
      isEnabled: entity.isEnabled,
      createdAt: entity.createdAt,
    );
  }
}
