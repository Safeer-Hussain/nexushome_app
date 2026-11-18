import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/device_entity.dart';
import '../../providers/device_provider.dart';
import 'device_control_sheet.dart';

class DeviceCard extends ConsumerWidget {
  final DeviceEntity device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPowered = device.isPowered;

    IconData icon;
    String statusText;

    switch (device.type) {
      case 'light':
        icon = isPowered
            ? Icons.lightbulb_rounded
            : Icons.lightbulb_outline_rounded;
        statusText = isPowered
            ? (device.circadianModeEnabled
                  ? '${device.colorTemp}K • Circadian'
                  : '${device.brightness}% • ${device.colorTemp}K')
            : 'Off';
        break;
      case 'hvac':
        icon = Icons.thermostat_rounded;
        statusText = isPowered
            ? '${device.targetTemp}°C • ${device.hvacMode.toUpperCase()}'
            : 'Off';
        break;
      case 'lock':
        icon = device.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded;
        statusText = device.isLocked ? 'Locked' : 'Unlocked';
        break;
      case 'blinds':
        icon = Icons.blinds_rounded;
        statusText = '${device.position}% Open';
        break;
      case 'sensor':
        icon = Icons.sensors_rounded;
        statusText = '${device.powerWatts} W';
        break;
      case 'ev_charger':
        icon = Icons.ev_station_rounded;
        final kw = (device.chargeCurrentAmps * 230.0 / 1000.0).toStringAsFixed(
          1,
        );
        statusText = isPowered
            ? (device.offPeakScheduleEnabled
                  ? '$kw kW • Off-Peak'
                  : '$kw kW • Boost')
            : 'Idle • ${device.chargeSocPercent.toInt()}% SoC';
        break;
      case 'valve':
        icon = device.isLocked
            ? Icons.plumbing_rounded
            : Icons.water_drop_rounded;
        statusText = device.isLocked ? 'Closed (Shut)' : 'Open (Flowing)';
        break;
      case 'smoke_sensor':
        icon = Icons.local_fire_department_rounded;
        statusText = isPowered ? 'Active • Normal' : 'Offline';
        break;
      case 'leak_sensor':
        icon = Icons.water_damage_rounded;
        statusText = isPowered ? 'Active • Dry' : 'Offline';
        break;
      default:
        icon = Icons.devices_other_rounded;
        statusText = isPowered ? 'Active' : 'Standby';
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPowered
              ? colorScheme.primary.withValues(alpha: 0.35)
              : colorScheme.outlineVariant,
          width: 1.2,
        ),
      ),
      color: isPowered
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surfaceContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => DeviceControlSheet.show(context, device),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPowered
                          ? colorScheme.primary.withValues(alpha: 0.15)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isPowered
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.signal_cellular_alt_rounded,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        height: 24,
                        width: 38,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Switch(
                            value: isPowered,
                            onChanged: (_) {
                              ref
                                  .read(deviceListProvider.notifier)
                                  .togglePower(device.id);
                              AppFeedback.showSuccess(
                                context,
                                '${device.name} ${!isPowered ? "Powered On" : "Powered Off"}.',
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    device.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          device.protocol,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          statusText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isPowered
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
