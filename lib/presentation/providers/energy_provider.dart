import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection.dart';
import '../../data/repositories/energy_repository.dart';
import '../../domain/entities/energy_telemetry_entity.dart';

final energyTelemetryStreamProvider =
    StreamProvider.autoDispose<EnergyTelemetryEntity>((ref) {
      final repo = getIt<EnergyRepository>();
      return repo.getTelemetryStream();
    });

final hourlyEnergyProfileProvider = Provider<List<EnergyHourlyDataPoint>>((
  ref,
) {
  final repo = getIt<EnergyRepository>();
  return repo.get24HourEnergyProfile();
});

final topConsumersListProvider = Provider<List<PowerConsumerItem>>((ref) {
  final repo = getIt<EnergyRepository>();
  return repo.getTopConsumers();
});

final energyCurrencyProvider = StateProvider<String>((ref) => 'USD');
