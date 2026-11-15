import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_provider.dart';
import '../../core/utils/app_feedback.dart';
import '../providers/energy_provider.dart';
import 'widgets/recruiter_debug_drawer.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final currency = ref.watch(energyCurrencyProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sanctuary Settings')),
      endDrawer: const RecruiterDebugDrawer(),
      body: Builder(
        builder: (innerContext) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              Text(
                'Interface Appearance',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: colorScheme.surfaceContainer,
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: Text(
                        'Obsidian Smart-Home Dark',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      value: ThemeMode.dark,
                      groupValue: themeMode,
                      onChanged: (mode) {
                        if (mode != null)
                          ref.read(themeModeProvider.notifier).setTheme(mode);
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text(
                        'Crisp Architectural Light',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      value: ThemeMode.light,
                      groupValue: themeMode,
                      onChanged: (mode) {
                        if (mode != null)
                          ref.read(themeModeProvider.notifier).setTheme(mode);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Tariff & Energy Rates',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: colorScheme.surfaceContainer,
                child: ListTile(
                  title: Text(
                    'Calculation Currency',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Current: $currency (\$0.16/kWh / PKR 48/kWh)',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'USD', label: Text('USD')),
                      ButtonSegment(value: 'PKR', label: Text('PKR')),
                    ],
                    selected: {currency},
                    onSelectionChanged: (set) {
                      ref.read(energyCurrencyProvider.notifier).state =
                          set.first;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Sanctuary Mesh Infrastructure',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: colorScheme.surfaceContainer,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.hub_outlined,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      title: Text(
                        'Matter Border Router',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        'Thread 1.3.0 • IP fdde:ad11:11de::1',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Text(
                        'ONLINE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.storage_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      title: Text(
                        'Local SQLite Storage',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        'nexushome.db • Schema Version 1',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Text(
                        'SYNCHRONIZED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // App Version tile with Long-Press Easter Egg to launch Recruiter Debug Drawer!
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onLongPress: () {
                    Scaffold.of(innerContext).openEndDrawer();
                    AppFeedback.showInfo(
                      innerContext,
                      'Recruiter Debug Drawer activated.',
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'NexusHome v1.0.0+1 (Architecture Build)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hold long-press to open Recruiter Debug Drawer',
                          style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
