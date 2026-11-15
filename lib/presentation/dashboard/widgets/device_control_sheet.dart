import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/device_entity.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            setState(() => _colorTemp = val.round());
          },
          onChangeEnd: (val) {
            ref
                .read(deviceListProvider.notifier)
                .updateColorTemp(widget.device.id, val.round());
          },
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
