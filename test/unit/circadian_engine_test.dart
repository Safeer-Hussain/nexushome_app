import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_home_app/domain/entities/circadian_state.dart';
import 'package:nexus_home_app/presentation/providers/circadian_provider.dart';
import 'package:nexus_home_app/presentation/providers/device_provider.dart';

import '../helpers/mock_repositories.dart';

void main() {
  group('AstronomicalSolarCalculator Unit Tests', () {
    test('Calculates warm amber (2700K) during deep solar night', () {
      // 08:10 UTC corresponds to ~00:00 solar midnight in San Francisco (-122.4W)
      final midnight = DateTime.utc(2026, 6, 21, 8, 10, 0);
      final state = AstronomicalSolarCalculator.calculate(
        time: midnight,
        latitude: 37.7749,
        longitude: -122.4194,
      );

      expect(state.targetKelvin, equals(2700));
      expect(state.phase, equals(CircadianPhase.solarNight));
      expect(state.solarElevation, lessThan(-12.0));
      expect(state.targetBrightness, equals(30));
    });

    test('Calculates crisp daylight (~5500K) at solar noon zenith', () {
      // 20:10 UTC corresponds to ~12:00 solar noon zenith in San Francisco (-122.4W)
      final solarNoon = DateTime.utc(2026, 6, 21, 20, 10, 0);
      final state = AstronomicalSolarCalculator.calculate(
        time: solarNoon,
        latitude: 37.7749,
        longitude: -122.4194,
      );

      expect(state.targetKelvin, greaterThanOrEqualTo(5400));
      expect(state.solarElevation, greaterThan(60.0));
      expect(state.targetBrightness, equals(100));
    });

    test('Transitions smoothly during sunset / twilight transition', () {
      // 03:45 UTC corresponds to sunset/twilight in San Francisco (-122.4W)
      final evening = DateTime.utc(2026, 6, 21, 3, 45, 0);
      final state = AstronomicalSolarCalculator.calculate(
        time: evening,
        latitude: 37.7749,
        longitude: -122.4194,
      );

      // Between 2700K amber and 5500K peak
      expect(state.targetKelvin, greaterThanOrEqualTo(2700));
      expect(state.targetKelvin, lessThan(5400));
    });
  });

  group('CircadianNotifier Riverpod Provider Tests', () {
    late FakeDeviceRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeDeviceRepository();
      container = ProviderContainer(
        overrides: [
          deviceListProvider.overrideWith(
            (ref) => DeviceListNotifier(repository),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initializes with active auto-sync and valid astronomical state', () {
      final circadian = container.read(circadianProvider);
      expect(circadian.isAutoSyncEnabled, isTrue);
      expect(circadian.state.targetKelvin, inInclusiveRange(2700, 5500));
      expect(circadian.state.phaseTitle.isNotEmpty, isTrue);
    });

    test('Toggles auto-sync state on and off', () {
      final notifier = container.read(circadianProvider.notifier);
      expect(container.read(circadianProvider).isAutoSyncEnabled, isTrue);

      notifier.toggleAutoSync();
      expect(container.read(circadianProvider).isAutoSyncEnabled, isFalse);

      notifier.toggleAutoSync();
      expect(container.read(circadianProvider).isAutoSyncEnabled, isTrue);
    });

    test(
      'evaluateNow batch-dispatches target Kelvin to circadian lights',
      () async {
        await container.read(deviceListProvider.notifier).loadDevices();

        // Simulate noon evaluation (20:10 UTC in SF is ~12:00 solar noon -> 5500K)
        final noonTime = DateTime.utc(2026, 6, 21, 20, 10, 0);
        final notifier = container.read(circadianProvider.notifier);
        await notifier.evaluateNow(simulatedTime: noonTime);

        final devices = container.read(deviceListProvider);
        final lights = devices
            .where((d) => d.type == 'light' && d.circadianModeEnabled)
            .toList();

        expect(lights.isNotEmpty, isTrue);
        for (final light in lights) {
          expect(light.colorTemp, greaterThanOrEqualTo(5400));
        }
      },
    );
  });
}
