import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/automation_rule_entity.dart';
import '../../providers/automation_provider.dart';

class CreateRuleSheet extends ConsumerStatefulWidget {
  const CreateRuleSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const CreateRuleSheet(),
    );
  }

  @override
  ConsumerState<CreateRuleSheet> createState() => _CreateRuleSheetState();
}

class _CreateRuleSheetState extends ConsumerState<CreateRuleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  String _triggerType = 'Time of Day';
  String _triggerValue = '22:00';
  String _actionType = 'Turn Off All Lighting';
  final String _actionTarget = 'All Zones';

  final List<Map<String, String>> _triggers = [
    {'type': 'Time of Day', 'defaultVal': '22:00'},
    {'type': 'Indoor Temp Threshold > 26°C', 'defaultVal': '26.0'},
    {'type': 'Battery SoC % < 20%', 'defaultVal': '20%'},
    {'type': 'Sunset / Sunrise Detection', 'defaultVal': 'sunset'},
  ];

  final List<String> _actions = [
    'Turn Off All Lighting',
    'Set Eco HVAC to 24.5°C',
    'Arm Perimeter Smart Deadbolts',
    'Close Panoramic Blinds 100%',
    'Activate Cinema Ambient Lighting',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final rule = AutomationRuleEntity(
      id: 'rule_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      triggerType: _triggerType,
      triggerValue: _triggerValue,
      actionType: _actionType,
      actionTarget: _actionTarget,
      isEnabled: true,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    ref.read(rulesListProvider.notifier).createRule(rule);
    Navigator.pop(context);
    AppFeedback.showSuccess(
      context,
      'Automation Rule "${rule.title}" created & armed locally in SQLite.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Create IF-THEN Automation Rule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Autonomous event-action triggers processed locally with 0ms cloud lag.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Rule Title',
                    hintText: 'e.g. Nightfall Security Sweep',
                    prefixIcon: const Icon(Icons.title_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Rule title is required.';
                    }
                    if (value.trim().length < 3) {
                      return 'Title must be at least 3 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _triggerType,
                  decoration: InputDecoration(
                    labelText: 'IF Trigger Condition',
                    prefixIcon: const Icon(Icons.flash_on_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _triggers
                      .map(
                        (t) => DropdownMenuItem(
                          value: t['type'],
                          child: Text(t['type']!),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _triggerType = val;
                        _triggerValue = _triggers.firstWhere(
                          (t) => t['type'] == val,
                        )['defaultVal']!;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _actionType,
                  decoration: InputDecoration(
                    labelText: 'THEN Action Execution',
                    prefixIcon: const Icon(Icons.play_arrow_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _actions
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _actionType = val);
                  },
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.bolt_rounded),
                    label: const Text(
                      'Save & Activate Rule',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
