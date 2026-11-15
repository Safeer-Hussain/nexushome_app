import 'package:flutter/material.dart';

class PromptShortcuts extends StatelessWidget {
  final void Function(String prompt) onSelect;

  const PromptShortcuts({super.key, required this.onSelect});

  static const List<Map<String, dynamic>> shortcuts = [
    {
      'label': 'Audit Vampire Standby Draw',
      'prompt': 'Audit Vampire Standby Power Draw',
      'icon': Icons.bolt_rounded,
    },
    {
      'label': 'Optimize HVAC Peak Tariffs',
      'prompt': 'Optimize HVAC Schedule for Peak Tariffs',
      'icon': Icons.thermostat_auto_rounded,
    },
    {
      'label': 'Suggest Efficiency Rule',
      'prompt': 'Suggest New Energy-Saving Automation Rule',
      'icon': Icons.energy_savings_leaf_outlined,
    },
    {
      'label': 'Inspect Mesh Signal Health',
      'prompt': 'Inspect Thread Mesh Signal Health',
      'icon': Icons.hub_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: shortcuts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = shortcuts[index];
          return ActionChip(
            avatar: Icon(
              item['icon'] as IconData,
              size: 14,
              color: colorScheme.primary,
            ),
            label: Text(
              item['label'] as String,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            backgroundColor: colorScheme.surfaceContainer,
            side: BorderSide(color: colorScheme.outlineVariant, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            onPressed: () => onSelect(item['prompt'] as String),
          );
        },
      ),
    );
  }
}
