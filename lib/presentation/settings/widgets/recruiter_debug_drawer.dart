import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_feedback.dart';
import '../../providers/recruiter_debug_provider.dart';
import '../../providers/security_provider.dart';

class RecruiterDebugDrawer extends ConsumerWidget {
  const RecruiterDebugDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debugState = ref.watch(recruiterDebugProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.bug_report_rounded,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recruiter Debug Drawer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Hardware & Mesh Fault Injection',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              Text(
                'Simulated Local Network Latency',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transit Delay',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${debugState.simulatedLatencyMs} ms',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: debugState.simulatedLatencyMs.toDouble(),
                min: 100,
                max: 1500,
                divisions: 14,
                activeColor: colorScheme.primary,
                onChanged: (val) {
                  ref
                      .read(recruiterDebugProvider.notifier)
                      .setLatency(val.round());
                },
              ),
              const SizedBox(height: 14),
              Card(
                color: colorScheme.surfaceContainer,
                child: SwitchListTile(
                  title: Text(
                    'Force HTTP 503 Cloud Outage',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Simulates cloud disconnection to test offline SQLite autonomy',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: debugState.force503CloudOutage,
                  onChanged: (_) {
                    ref.read(recruiterDebugProvider.notifier).toggle503Outage();
                    AppFeedback.showWarning(
                      context,
                      debugState.force503CloudOutage
                          ? 'HTTP 503 Simulation Cleared. Cloud-sync restored.'
                          : 'HTTP 503 Outage Injected: App running in zero-cloud local mode.',
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: colorScheme.surfaceContainer,
                child: SwitchListTile(
                  title: Text(
                    'Simulate Peak Tariff Spike',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Injects \$0.48/kWh critical rate alert',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: debugState.peakTariffSpikeActive,
                  onChanged: (_) {
                    ref
                        .read(recruiterDebugProvider.notifier)
                        .togglePeakTariff();
                    AppFeedback.showInfo(
                      context,
                      debugState.peakTariffSpikeActive
                          ? 'Peak tariff cleared.'
                          : 'Peak tariff spike triggered! Eco savings scene recommended.',
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Instant Event Injections',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.motion_photos_on_outlined, size: 16),
                  label: const Text('Inject PIR Motion Event'),
                  onPressed: () {
                    ref
                        .read(securityEventsProvider.notifier)
                        .triggerAlert(
                          title: 'Living Room PIR Motion Injected',
                          deviceName: 'Radar PIR Sensor',
                          room: 'Living Room',
                          severity: 'warning',
                        );
                    AppFeedback.showWarning(
                      context,
                      'Injected motion event to security feed.',
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.battery_alert_outlined, size: 16),
                  label: const Text('Inject Battery Discharge Alert'),
                  onPressed: () {
                    ref
                        .read(securityEventsProvider.notifier)
                        .triggerAlert(
                          title: 'Battery Wall Threshold 15% Reached',
                          deviceName: 'Solar Inverter Hub',
                          room: 'Solar Garage',
                          severity: 'alert',
                        );
                    AppFeedback.showError(
                      context,
                      'Injected critical battery alert to sentinel.',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
