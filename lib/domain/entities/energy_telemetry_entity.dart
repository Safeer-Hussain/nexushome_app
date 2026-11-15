class EnergyTelemetryEntity {
  final int timestamp;
  final int homeLoadWatts;
  final int solarGenerationWatts;
  final double batterySocPercent;
  final double gridImportExportKw;
  final double lineVoltageV;
  final int threadMeshLatencyMs;

  const EnergyTelemetryEntity({
    required this.timestamp,
    required this.homeLoadWatts,
    required this.solarGenerationWatts,
    required this.batterySocPercent,
    required this.gridImportExportKw,
    required this.lineVoltageV,
    required this.threadMeshLatencyMs,
  });

  double get homeLoadKw => homeLoadWatts / 1000.0;
  double get solarGenerationKw => solarGenerationWatts / 1000.0;
  bool get isGridExporting => gridImportExportKw < 0;
  double get gridFlowAbsKw => gridImportExportKw.abs();
}
