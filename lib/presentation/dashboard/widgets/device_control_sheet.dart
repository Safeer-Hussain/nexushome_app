import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/device_entity.dart';
import '../../providers/circadian_provider.dart';
import '../../providers/device_provider.dart';

class DeviceControlSheet extends ConsumerStatefulWidget {
  final DeviceEntity device;

  const DeviceControlSheet({super.key, required this.device});

  static Future<void> show(BuildContext context, DeviceEntity device) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DeviceControlSheet(device: device),
    );
  }

  @override
  ConsumerState<DeviceControlSheet> createState() => _DeviceControlSheetState();
}

class _DeviceControlSheetState extends ConsumerState<DeviceControlSheet> {
  late int _brightness;
  late int _colorTemp;
  late double _targetTemp;
  late String _hvacMode;
  late bool _isLocked;
  late int _blindsPos;
  late int _chargeAmps;
  late bool _offPeakEnabled;
  late bool _circadianEnabled;
  final TextEditingController _pinController = TextEditingController();
  String? _pinError;

  @override
  void initState() {
    super.initState();
    _brightness = widget.device.brightness;
    _colorTemp = widget.device.colorTemp;
    _targetTemp = widget.device.targetTemp;
    _hvacMode = widget.device.hvacMode;
    _isLocked = widget.device.isLocked;
    _blindsPos = widget.device.position;
    _chargeAmps = widget.device.chargeCurrentAmps;
    _offPeakEnabled = widget.device.offPeakScheduleEnabled;
    _circadianEnabled = widget.device.circadianModeEnabled;
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final device = widget.device;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${device.room} • ${device.protocol}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: device.isPowered,
                    onChanged: (val) {
                      ref
                          .read(deviceListProvider.notifier)
                          .togglePower(device.id);
                      Navigator.pop(context);
                      AppFeedback.showSuccess(
                        context,
                        '${device.name} powered ${val ? "ON" : "OFF"} via Matter bridge.',
                      );
                    },
                  ),
                ],
              ),
              const Divider(height: 28),
              if (device.type == 'light') ...[
                _buildLightControls(colorScheme),
              ] else if (device.type == 'hvac') ...[
                _buildHvacControls(colorScheme),
              ] else if (device.type == 'lock') ...[
                _buildLockControls(colorScheme),
              ] else if (device.type == 'blinds') ...[
                _buildBlindsControls(colorScheme),
              ] else if (device.type == 'ev_charger') ...[
                _buildEvChargerControls(colorScheme),
              ] else ...[
                _buildGenericControls(colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLightControls(ColorScheme colorScheme) {
    final circadian = ref.watch(circadianProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circadian Adaptive Lighting Sync Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _circadianEnabled
                  ? colorScheme.primary.withOpacity(0.4)
                  : colorScheme.outlineVariant,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.wb_sunny_outlined,
                        size: 18,
                        color: _circadianEnabled
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Circadian Adaptive Curve',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _circadianEnabled,
                    onChanged: (val) {
                      setState(() {
                        _circadianEnabled = val;
                        if (val) {
                          _colorTemp = circadian.state.targetKelvin;
                        }
                      });
                      ref
                          .read(deviceListProvider.notifier)
                          .toggleCircadianMode(widget.device.id);
                      if (val) {
                        ref
                            .read(deviceListProvider.notifier)
                            .updateColorTemp(
                              widget.device.id,
                              circadian.state.targetKelvin,
                            );
                        AppFeedback.showSuccess(
                          context,
                          'Circadian sync enabled. Locked to ${circadian.state.targetKelvin}K (${circadian.state.phaseTitle}).',
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _circadianEnabled
                    ? 'Active: ${circadian.state.phaseTitle} (Solar Angle: ${circadian.state.solarElevation.toStringAsFixed(1)}°). Dispatched every 15 minutes.'
                    : 'Manual Override: Fixed Kelvin color temperature without astronomical solar tracking.',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (_circadianEnabled) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 13,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Astronomical Target: ${circadian.state.targetKelvin}K',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Brightness',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '$_brightness%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        Slider(
          value: _brightness.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          activeColor: colorScheme.primary,
          onChanged: (val) {
            setState(() => _brightness = val.round());
          },
          onChangeEnd: (val) {
            ref
                .read(deviceListProvider.notifier)
                .updateBrightness(widget.device.id, val.round());
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Color Temperature',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${_colorTemp}K',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.secondary,
              ),
            ),
          ],
        ),
        Slider(
          value: _colorTemp.toDouble(),
          min: 2700,
          max: 6500,
          divisions: 38,
          activeColor: colorScheme.secondary,
          onChanged: (val) {
            setState(() {
              _colorTemp = val.round();
              if (_circadianEnabled) {
                _circadianEnabled = false;
              }
            });
          },
          onChangeEnd: (val) {
            ref
                .read(deviceListProvider.notifier)
                .updateColorTemp(widget.device.id, val.round());
          },
        ),
        const SizedBox(height: 10),
        Text(
          'Kelvin Presets:',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ActionChip(
                avatar: const Icon(Icons.nightlight_round, size: 14),
                label: const Text('2700K Rest'),
                onPressed: () {
                  setState(() {
                    _colorTemp = 2700;
                    _circadianEnabled = false;
                  });
                  ref
                      .read(deviceListProvider.notifier)
                      .updateColorTemp(widget.device.id, 2700);
                },
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(Icons.wb_twilight_rounded, size: 14),
                label: const Text('3500K Ambient'),
                onPressed: () {
                  setState(() {
                    _colorTemp = 3500;
                    _circadianEnabled = false;
                  });
                  ref
                      .read(deviceListProvider.notifier)
                      .updateColorTemp(widget.device.id, 3500);
                },
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(Icons.wb_sunny_rounded, size: 14),
                label: const Text('5500K Daylight'),
                onPressed: () {
                  setState(() {
                    _colorTemp = 5500;
                    _circadianEnabled = false;
                  });
                  ref
                      .read(deviceListProvider.notifier)
                      .updateColorTemp(widget.device.id, 5500);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHvacControls(ColorScheme colorScheme) {
    const modes = ['cool', 'heat', 'eco', 'auto', 'off'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerHighest,
              border: Border.all(color: colorScheme.primary, width: 3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_targetTemp.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Current: ${widget.device.currentTemp}°C',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              icon: const Icon(Icons.remove),
              onPressed: _targetTemp > 16.0
                  ? () {
                      setState(() => _targetTemp -= 0.5);
                      ref
                          .read(deviceListProvider.notifier)
                          .updateTargetTemp(widget.device.id, _targetTemp);
                    }
                  : null,
            ),
            const SizedBox(width: 24),
            IconButton.filled(
              icon: const Icon(Icons.add),
              onPressed: _targetTemp < 30.0
                  ? () {
                      setState(() => _targetTemp += 0.5);
                      ref
                          .read(deviceListProvider.notifier)
                          .updateTargetTemp(widget.device.id, _targetTemp);
                    }
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: modes.map((m) {
            final isSelected = m == _hvacMode;
            return ChoiceChip(
              label: Text(m.toUpperCase()),
              selected: isSelected,
              selectedColor: colorScheme.primaryContainer,
              onSelected: (_) {
                setState(() => _hvacMode = m);
                ref
                    .read(deviceListProvider.notifier)
                    .updateHvacMode(widget.device.id, m);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLockControls(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                _isLocked
                    ? Icons.lock_outline_rounded
                    : Icons.lock_open_rounded,
                size: 32,
                color: _isLocked ? colorScheme.primary : colorScheme.error,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLocked ? 'SECURELY LOCKED' : 'UNLOCKED / ACCESS OPEN',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _isLocked
                            ? colorScheme.primary
                            : colorScheme.error,
                      ),
                    ),
                    Text(
                      'PIN authentication required to unlock perimeter.',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_isLocked) ...[
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: InputDecoration(
              labelText: 'Enter 4-Digit Security PIN (Default: 1234)',
              errorText: _pinError,
              prefixIcon: const Icon(Icons.pin_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.key_rounded),
              label: const Text('Unlock Perimeter Deadbolt'),
              onPressed: () {
                if (_pinController.text == '1234') {
                  setState(() {
                    _isLocked = false;
                    _pinError = null;
                  });
                  ref
                      .read(deviceListProvider.notifier)
                      .toggleLock(widget.device.id);
                  Navigator.pop(context);
                  AppFeedback.showWarning(
                    context,
                    'Perimeter Deadbolt UNLOCKED.',
                  );
                } else {
                  setState(() {
                    _pinError = 'Invalid Security PIN. Access denied.';
                  });
                }
              },
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.lock_rounded),
              label: const Text('Lock Deadbolt Now'),
              onPressed: () {
                setState(() => _isLocked = true);
                ref
                    .read(deviceListProvider.notifier)
                    .toggleLock(widget.device.id);
                Navigator.pop(context);
                AppFeedback.showSuccess(
                  context,
                  'Perimeter Deadbolt LOCKED securely.',
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBlindsControls(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Blinds Position',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '$_blindsPos% Open',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        Slider(
          value: _blindsPos.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          activeColor: colorScheme.primary,
          onChanged: (val) {
            setState(() => _blindsPos = val.round());
          },
          onChangeEnd: (val) {
            ref
                .read(deviceListProvider.notifier)
                .updateBlindsPosition(widget.device.id, val.round());
          },
        ),
      ],
    );
  }

  Widget _buildEvChargerControls(ColorScheme colorScheme) {
    final kw = (_chargeAmps * 230.0 / 1000.0).toStringAsFixed(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car_filled_rounded,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'EV Battery State of Charge',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${widget.device.chargeSocPercent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: widget.device.chargeSocPercent / 100.0,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Connected to 400V 82kWh Battery Pack • J1772 / NACS Protocol',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Charging Current Rate',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '$_chargeAmps A ($kw kW)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.secondary,
              ),
            ),
          ],
        ),
        Slider(
          value: _chargeAmps.toDouble(),
          min: 6,
          max: 32,
          divisions: 26,
          activeColor: colorScheme.secondary,
          onChanged: (val) {
            setState(() => _chargeAmps = val.round());
          },
          onChangeEnd: (val) {
            ref
                .read(deviceListProvider.notifier)
                .updateEvChargeCurrent(widget.device.id, val.round());
          },
        ),
        const SizedBox(height: 12),
        Card(
          color: colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: _offPeakEnabled
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.outlineVariant,
            ),
          ),
          child: SwitchListTile(
            title: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: _offPeakEnabled
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Smart Off-Peak Window Scheduler',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              'Pauses charging during 17:00-21:00 peak tariffs (\$0.48/kWh). Resumes automatically during midnight off-peak (\$0.08/kWh) or solar surplus > 3.5 kW.',
              style: TextStyle(
                fontSize: 10.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            value: _offPeakEnabled,
            onChanged: (val) {
              setState(() => _offPeakEnabled = val);
              ref
                  .read(deviceListProvider.notifier)
                  .toggleEvOffPeakSchedule(widget.device.id);
              AppFeedback.showSuccess(
                context,
                val
                    ? 'Off-Peak EV charging schedule armed. Peak tariffs avoided.'
                    : 'Off-Peak schedule disabled. Immediate charge enabled.',
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.bolt_rounded, size: 18),
            label: const Text('Instant Full-Rate Boost Charge (32A)'),
            onPressed: () {
              setState(() {
                _chargeAmps = 32;
                _offPeakEnabled = false;
              });
              ref
                  .read(deviceListProvider.notifier)
                  .updateEvChargeCurrent(widget.device.id, 32);
              ref
                  .read(deviceListProvider.notifier)
                  .toggleEvOffPeakSchedule(widget.device.id);
              AppFeedback.showWarning(
                context,
                'Full 32A (7.36 kW) Boost Charge activated. Overriding tariff pause.',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenericControls(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Telemetry & Diagnostics',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Signal RSSI: ${widget.device.rssi} dBm (Healthy)',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          Text(
            'Instant Wattage Draw: ${widget.device.powerWatts} W',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          Text(
            'Pairing Code: ${widget.device.pairingCode ?? "N/A"}',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
