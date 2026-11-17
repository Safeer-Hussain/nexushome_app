import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../../core/platform/matter_native_bridge.dart';
import '../models/device_model.dart';

class DeviceRepository {
  final AppDatabase appDatabase;
  final MatterNativeBridge matterBridge;

  DeviceRepository({required this.appDatabase, required this.matterBridge});

  Future<List<DeviceModel>> getAllDevices() async {
    final db = await appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'devices',
      orderBy: 'room ASC, name ASC',
    );
    return maps.map((m) => DeviceModel.fromMap(m)).toList();
  }

  Future<List<DeviceModel>> getDevicesByRoom(String room) async {
    final db = await appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'devices',
      where: 'room = ?',
      whereArgs: [room],
      orderBy: 'name ASC',
    );
    return maps.map((m) => DeviceModel.fromMap(m)).toList();
  }

  Future<void> togglePower(String id, bool isPowered) async {
    final db = await appDatabase.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'devices',
      {'is_powered': isPowered ? 1 : 0, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );

    // Call native Matter bridge
    await matterBridge.toggleDevicePower(deviceId: id, isPowered: isPowered);
  }

  Future<void> updateAttributes(
    String id, {
    int? brightness,
    int? colorTemp,
    double? targetTemp,
    String? hvacMode,
    bool? isLocked,
    int? position,
    int? chargeCurrentAmps,
    double? chargeSocPercent,
    bool? offPeakScheduleEnabled,
    double? powerWatts,
    bool? circadianModeEnabled,
  }) async {
    final db = await appDatabase.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final Map<String, dynamic> updates = {'updated_at': now};

    if (brightness != null) {
      updates['brightness'] = brightness;
    }
    if (colorTemp != null) {
      updates['color_temp'] = colorTemp;
    }
    if (targetTemp != null) {
      updates['target_temp'] = targetTemp;
    }
    if (hvacMode != null) {
      updates['hvac_mode'] = hvacMode;
    }
    if (isLocked != null) {
      updates['is_locked'] = isLocked ? 1 : 0;
    }
    if (position != null) {
      updates['position'] = position;
    }
    if (chargeCurrentAmps != null) {
      updates['charge_current_amps'] = chargeCurrentAmps;
    }
    if (chargeSocPercent != null) {
      updates['charge_soc_percent'] = chargeSocPercent;
    }
    if (offPeakScheduleEnabled != null) {
      updates['off_peak_enabled'] = offPeakScheduleEnabled ? 1 : 0;
    }
    if (powerWatts != null) {
      updates['power_watts'] = powerWatts;
    }
    if (circadianModeEnabled != null) {
      updates['circadian_enabled'] = circadianModeEnabled ? 1 : 0;
    }

    await db.update('devices', updates, where: 'id = ?', whereArgs: [id]);

    if (brightness != null) {
      await matterBridge.setDeviceAttribute(
        deviceId: id,
        attribute: 'brightness',
        value: brightness,
      );
    }
    if (targetTemp != null) {
      await matterBridge.setDeviceAttribute(
        deviceId: id,
        attribute: 'targetTemp',
        value: targetTemp,
      );
    }
    if (isLocked != null) {
      await matterBridge.setDeviceAttribute(
        deviceId: id,
        attribute: 'isLocked',
        value: isLocked,
      );
    }
    if (chargeCurrentAmps != null) {
      await matterBridge.setDeviceAttribute(
        deviceId: id,
        attribute: 'chargeCurrentAmps',
        value: chargeCurrentAmps,
      );
    }
  }

  Future<void> batchUpdateColorTemp({
    required List<String> deviceIds,
    required int colorTemp,
    int? brightness,
  }) async {
    if (deviceIds.isEmpty) return;
    final db = await appDatabase.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final Map<String, dynamic> updates = {
      'color_temp': colorTemp,
      'updated_at': now,
    };
    if (brightness != null) {
      updates['brightness'] = brightness;
    }

    final placeholders = List.filled(deviceIds.length, '?').join(',');
    await db.update(
      'devices',
      updates,
      where: 'id IN ($placeholders)',
      whereArgs: deviceIds,
    );

    await matterBridge.batchSetDeviceAttribute(
      deviceIds: deviceIds,
      attribute: 'colorTemp',
      value: colorTemp,
    );
  }

  Future<void> commissionDevice(DeviceModel device) async {
    final db = await appDatabase.database;
    await db.insert(
      'devices',
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await matterBridge.commissionMatterDevice(
      pairingCode: device.pairingCode ?? 'UNKNOWN',
      deviceType: device.type,
      room: device.room,
    );
  }

  Future<void> deleteDevice(String id) async {
    final db = await appDatabase.database;
    await db.delete('devices', where: 'id = ?', whereArgs: [id]);
  }
}
