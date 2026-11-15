class AutomationRuleEntity {
  final String id;
  final String title;
  final String triggerType;
  final String triggerValue;
  final String actionType;
  final String actionTarget;
  final bool isEnabled;
  final int createdAt;

  const AutomationRuleEntity({
    required this.id,
    required this.title,
    required this.triggerType,
    required this.triggerValue,
    required this.actionType,
    required this.actionTarget,
    required this.isEnabled,
    required this.createdAt,
  });

  AutomationRuleEntity copyWith({
    String? id,
    String? title,
    String? triggerType,
    String? triggerValue,
    String? actionType,
    String? actionTarget,
    bool? isEnabled,
    int? createdAt,
  }) {
    return AutomationRuleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      triggerType: triggerType ?? this.triggerType,
      triggerValue: triggerValue ?? this.triggerValue,
      actionType: actionType ?? this.actionType,
      actionTarget: actionTarget ?? this.actionTarget,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
