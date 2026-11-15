import '../../domain/entities/energy_telemetry_entity.dart';

class EnergyTelemetryModel extends EnergyTelemetryEntity {
  const EnergyTelemetryModel({
    required super.timestamp,
    required super.homeLoadWatts,
    required super.solarGenerationWatts,
    required super.batterySocPercent,
    required super.gridImportExportKw,
    required super.lineVoltageV,
    required super.threadMeshLatencyMs,
  });

  factory EnergyTelemetryModel.fromMap(Map<String, dynamic> map) {
    return EnergyTelemetryModel(
      timestamp:
          map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      homeLoadWatts: map['homeLoadWatts'] as int? ?? 2400,
      solarGenerationWatts: map['solarGenerationWatts'] as int? ?? 4200,
      batterySocPercent: (map['batterySocPercent'] as num?)?.toDouble() ?? 85.0,
      gridImportExportKw:
          (map['gridImportExportKw'] as num?)?.toDouble() ?? -1.8,
      lineVoltageV: (map['lineVoltageV'] as num?)?.toDouble() ?? 230.0,
      threadMeshLatencyMs: map['threadMeshLatencyMs'] as int? ?? 14,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'homeLoadWatts': homeLoadWatts,
      'solarGenerationWatts': solarGenerationWatts,
      'batterySocPercent': batterySocPercent,
      'gridImportExportKw': gridImportExportKw,
      'lineVoltageV': lineVoltageV,
      'threadMeshLatencyMs': threadMeshLatencyMs,
    };
  }
}
