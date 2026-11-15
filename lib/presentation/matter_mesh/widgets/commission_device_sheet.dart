import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../data/models/device_model.dart';
import '../../providers/device_provider.dart';
import '../../providers/mesh_provider.dart';

class CommissionDeviceSheet extends ConsumerStatefulWidget {
  const CommissionDeviceSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const CommissionDeviceSheet(),
    );
  }

  @override
  ConsumerState<CommissionDeviceSheet> createState() =>
      _CommissionDeviceSheetState();
}

class _CommissionDeviceSheetState extends ConsumerState<CommissionDeviceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pairingCodeController = TextEditingController();

  String _selectedRoom = 'Living Room';
  String _selectedType = 'light';
  String _selectedProtocol = 'Thread 1.3';

  final List<String> _rooms = [
    'Living Room',
    'Master Suite',
    'Kitchen',
    'Home Office',
    'Solar Garage',
  ];

  final List<Map<String, String>> _types = [
    {'type': 'light', 'label': 'Smart Luminaire / Light'},
    {'type': 'hvac', 'label': 'HVAC Climate Unit'},
    {'type': 'lock', 'label': 'Smart Deadbolt'},
    {'type': 'blinds', 'label': 'Motorized Blinds'},
    {'type': 'sensor', 'label': 'Environmental Sensor'},
  ];

  final List<String> _protocols = [
    'Thread 1.3',
    'Matter over Wi-Fi',
    'BLE Mesh',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _pairingCodeController.dispose();
    super.dispose();
  }

  void _applyQuickDiscovery(
    String name,
    String type,
    String code,
    String protocol,
  ) {
    setState(() {
      _nameController.text = name;
      _selectedType = type;
      _pairingCodeController.text = code;
      _selectedProtocol = protocol;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final id = 'dev_${DateTime.now().millisecondsSinceEpoch}';
    final name = _nameController.text.trim();
    final code = _pairingCodeController.text.trim();

    final newDevice = DeviceModel(
      id: id,
      name: name,
      room: _selectedRoom,
      type: _selectedType,
      protocol: _selectedProtocol,
      isPowered: true,
      brightness: _selectedType == 'light' ? 80 : 0,
      colorTemp: _selectedType == 'light' ? 3500 : 0,
      targetTemp: _selectedType == 'hvac' ? 22.0 : 0.0,
      currentTemp: 22.0,
      hvacMode: _selectedType == 'hvac' ? 'cool' : 'off',
      isLocked: true,
      position: _selectedType == 'blinds' ? 50 : 0,
      powerWatts: _selectedType == 'light'
          ? 20.0
          : (_selectedType == 'hvac' ? 650.0 : 8.0),
      rssi: -45 - Random().nextInt(15),
      pairingCode: code,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Save device to registry
    ref.read(deviceListProvider.notifier).commissionDevice(newDevice);

    // Add node to mesh network
    ref
        .read(meshListProvider.notifier)
        .commissionNewNode(
          deviceId: id,
          nodeName: name,
          protocol: _selectedProtocol,
          nodeType: _selectedProtocol == 'Thread 1.3' ? 'router' : 'end_device',
        );

    Navigator.pop(context);
    AppFeedback.showSuccess(
      context,
      'Device "$name" successfully commissioned via Matter bridge into $_selectedRoom.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Form(
            key: _formKey,
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
                Text(
                  'Commission Matter Device',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Pair zero-cloud IoT hardware directly to your Thread/Matter mesh.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Discovered Nearby Beacons:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.bolt_rounded, size: 16),
                        label: const Text('Smart Plug Pro'),
                        onPressed: () => _applyQuickDiscovery(
                          'Kitchen Espresso Plug',
                          'sensor',
                          '5412-8891-304',
                          'Thread 1.3',
                        ),
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: const Icon(Icons.lightbulb_outline, size: 16),
                        label: const Text('RGB Light Strip'),
                        onPressed: () => _applyQuickDiscovery(
                          'Office Accent Strip',
                          'light',
                          '9923-4100-221',
                          'Thread 1.3',
                        ),
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: const Icon(Icons.shield_outlined, size: 16),
                        label: const Text('Backdoor Lock'),
                        onPressed: () => _applyQuickDiscovery(
                          'Patio Deadbolt',
                          'lock',
                          '1120-4493-556',
                          'Matter over Wi-Fi',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Device Name',
                    hintText: 'e.g. Master Pendant Luminaire',
                    prefixIcon: const Icon(Icons.label_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a device name.';
                    }
                    if (value.trim().length < 3) {
                      return 'Device name must be at least 3 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _pairingCodeController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: '11-Digit Matter Pairing Code',
                    hintText: 'e.g. 8234-9120-441',
                    prefixIcon: const Icon(Icons.qr_code_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Pairing code is required.';
                    }
                    final clean = value.replaceAll('-', '').trim();
                    if (clean.length < 11) {
                      return 'Matter pairing code must contain 11 digits.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedRoom,
                  decoration: InputDecoration(
                    labelText: 'Assign Room Zone',
                    prefixIcon: const Icon(Icons.room_preferences_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _rooms
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRoom = val);
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Device Type',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _types
                      .map(
                        (t) => DropdownMenuItem(
                          value: t['type'],
                          child: Text(t['label']!),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedProtocol,
                  decoration: InputDecoration(
                    labelText: 'Transport Protocol',
                    prefixIcon: const Icon(Icons.wifi_tethering_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _protocols
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedProtocol = val);
                  },
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.add_link_rounded),
                    label: const Text(
                      'Commission to Matter Network',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
