import 'dart:math';

import '../../core/platform/matter_native_bridge.dart';
import '../models/energy_telemetry_model.dart';

class EnergyHourlyDataPoint {
  final int hour;
  final double solarKwh;
  final double loadKwh;

  const EnergyHourlyDataPoint({
    required this.hour,
    required this.solarKwh,
    required this.loadKwh,
  });
}

class PowerConsumerItem {
  final String name;
  final String room;
  final double currentWatts;
  final double monthlyKwh;
  final double monthlyCostUsd;
  final double monthlyCostPkr;

  const PowerConsumerItem({
    required this.name,
    required this.room,
    required this.currentWatts,
    required this.monthlyKwh,
    required this.monthlyCostUsd,
    required this.monthlyCostPkr,
  });
}

class EnergyRepository {
  final MatterNativeBridge matterBridge;

  EnergyRepository({required this.matterBridge});

  Stream<EnergyTelemetryModel> getTelemetryStream() {
    return matterBridge.getEnergyTelemetryStream().map((data) {
      return EnergyTelemetryModel.fromMap(data);
    });
  }

  List<EnergyHourlyDataPoint> get24HourEnergyProfile() {
    // Generate realistic 24-hour diurnal solar bell curve + dual peak consumption
    final points = <EnergyHourlyDataPoint>[];
    for (int h = 0; h < 24; h++) {
      double solar = 0.0;
      if (h >= 6 && h <= 18) {
        // Bell curve peaking at hour 12-13
        final angle = (h - 6) / 12 * pi;
        solar = 5.2 * sin(angle);
        if (solar < 0) solar = 0;
      }

      // Home load with morning peak (7-9am) and evening peak (18-22pm)
      double load = 1.2;
      if (h >= 7 && h <= 9) {
        load = 3.4 + 0.4 * sin((h - 7) / 2 * pi);
      } else if (h >= 17 && h <= 22) {
        load = 4.2 + 0.6 * sin((h - 17) / 5 * pi);
      } else if (h >= 10 && h <= 16) {
        load = 2.1;
      }

      points.add(
        EnergyHourlyDataPoint(
          hour: h,
          solarKwh: double.parse(solar.toStringAsFixed(2)),
          loadKwh: double.parse(load.toStringAsFixed(2)),
        ),
      );
    }
    return points;
  }

  List<PowerConsumerItem> getTopConsumers() {
    const usdPerKwh = 0.16;
    const pkrPerKwh = 48.0;

    return const [
      PowerConsumerItem(
        name: 'Living Climate Controller (HVAC)',
        room: 'Living Room',
        currentWatts: 840.0,
        monthlyKwh: 242.0,
        monthlyCostUsd: 242.0 * usdPerKwh,
        monthlyCostPkr: 242.0 * pkrPerKwh,
      ),
      PowerConsumerItem(
        name: 'Culinary Induction & Luminaire',
        room: 'Kitchen',
        currentWatts: 185.0,
        monthlyKwh: 58.0,
        monthlyCostUsd: 58.0 * usdPerKwh,
        monthlyCostPkr: 58.0 * pkrPerKwh,
      ),
      PowerConsumerItem(
        name: 'Solar Inverter Cooling & Logic',
        room: 'Solar Garage',
        currentWatts: 35.0,
        monthlyKwh: 25.2,
        monthlyCostUsd: 25.2 * usdPerKwh,
        monthlyCostPkr: 25.2 * pkrPerKwh,
      ),
      PowerConsumerItem(
        name: 'Studio Workstation & Spotlight',
        room: 'Home Office',
        currentWatts: 28.0,
        monthlyKwh: 20.1,
        monthlyCostUsd: 20.1 * usdPerKwh,
        monthlyCostPkr: 20.1 * pkrPerKwh,
      ),
      PowerConsumerItem(
        name: 'Nexus Border Router & Mesh Hub',
        room: 'Network Hub',
        currentWatts: 14.5,
        monthlyKwh: 10.4,
        monthlyCostUsd: 10.4 * usdPerKwh,
        monthlyCostPkr: 10.4 * pkrPerKwh,
      ),
    ];
  }
}
