import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/scene_entity.dart';
import '../../providers/automation_provider.dart';
import 'create_rule_sheet.dart';

class ScenesTab extends ConsumerWidget {
  const ScenesTab({super.key});

  IconData _getSceneIcon(String iconName) {
    switch (iconName) {
      case 'wb_sunny_rounded':
        return Icons.wb_sunny_rounded;
      case 'shield_rounded':
        return Icons.shield_rounded;
      case 'movie_filter_rounded':
        return Icons.movie_filter_rounded;
      case 'energy_savings_leaf_rounded':
        return Icons.energy_savings_leaf_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(scenesListProvider);
    final rules = ref.watch(rulesListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 84),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sanctuary Quick Scenes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '1-Tap multi-device orchestrations executed via local SQLite & Thread mesh.',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent:
                  140, // Explicit mainAxisExtent avoids RenderFlex overflow
            ),
            itemCount: scenes.length,
            itemBuilder: (context, index) {
              final scene = scenes[index];
              return _buildSceneCard(context, ref, scene, colorScheme);
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IF-THEN Automation Rules (${rules.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Zero-cloud local rule engine',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Rule'),
                onPressed: () => CreateRuleSheet.show(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rules.map((rule) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: colorScheme.surfaceContainer,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: rule.isEnabled
                        ? colorScheme.primary.withValues(alpha: 0.15)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    size: 20,
                    color: rule.isEnabled
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                title: Text(
                  rule.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'IF: ${rule.triggerType} -> THEN: ${rule.actionType}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: rule.isEnabled,
                      onChanged: (_) {
                        ref
                            .read(rulesListProvider.notifier)
                            .toggleRule(rule.id);
                        AppFeedback.showInfo(
                          context,
                          'Rule "${rule.title}" ${!rule.isEnabled ? "Armed" : "Disarmed"}.',
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      onPressed: () {
                        ref
                            .read(rulesListProvider.notifier)
                            .deleteRule(rule.id);
                        AppFeedback.showWarning(context, 'Rule removed.');
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSceneCard(
    BuildContext context,
    WidgetRef ref,
    SceneEntity scene,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await ref.read(scenesListProvider.notifier).executeScene(scene);
          if (context.mounted) {
            AppFeedback.showSuccess(
              context,
              'Scene "${scene.title}" executed across all target zones.',
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getSceneIcon(scene.iconName),
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  Icon(
                    Icons.play_circle_filled_rounded,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    scene.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    scene.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
