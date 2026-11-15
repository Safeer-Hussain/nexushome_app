import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/device_provider.dart';
import '../../providers/security_provider.dart';

class EnvironmentBar extends ConsumerWidget {
  const EnvironmentBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceListProvider);
    final securityMode = ref.watch(securityModeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final activeCount = devices.where((d) => d.isPowered).length;

    // Calculate average room temp from active temperature sensors
    double avgTemp = 22.4;
    final hvacs = devices.where((d) => d.type == 'hvac' || d.type == 'sensor');
    if (hvacs.isNotEmpty) {
      avgTemp =
          hvacs.fold<double>(0.0, (acc, d) => acc + d.currentTemp) /
          hvacs.length;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 500;

          final items = [
            _MetricItem(
              icon: Icons.thermostat_rounded,
              label: 'Temp',
              value: '${avgTemp.toStringAsFixed(1)}°C',
              color: colorScheme.secondary,
            ),
            _MetricItem(
              icon: Icons.water_drop_outlined,
              label: 'Humidity',
              value: '48%',
              color: colorScheme.tertiary,
            ),
            _MetricItem(
              icon: Icons.air_rounded,
              label: 'AQI',
              value: '28 (Good)',
              color: colorScheme.primary,
            ),
            _MetricItem(
              icon: Icons.shield_outlined,
              label: 'Security',
              value: securityMode,
              color: securityMode.contains('Armed')
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            _MetricItem(
              icon: Icons.power_rounded,
              label: 'Active',
              value: '$activeCount / ${devices.length}',
              color: colorScheme.primary,
            ),
          ];

          if (isCompact) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: item,
                      ),
                    )
                    .toList(),
              ),
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items,
          );
        },
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
