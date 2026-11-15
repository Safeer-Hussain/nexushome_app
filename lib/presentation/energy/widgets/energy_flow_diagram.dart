import 'package:flutter/material.dart';

import '../../../domain/entities/energy_telemetry_entity.dart';

class EnergyFlowDiagram extends StatelessWidget {
  final EnergyTelemetryEntity telemetry;

  const EnergyFlowDiagram({super.key, required this.telemetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Directional Power Bus',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  telemetry.isGridExporting
                      ? 'NET EXPORTING'
                      : 'GRID IMPORTING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Flow Grid: Solar (Top Left), Home Load (Top Right), Battery (Bottom Left), Grid (Bottom Right)
          Row(
            children: [
              Expanded(
                child: _FlowNodeCard(
                  icon: Icons.solar_power_rounded,
                  title: 'Solar Generation',
                  value: '${telemetry.solarGenerationKw.toStringAsFixed(2)} kW',
                  accentColor: colorScheme.secondary,
                  arrowText: 'Flows to Home & Battery',
                  arrowDown: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FlowNodeCard(
                  icon: Icons.home_rounded,
                  title: 'Home Active Load',
                  value: '${telemetry.homeLoadKw.toStringAsFixed(2)} kW',
                  accentColor: colorScheme.primary,
                  arrowText: 'Live Demand',
                  arrowDown: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FlowNodeCard(
                  icon: Icons.battery_charging_full_rounded,
                  title: 'Home Battery Wall',
                  value: '${telemetry.batterySocPercent.toStringAsFixed(1)}%',
                  accentColor: colorScheme.tertiary,
                  arrowText: 'Buffer Optimal',
                  arrowDown: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FlowNodeCard(
                  icon: Icons.grid_goldenratio_rounded,
                  title: telemetry.isGridExporting
                      ? 'Grid Feed-in'
                      : 'Grid Import',
                  value: '${telemetry.gridFlowAbsKw.toStringAsFixed(2)} kW',
                  accentColor: telemetry.isGridExporting
                      ? colorScheme.primary
                      : colorScheme.error,
                  arrowText: telemetry.isGridExporting
                      ? 'Surplus Export'
                      : 'Peak Offset',
                  arrowDown: !telemetry.isGridExporting,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlowNodeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;
  final String arrowText;
  final bool arrowDown;

  const _FlowNodeCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accentColor,
    required this.arrowText,
    required this.arrowDown,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 22, color: accentColor),
              Icon(
                arrowDown
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 14,
                color: accentColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            arrowText,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
