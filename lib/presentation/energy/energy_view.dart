import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/energy_telemetry_entity.dart';
import '../providers/energy_provider.dart';
import 'widgets/energy_flow_diagram.dart';
import 'widgets/energy_chart.dart';
import 'widgets/power_consumers_list.dart';
import 'widgets/share_audit_sheet.dart';

class EnergyView extends ConsumerWidget {
  const EnergyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryAsync = ref.watch(energyTelemetryStreamProvider);
    final profile = ref.watch(hourlyEnergyProfileProvider);
    final consumers = ref.watch(topConsumersListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final telemetry =
        telemetryAsync.valueOrNull ??
        const EnergyTelemetryEntity(
          timestamp: 0,
          homeLoadWatts: 2400,
          solarGenerationWatts: 4200,
          batterySocPercent: 84.5,
          gridImportExportKw: -1.8,
          lineVoltageV: 230.2,
          threadMeshLatencyMs: 14,
        );

    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        if (isLandscape) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Pane: Energy Flow & Real-time Metrics
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Real-Time Telemetry Flow',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_outlined, size: 18),
                            onPressed: () =>
                                ShareAuditSheet.show(context, telemetry),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      EnergyFlowDiagram(telemetry: telemetry),
                      const SizedBox(height: 10),
                      PowerConsumersList(consumers: consumers),
                    ],
                  ),
                ),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              // Right Pane: Full-width Diurnal Chart & Audits
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [EnergyChart(profile: profile)],
                  ),
                ),
              ),
            ],
          );
        }

        // Portrait Layout
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Solar & Grid Telemetry',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Smart Meter 2-Second Pulse Stream',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: const Text('Audit Report'),
                    onPressed: () => ShareAuditSheet.show(context, telemetry),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              EnergyFlowDiagram(telemetry: telemetry),
              const SizedBox(height: 14),
              EnergyChart(profile: profile),
              const SizedBox(height: 14),
              PowerConsumersList(consumers: consumers),
            ],
          ),
        );
      },
    );
  }
}
