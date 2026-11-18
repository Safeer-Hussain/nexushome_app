import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection.dart';
import '../../data/models/device_model.dart';
import '../../data/repositories/device_repository.dart';
import '../../domain/entities/device_entity.dart';

final selectedRoomProvider = StateProvider<String>((ref) => 'All Rooms');

final deviceListProvider =
    StateNotifierProvider<DeviceListNotifier, List<DeviceEntity>>((ref) {
      final repo = getIt<DeviceRepository>();
      return DeviceListNotifier(repo);
    });

class DeviceListNotifier extends StateNotifier<List<DeviceEntity>> {
  final DeviceRepository _repository;

  DeviceListNotifier(this._repository) : super([]) {
    loadDevices();
  }

  Future<void> loadDevices() async {
    final devices = await _repository.getAllDevices();
    state = devices;
  }

  Future<void> togglePower(String id) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final target = state[index];
    final updated = target.copyWith(isPowered: !target.isPowered);

    // Optimistic immutable state update
    state = [
      for (final dev in state)
        if (dev.id == id) updated else dev,
    ];

    await _repository.togglePower(id, updated.isPowered);
  }

  Future<void> updateBrightness(String id, int brightness) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final target = state[index];
    final updated = target.copyWith(
      brightness: brightness,
      isPowered: brightness > 0 ? true : target.isPowered,
    );

    state = [
      for (final dev in state)
        if (dev.id == id) updated else dev,
    ];

    await _repository.updateAttributes(id, brightness: brightness);
  }

  Future<void> updateColorTemp(String id, int colorTemp) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final updated = state[index].copyWith(colorTemp: colorTemp);
    state = [
      for (final dev in state)
        if (dev.id == id) updated else dev,
    ];

    await _repository.updateAttributes(id, colorTemp: colorTemp);
  }

  Future<void> updateTargetTemp(String id, double targetTemp) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final updated = state[index].copyWith(targetTemp: targetTemp);
    state = [
      for (final dev in state)
        if (dev.id == id) updated else dev,
    ];

    await _repository.updateAttributes(id, targetTemp: targetTemp);
  }

  Future<void> updateHvacMode(String id, String mode) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final updated = state[index].copyWith(
      hvacMode: mode,
      isPowered: mode != 'off',
    );
    state = [
      for (final dev in state)
        if (dev.id == id) updated else dev,
    ];

    await _repository.updateAttributes(id, hvacMode: mode);
  }

  Future<void> toggleLock(String id) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final updated = state[index].copyWith(isLocked: !state[index].isLocked);
    state = [
      for (final dev in state)
        if (dev.id == id) updated else dev,
    ];

    await _repository.updateAttributes(id, isLocked: updated.isLocked);
  }

  Future<void> updateBlindsPosition(String id, int position) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final updated = state[index].copyWith(position: position);
    state = [
      for (final dev in state)
        if (dev.id == id) updated else dev,
    ];

    await _repository.updateAttributes(id, position: position);
  }

  Future<void> updateEvChargeCurrent(String id, int amps) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final target = state[index];
    final watts = target.isPowered ? (amps * 230.0) : 0.0;
    final updated = target.copyWith(chargeCurrentAmps: amps, powerWatts: watts);

    state = [
      for (final dev in state)
        if (dev.id == id) updated else dev,
    ];

    await _repository.updateAttributes(
      id,
      chargeCurrentAmps: amps,
      powerWatts: watts,
    );
  }

  Future<void> toggleEvOffPeakSchedule(String id) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final target = state[index];
    final updated = target.copyWith(
      offPeakScheduleEnabled: !target.offPeakScheduleEnabled,
    );

    state = [
      for (final dev in state)
        if (dev.id == id) updated else dev,
    ];

    await _repository.updateAttributes(
      id,
      offPeakScheduleEnabled: updated.offPeakScheduleEnabled,
    );
  }

  Future<void> toggleCircadianMode(String id) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final target = state[index];
    final updated = target.copyWith(
      circadianModeEnabled: !target.circadianModeEnabled,
    );

    state = [
      for (final dev in state)
        if (dev.id == id) updated else dev,
    ];

    await _repository.updateAttributes(
      id,
      circadianModeEnabled: updated.circadianModeEnabled,
    );
  }

  Future<void> batchApplyCircadianKelvin(
    int targetKelvin, {
    int? targetBrightness,
  }) async {
    final eligibleIds = <String>[];
    state = [
      for (final dev in state)
        if (dev.type == 'light' && dev.circadianModeEnabled) ...[
          () {
            eligibleIds.add(dev.id);
            return dev.copyWith(
              colorTemp: targetKelvin,
              brightness: targetBrightness ?? dev.brightness,
            );
          }(),
        ] else
          dev,
    ];

    if (eligibleIds.isNotEmpty) {
      await _repository.batchUpdateColorTemp(
        deviceIds: eligibleIds,
        colorTemp: targetKelvin,
        brightness: targetBrightness,
      );
    }
  }

  /// Emergency Override Action: Unlocks all perimeter exit deadbolts within milliseconds
  Future<int> unlockAllExitDoors() async {
    final unlockedIds = <String>[];
    state = [
      for (final dev in state)
        if (dev.type == 'lock') ...[
          () {
            unlockedIds.add(dev.id);
            return dev.copyWith(isLocked: false);
          }(),
        ] else
          dev,
    ];

    for (final id in unlockedIds) {
      await _repository.updateAttributes(id, isLocked: false);
    }
    return unlockedIds.length;
  }

  /// Emergency Override Action: Drives interior luminaires to high-visibility amber strobe (2700K 100%)
  Future<int> setEmergencyAmberStrobe() async {
    final lightIds = <String>[];
    state = [
      for (final dev in state)
        if (dev.type == 'light') ...[
          () {
            lightIds.add(dev.id);
            return dev.copyWith(
              isPowered: true,
              colorTemp: 2700,
              brightness: 100,
            );
          }(),
        ] else
          dev,
    ];

    if (lightIds.isNotEmpty) {
      await _repository.batchUpdateColorTemp(
        deviceIds: lightIds,
        colorTemp: 2700,
        brightness: 100,
      );
      for (final id in lightIds) {
        await _repository.togglePower(id, true);
      }
    }
    return lightIds.length;
  }

  /// Emergency Override Action: Closes main water valves immediately to mitigate flooding
  Future<int> closeMainWaterValves() async {
    final valveIds = <String>[];
    state = [
      for (final dev in state)
        if (dev.type == 'valve') ...[
          () {
            valveIds.add(dev.id);
            return dev.copyWith(isLocked: true, position: 0, isPowered: false);
          }(),
        ] else
          dev,
    ];

    for (final id in valveIds) {
      await _repository.updateAttributes(id, isLocked: true, position: 0);
      await _repository.togglePower(id, false);
    }
    return valveIds.length;
  }

  Future<void> commissionDevice(DeviceModel device) async {
    await _repository.commissionDevice(device);
    state = [...state, device];
  }

  Future<void> deleteDevice(String id) async {
    await _repository.deleteDevice(id);
    state = state.where((d) => d.id != id).toList();
  }
}
