class DeviceEntity {
  final String id;
  final String name;
  final String room;
  final String
  type; // 'light', 'hvac', 'lock', 'blinds', 'sensor', 'router', 'ev_charger'
  final String protocol; // 'Thread 1.3', 'Matter over Wi-Fi', 'BLE Mesh'
  final bool isPowered;
  final int brightness; // 0 - 100
  final int colorTemp; // 2700 - 6500 K
  final double targetTemp; // 16.0 - 30.0 C
  final double currentTemp;
  final String hvacMode; // 'cool', 'heat', 'eco', 'auto', 'off'
  final bool isLocked;
  final int position; // 0 - 100%
  final double powerWatts;
  final int rssi;
  final String? pairingCode;
  final int updatedAt;
  final int chargeCurrentAmps; // 6A - 32A
  final double chargeSocPercent; // 0 - 100%
  final bool offPeakScheduleEnabled;
  final bool circadianModeEnabled;

  const DeviceEntity({
    required this.id,
    required this.name,
    required this.room,
    required this.type,
    required this.protocol,
    required this.isPowered,
    this.brightness = 80,
    this.colorTemp = 3500,
    this.targetTemp = 22.0,
    this.currentTemp = 22.5,
    this.hvacMode = 'cool',
    this.isLocked = true,
    this.position = 0,
    this.powerWatts = 0.0,
    this.rssi = -55,
    this.pairingCode,
    required this.updatedAt,
    this.chargeCurrentAmps = 16,
    this.chargeSocPercent = 65.0,
    this.offPeakScheduleEnabled = true,
    this.circadianModeEnabled = true,
  });

  DeviceEntity copyWith({
    String? id,
    String? name,
    String? room,
    String? type,
    String? protocol,
    bool? isPowered,
    int? brightness,
    int? colorTemp,
    double? targetTemp,
    double? currentTemp,
    String? hvacMode,
    bool? isLocked,
    int? position,
    double? powerWatts,
    int? rssi,
    String? pairingCode,
    int? updatedAt,
    int? chargeCurrentAmps,
    double? chargeSocPercent,
    bool? offPeakScheduleEnabled,
    bool? circadianModeEnabled,
  }) {
    return DeviceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      room: room ?? this.room,
      type: type ?? this.type,
      protocol: protocol ?? this.protocol,
      isPowered: isPowered ?? this.isPowered,
      brightness: brightness ?? this.brightness,
      colorTemp: colorTemp ?? this.colorTemp,
      targetTemp: targetTemp ?? this.targetTemp,
      currentTemp: currentTemp ?? this.currentTemp,
      hvacMode: hvacMode ?? this.hvacMode,
      isLocked: isLocked ?? this.isLocked,
      position: position ?? this.position,
      powerWatts: powerWatts ?? this.powerWatts,
      rssi: rssi ?? this.rssi,
      pairingCode: pairingCode ?? this.pairingCode,
      updatedAt: updatedAt ?? this.updatedAt,
      chargeCurrentAmps: chargeCurrentAmps ?? this.chargeCurrentAmps,
      chargeSocPercent: chargeSocPercent ?? this.chargeSocPercent,
      offPeakScheduleEnabled:
          offPeakScheduleEnabled ?? this.offPeakScheduleEnabled,
      circadianModeEnabled: circadianModeEnabled ?? this.circadianModeEnabled,
    );
  }
}
