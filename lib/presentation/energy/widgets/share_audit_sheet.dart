import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/energy_telemetry_entity.dart';

class ShareAuditSheet extends StatelessWidget {
  final EnergyTelemetryEntity telemetry;

  const ShareAuditSheet({super.key, required this.telemetry});

  static Future<void> show(
    BuildContext context,
    EnergyTelemetryEntity telemetry,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ShareAuditSheet(telemetry: telemetry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final summaryText =
        '''
NexusHome Sanctuary Energy Audit
Timestamp: ${DateTime.now().toIso8601String()}
Solar Roof Generation: ${telemetry.solarGenerationKw.toStringAsFixed(2)} kW
Total Home Active Load: ${telemetry.homeLoadKw.toStringAsFixed(2)} kW
Home Battery Wall SoC: ${telemetry.batterySocPercent}%
Grid Net Balance: ${telemetry.gridImportExportKw} kW (${telemetry.isGridExporting ? "Exporting" : "Importing"})
Line Voltage: ${telemetry.lineVoltageV} V
Thread Mesh Latency: ${telemetry.threadMeshLatencyMs} ms
Protocol: Matter 1.3 over Thread Mesh (Zero-Cloud Offline)
''';

    final jsonData = jsonEncode({
      'auditReport': 'NexusHome',
      'generatedAt': DateTime.now().toIso8601String(),
      'metrics': {
        'solarKw': telemetry.solarGenerationKw,
        'homeLoadKw': telemetry.homeLoadKw,
        'batterySocPercent': telemetry.batterySocPercent,
        'gridBalanceKw': telemetry.gridImportExportKw,
        'lineVoltageV': telemetry.lineVoltageV,
        'threadLatencyMs': telemetry.threadMeshLatencyMs,
      },
    });

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
                'Share & Export Energy Audit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'Export local Matter telemetry packets and solar offset audits.',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  summaryText.trim(),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy Summary'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: summaryText));
                        Navigator.pop(context);
                        AppFeedback.showSuccess(
                          context,
                          'Energy summary copied to clipboard.',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.file_download_outlined, size: 16),
                      label: const Text('Export JSON'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: jsonData));
                        Navigator.pop(context);
                        AppFeedback.showSuccess(
                          context,
                          'JSON telemetry package exported to clipboard.',
                        );
                      },
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
