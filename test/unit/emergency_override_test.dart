import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_home_app/data/models/device_model.dart';
import 'package:nexus_home_app/domain/entities/emergency_event.dart';
import 'package:nexus_home_app/presentation/providers/device_provider.dart';
import 'package:nexus_home_app/presentation/providers/emergency_provider.dart';

import '../helpers/mock_repositories.dart';

void main() {
  group('Emergency Override Pipeline Unit Tests', () {
    late FakeDeviceRepository deviceRepo;
    late FakeEmergencyRepository emergencyRepo;
    late ProviderContainer container;

    setUp(() {
      final now = DateTime.now().millisecondsSinceEpoch;
      final initialDevices = [
        DeviceModel(
          id: 'dev_front_door',
          name: 'Front Portal Deadbolt',
          room: 'Living Room',
          type: 'lock',
          protocol: 'Thread 1.3',
          isPowered: true,
          isLocked: true,
          updatedAt: now,
        ),
        DeviceModel(
          id: 'dev_patio_door',
          name: 'Patio Slider Lock',
          room: 'Living Room',
          type: 'lock',
          protocol: 'Thread 1.3',
          isPowered: true,
          isLocked: true,
          updatedAt: now,
        ),
        DeviceModel(
          id: 'dev_living_light',
          name: 'Living Luminaire',
          room: 'Living Room',
          type: 'light',
          protocol: 'Thread 1.3',
          isPowered: true,
          brightness: 50,
          colorTemp: 4000,
          updatedAt: now,
        ),
        DeviceModel(
          id: 'dev_kitchen_light',
          name: 'Kitchen Array',
          room: 'Kitchen',
          type: 'light',
          protocol: 'Thread 1.3',
          isPowered: false,
          brightness: 0,
          colorTemp: 3500,
          updatedAt: now,
        ),
        DeviceModel(
          id: 'dev_main_water_valve',
          name: 'Main Water Shutoff Valve',
          room: 'Solar Garage',
          type: 'valve',
          protocol: 'Thread 1.3',
          isPowered: true,
          isLocked: false, // Open
          position: 100,
          updatedAt: now,
        ),
      ];

      deviceRepo = FakeDeviceRepository(initialDevices);
      emergencyRepo = FakeEmergencyRepository();

      container = ProviderContainer(
        overrides: [
          deviceListProvider.overrideWith(
            (ref) => DeviceListNotifier(deviceRepo),
          ),
          emergencyRepositoryProvider.overrideWithValue(emergencyRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Smoke emergency unlocks all exit deadbolts and drives lights to 2700K amber within 50ms', () async {
      await container.read(deviceListProvider.notifier).loadDevices();

      // Verify initial state: both doors locked
      final initialDoors = container
          .read(deviceListProvider)
          .where((d) => d.type == 'lock')
          .toList();
      expect(initialDoors.every((d) => d.isLocked), isTrue);

      // Trigger smoke alarm override
      final notifier = container.read(emergencyProvider.notifier);
      final event = await notifier.triggerEmergency(
        type: EmergencyType.smoke,
        sourceDeviceId: 'dev_kitchen_smoke',
        sourceDeviceName: 'Kitchen Smoke Detector',
        room: 'Kitchen',
      );

      expect(event.type, equals(EmergencyType.smoke));
      expect(event.severity, equals(EmergencySeverity.critical));

      // Acceptance Criteria: Deadbolts unlocked within 50ms
      final state = container.read(emergencyProvider);
      expect(state.activeEmergency, isNotNull);
      expect(state.executionLatencyMs, lessThan(50));

      // Verify all deadbolts unlocked
      final updatedDoors = container
          .read(deviceListProvider)
          .where((d) => d.type == 'lock')
          .toList();
      expect(updatedDoors.every((d) => !d.isLocked), isTrue);

      // Verify lights driven to high-visibility amber (2700K 100%)
      final updatedLights = container
          .read(deviceListProvider)
          .where((d) => d.type == 'light')
          .toList();
      for (final light in updatedLights) {
        expect(light.isPowered, isTrue);
        expect(light.colorTemp, equals(2700));
        expect(light.brightness, equals(100));
      }

      // Verify recorded in repository history
      expect(emergencyRepo.events.length, equals(1));
      expect(
        emergencyRepo.events.first.actionsExecuted.length,
        greaterThanOrEqualTo(3),
      );
    });

    test(
      'Water leak emergency shuts main valve and unlocks doors immediately',
      () async {
        await container.read(deviceListProvider.notifier).loadDevices();

        final notifier = container.read(emergencyProvider.notifier);
        await notifier.triggerEmergency(
          type: EmergencyType.waterLeak,
          sourceDeviceId: 'dev_subfloor_leak',
          sourceDeviceName: 'Garage Sub-Floor Sensor',
          room: 'Solar Garage',
        );

        // Verify main water valve closed
        final valve = container
            .read(deviceListProvider)
            .firstWhere((d) => d.type == 'valve');
        expect(valve.isLocked, isTrue); // Locked/closed
        expect(valve.position, equals(0));
        expect(valve.isPowered, isFalse);

        // Verify doors also unlocked for emergency egress
        final updatedDoors = container
            .read(deviceListProvider)
            .where((d) => d.type == 'lock')
            .toList();
        expect(updatedDoors.every((d) => !d.isLocked), isTrue);
      },
    );

    test('Dismissing emergency clears active status', () async {
      await container.read(deviceListProvider.notifier).loadDevices();

      final notifier = container.read(emergencyProvider.notifier);
      final event = await notifier.triggerEmergency(
        type: EmergencyType.smoke,
        sourceDeviceId: 'dev_smoke',
        sourceDeviceName: 'Smoke Sensor',
        room: 'Kitchen',
      );

      expect(container.read(emergencyProvider).activeEmergency, isNotNull);

      await notifier.dismissEmergency(event.id);
      expect(container.read(emergencyProvider).activeEmergency, isNull);
      expect(emergencyRepo.events.first.isResolved, isTrue);
    });
  });
}
