import '../../domain/entities/device_entity.dart';

class DeviceModel extends DeviceEntity {
  const DeviceModel({
    required super.id,
    required super.name,
    required super.room,
    required super.type,
    required super.protocol,
    required super.isPowered,
    super.brightness,
    super.colorTemp,
    super.targetTemp,
    super.currentTemp,
    super.hvacMode,
    super.isLocked,
    super.position,
    super.powerWatts,
    super.rssi,
    super.pairingCode,
    required super.updatedAt,
    super.chargeCurrentAmps,
    super.chargeSocPercent,
    super.offPeakScheduleEnabled,
    super.circadianModeEnabled,
  });

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      id: map['id'] as String,
      name: map['name'] as String,
      room: map['room'] as String,
      type: map['type'] as String,
      protocol: map['protocol'] as String,
      isPowered: (map['is_powered'] as int) == 1,
      brightness: map['brightness'] as int? ?? 80,
      colorTemp: map['color_temp'] as int? ?? 3500,
      targetTemp: (map['target_temp'] as num?)?.toDouble() ?? 22.0,
      currentTemp: (map['current_temp'] as num?)?.toDouble() ?? 22.5,
      hvacMode: map['hvac_mode'] as String? ?? 'cool',
      isLocked: (map['is_locked'] as int?) == 1,
      position: map['position'] as int? ?? 0,
      powerWatts: (map['power_watts'] as num?)?.toDouble() ?? 0.0,
      rssi: map['rssi'] as int? ?? -55,
      pairingCode: map['pairing_code'] as String?,
      updatedAt:
          map['updated_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      chargeCurrentAmps: map['charge_current_amps'] as int? ?? 16,
      chargeSocPercent: (map['charge_soc_percent'] as num?)?.toDouble() ?? 65.0,
      offPeakScheduleEnabled: (map['off_peak_enabled'] as int? ?? 1) == 1,
      circadianModeEnabled: (map['circadian_enabled'] as int? ?? 1) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'room': room,
      'type': type,
      'protocol': protocol,
      'is_powered': isPowered ? 1 : 0,
      'brightness': brightness,
      'color_temp': colorTemp,
      'target_temp': targetTemp,
      'current_temp': currentTemp,
      'hvac_mode': hvacMode,
      'is_locked': isLocked ? 1 : 0,
      'position': position,
      'power_watts': powerWatts,
      'rssi': rssi,
      'pairing_code': pairingCode,
      'updated_at': updatedAt,
      'charge_current_amps': chargeCurrentAmps,
      'charge_soc_percent': chargeSocPercent,
      'off_peak_enabled': offPeakScheduleEnabled ? 1 : 0,
      'circadian_enabled': circadianModeEnabled ? 1 : 0,
    };
  }

  factory DeviceModel.fromEntity(DeviceEntity entity) {
    return DeviceModel(
      id: entity.id,
      name: entity.name,
      room: entity.room,
      type: entity.type,
      protocol: entity.protocol,
      isPowered: entity.isPowered,
      brightness: entity.brightness,
      colorTemp: entity.colorTemp,
      targetTemp: entity.targetTemp,
      currentTemp: entity.currentTemp,
      hvacMode: entity.hvacMode,
      isLocked: entity.isLocked,
      position: entity.position,
      powerWatts: entity.powerWatts,
      rssi: entity.rssi,
      pairingCode: entity.pairingCode,
      updatedAt: entity.updatedAt,
      chargeCurrentAmps: entity.chargeCurrentAmps,
      chargeSocPercent: entity.chargeSocPercent,
      offPeakScheduleEnabled: entity.offPeakScheduleEnabled,
      circadianModeEnabled: entity.circadianModeEnabled,
    );
  }
}
