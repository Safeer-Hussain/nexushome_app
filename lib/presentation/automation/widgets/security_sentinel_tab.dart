import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/app_feedback.dart';
import '../../providers/security_provider.dart';

class SecuritySentinelTab extends ConsumerWidget {
  const SecuritySentinelTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityMode = ref.watch(securityModeProvider);
    final events = ref.watch(securityEventsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 84),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perimeter Security Sentinel',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hardware-enforced perimeter locks, radar PIR sensors & camera feeds.',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          // Armed Mode Selector
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sentinel Arming State',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      securityMode.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildModeButton(
                        context,
                        ref,
                        label: 'Armed Home',
                        icon: Icons.shield_outlined,
                        mode: 'Armed Home',
                        current: securityMode,
                        colorScheme: colorScheme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildModeButton(
                        context,
                        ref,
                        label: 'Armed Away',
                        icon: Icons.security_rounded,
                        mode: 'Armed Away',
                        current: securityMode,
                        colorScheme: colorScheme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildModeButton(
                        context,
                        ref,
                        label: 'Disarmed',
                        icon: Icons.lock_open_rounded,
                        mode: 'Disarmed',
                        current: securityMode,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Live Sentinel Video Feeds',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildCameraCard(
                  title: 'Front Entrance',
                  room: 'Living Room',
                  status: 'Live 1080p',
                  colorScheme: colorScheme,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCameraCard(
                  title: 'Solar Garage Bay',
                  room: 'Solar Garage',
                  status: 'Live 1080p',
                  colorScheme: colorScheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Security Event Timeline',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.notifications_active_outlined, size: 16),
                label: const Text('Simulate Trigger'),
                onPressed: () {
                  ref
                      .read(securityEventsProvider.notifier)
                      .triggerAlert(
                        title: 'Front Door PIR Motion Triggered',
                        deviceName: 'Entrance PIR Sensor',
                        room: 'Living Room',
                        severity: 'warning',
                      );
                  AppFeedback.showWarning(
                    context,
                    'Motion detected at Front Door portal.',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...events.map((evt) {
            final dateStr = DateFormat('HH:mm:ss')
                .format(DateTime.fromMillisecondsSinceEpoch(evt.timestamp));

            Color badgeColor;
            if (evt.severity == 'alert') {
              badgeColor = colorScheme.error;
            } else if (evt.severity == 'warning') {
              badgeColor = colorScheme.secondary;
            } else {
              badgeColor = colorScheme.primary;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: colorScheme.surfaceContainer,
              child: ListTile(
                dense: true,
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.sensors_rounded,
                    color: badgeColor,
                    size: 18,
                  ),
                ),
                title: Text(
                  evt.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  '${evt.deviceName} • ${evt.room}',
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required IconData icon,
    required String mode,
    required String current,
    required ColorScheme colorScheme,
  }) {
    final isSelected = mode == current;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        backgroundColor: isSelected
            ? colorScheme.primaryContainer
            : Colors.transparent,
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        ref.read(securityModeProvider.notifier).state = mode;
        AppFeedback.showSuccess(context, 'Security state set to: $mode');
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraCard({
    required String title,
    required String room,
    required String status,
    required ColorScheme colorScheme,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.videocam_outlined,
              size: 38,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onError,
                        ),
                      ),
                    ),
                    Icon(Icons.circle, size: 8, color: colorScheme.primary),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      room,
                      style: TextStyle(
                        fontSize: 9,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
