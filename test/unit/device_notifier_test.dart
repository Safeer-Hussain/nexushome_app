import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_home_app/data/models/device_model.dart';
import 'package:nexus_home_app/presentation/providers/device_provider.dart';

import '../helpers/mock_repositories.dart';

void main() {
  group('DeviceListNotifier Unit Tests', () {
    late FakeDeviceRepository repository;
    late DeviceListNotifier notifier;

    setUp(() {
      repository = FakeDeviceRepository();
      notifier = DeviceListNotifier(repository);
    });

    test('Loads initial devices from repository into state', () async {
      await notifier.loadDevices();
      expect(notifier.state.length, equals(3));
      expect(notifier.state.first.name, equals('Living Room Ambient Light'));
    });

    test('Toggles device power immutably and updates repository', () async {
      await notifier.loadDevices();
      final dev = notifier.state.first;
      expect(dev.isPowered, isTrue);

      await notifier.togglePower(dev.id);
      final updated = notifier.state.firstWhere((d) => d.id == dev.id);
      expect(updated.isPowered, isFalse);

      final repoDev = repository.devices.firstWhere((d) => d.id == dev.id);
      expect(repoDev.isPowered, isFalse);
    });

    test(
      'Updates light brightness and activates power if brightness > 0',
      () async {
        await notifier.loadDevices();
        const devId = 'dev_living_ambient_light';

        await notifier.updateBrightness(devId, 45);
        final updated = notifier.state.firstWhere((d) => d.id == devId);
        expect(updated.brightness, equals(45));
        expect(updated.isPowered, isTrue);
      },
    );

    test('Updates HVAC target temperature correctly', () async {
      await notifier.loadDevices();
      const devId = 'dev_living_hvac';

      await notifier.updateTargetTemp(devId, 24.5);
      final updated = notifier.state.firstWhere((d) => d.id == devId);
      expect(updated.targetTemp, equals(24.5));
    });

    test('Updates HVAC mode and handles power state', () async {
      await notifier.loadDevices();
      const devId = 'dev_living_hvac';

      await notifier.updateHvacMode(devId, 'eco');
      var updated = notifier.state.firstWhere((d) => d.id == devId);
      expect(updated.hvacMode, equals('eco'));
      expect(updated.isPowered, isTrue);

      await notifier.updateHvacMode(devId, 'off');
      updated = notifier.state.firstWhere((d) => d.id == devId);
      expect(updated.hvacMode, equals('off'));
      expect(updated.isPowered, isFalse);
    });

    test('Toggles smart lock state', () async {
      await notifier.loadDevices();
      const devId = 'dev_main_entrance_lock';

      await notifier.toggleLock(devId);
      final updated = notifier.state.firstWhere((d) => d.id == devId);
      expect(updated.isLocked, isFalse);
    });

    test('Commissions new device and adds to state', () async {
      await notifier.loadDevices();
      final initialCount = notifier.state.length;

      final newDevice = DeviceModel(
        id: 'dev_test_sensor',
        name: 'Terrace Motion PIR',
        room: 'Outdoor',
        type: 'sensor',
        protocol: 'Thread 1.3',
        isPowered: true,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await notifier.commissionDevice(newDevice);
      expect(notifier.state.length, equals(initialCount + 1));
      expect(notifier.state.any((d) => d.id == 'dev_test_sensor'), isTrue);
    });

    test('Deletes device by ID from state and repository', () async {
      await notifier.loadDevices();
      const devId = 'dev_main_entrance_lock';

      await notifier.deleteDevice(devId);
      expect(notifier.state.any((d) => d.id == devId), isFalse);
      expect(repository.devices.any((d) => d.id == devId), isFalse);
    });

    test(
      'Updates EV charge current and recalculates wattage dynamically',
      () async {
        await notifier.loadDevices();
        final evDevice = DeviceModel(
          id: 'dev_garage_ev',
          name: 'Garage HyperCharge EVSE',
          room: 'Solar Garage',
          type: 'ev_charger',
          protocol: 'Matter over Wi-Fi',
          isPowered: true,
          chargeCurrentAmps: 16,
          chargeSocPercent: 55,
          offPeakScheduleEnabled: true,
          powerWatts: 3680.0,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        await notifier.commissionDevice(evDevice);

        await notifier.updateEvChargeCurrent('dev_garage_ev', 32);
        final updated = notifier.state.firstWhere(
          (d) => d.id == 'dev_garage_ev',
        );
        expect(updated.chargeCurrentAmps, equals(32));
        expect(updated.powerWatts, equals(7360.0));
        expect(updated.isPowered, isTrue);

        final repoDev = repository.devices.firstWhere(
          (d) => d.id == 'dev_garage_ev',
        );
        expect(repoDev.chargeCurrentAmps, equals(32));
        expect(repoDev.powerWatts, equals(7360.0));
      },
    );

    test('Toggles EV off-peak schedule flag immutably', () async {
      await notifier.loadDevices();
      final evDevice = DeviceModel(
        id: 'dev_garage_ev2',
        name: 'Garage EV Charger 2',
        room: 'Solar Garage',
        type: 'ev_charger',
        protocol: 'Matter over Wi-Fi',
        isPowered: true,
        chargeCurrentAmps: 16,
        chargeSocPercent: 40,
        offPeakScheduleEnabled: true,
        powerWatts: 3680.0,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await notifier.commissionDevice(evDevice);

      await notifier.toggleEvOffPeakSchedule('dev_garage_ev2');
      final updated = notifier.state.firstWhere(
        (d) => d.id == 'dev_garage_ev2',
      );
      expect(updated.offPeakScheduleEnabled, isFalse);

      await notifier.toggleEvOffPeakSchedule('dev_garage_ev2');
      final updatedAgain = notifier.state.firstWhere(
        (d) => d.id == 'dev_garage_ev2',
      );
      expect(updatedAgain.offPeakScheduleEnabled, isTrue);
    });

    test('Toggles circadian adaptive mode on a light device', () async {
      await notifier.loadDevices();
      const devId = 'dev_living_ambient_light';

      final initial = notifier.state.firstWhere((d) => d.id == devId);
      expect(initial.circadianModeEnabled, isTrue);

      await notifier.toggleCircadianMode(devId);
      final toggled = notifier.state.firstWhere((d) => d.id == devId);
      expect(toggled.circadianModeEnabled, isFalse);

      final repoDev = repository.devices.firstWhere((d) => d.id == devId);
      expect(repoDev.circadianModeEnabled, isFalse);

      await notifier.toggleCircadianMode(devId);
      final restored = notifier.state.firstWhere((d) => d.id == devId);
      expect(restored.circadianModeEnabled, isTrue);
    });

    test(
      'Batch applies circadian Kelvin only to circadian-enabled lights',
      () async {
        await notifier.loadDevices();
        const lightId = 'dev_living_ambient_light';
        const hvacId = 'dev_living_hvac';

        // dev_living_ambient_light has circadianModeEnabled = true
        // dev_living_hvac is type 'hvac'
        await notifier.batchApplyCircadianKelvin(5200);

        final light = notifier.state.firstWhere((d) => d.id == lightId);
        expect(light.colorTemp, equals(5200));

        final hvac = notifier.state.firstWhere((d) => d.id == hvacId);
        expect(hvac.colorTemp, equals(0)); // Unaffected
      },
    );
  });
}
