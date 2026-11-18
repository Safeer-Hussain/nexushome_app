import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/emergency_event.dart';
import '../../providers/emergency_provider.dart';

class EmergencyAlertBanner extends ConsumerWidget {
  const EmergencyAlertBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyState = ref.watch(emergencyProvider);
    final active = emergencyState.activeEmergency;

    if (active == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    final IconData icon;
    switch (active.type) {
      case EmergencyType.smoke:
        icon = Icons.local_fire_department_rounded;
        break;
      case EmergencyType.waterLeak:
        icon = Icons.water_damage_rounded;
        break;
      case EmergencyType.coAlarm:
        icon = Icons.masks_rounded;
        break;
      case EmergencyType.intrusion:
        icon = Icons.security_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.error, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: colorScheme.onError),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CRITICAL EMERGENCY OVERRIDE ACTIVE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                    Text(
                      active.description,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onErrorContainer.withValues(
                          alpha: 0.9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Dismiss Alert',
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colorScheme.onErrorContainer,
                ),
                onPressed: () {
                  ref
                      .read(emergencyProvider.notifier)
                      .dismissEmergency(active.id);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ActionPill(
                  icon: Icons.lock_open_rounded,
                  label: 'Exit Doors: UNLOCKED',
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 6),
                _ActionPill(
                  icon: Icons.wb_incandescent_rounded,
                  label: 'Lighting: 2700K AMBER',
                  colorScheme: colorScheme,
                ),
                if (active.type == EmergencyType.waterLeak) ...[
                  const SizedBox(width: 6),
                  _ActionPill(
                    icon: Icons.plumbing_rounded,
                    label: 'Main Water: SHUT OFF',
                    colorScheme: colorScheme,
                  ),
                ],
                const SizedBox(width: 6),
                _ActionPill(
                  icon: Icons.timer_outlined,
                  label: 'Latency: ${emergencyState.executionLatencyMs}ms',
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.error),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
