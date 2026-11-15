import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme_provider.dart';
import 'dashboard/dashboard_view.dart';
import 'matter_mesh/matter_mesh_view.dart';
import 'energy/energy_view.dart';
import 'automation/automation_view.dart';
import 'ai_copilot/ai_copilot_view.dart';
import 'settings/settings_view.dart';
import 'settings/widgets/recruiter_debug_drawer.dart';
import 'providers/connectivity_provider.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class AdaptiveScaffold extends ConsumerWidget {
  const AdaptiveScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isLocalOnly = ref.watch(isLocalMeshOnlyProvider);
    final colorScheme = Theme.of(context).colorScheme;

    const destinations = [
      NavigationDestination(
        icon: Icon(Icons.grid_view_rounded),
        selectedIcon: Icon(Icons.grid_view_sharp),
        label: 'Dashboard',
      ),
      NavigationDestination(
        icon: Icon(Icons.hub_outlined),
        selectedIcon: Icon(Icons.hub_rounded),
        label: 'Matter Mesh',
      ),
      NavigationDestination(
        icon: Icon(Icons.bolt_outlined),
        selectedIcon: Icon(Icons.bolt_rounded),
        label: 'Energy',
      ),
      NavigationDestination(
        icon: Icon(Icons.auto_mode_outlined),
        selectedIcon: Icon(Icons.auto_mode_rounded),
        label: 'Automation',
      ),
      NavigationDestination(
        icon: Icon(Icons.psychology_outlined),
        selectedIcon: Icon(Icons.psychology_rounded),
        label: 'AI Copilot',
      ),
    ];

    const screens = [
      DashboardView(),
      MatterMeshView(),
      EnergyView(),
      AutomationView(),
      AiHomeCopilotView(),
    ];

    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        final appBar = AppBar(
          toolbarHeight: isLandscape ? 36 : 56,
          backgroundColor: colorScheme.surfaceContainer,
          title: Row(
            children: [
              Container(
                width: isLandscape ? 22 : 28,
                height: isLandscape ? 22 : 28,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sensors_rounded,
                  size: isLandscape ? 14 : 18,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'NexusHome',
                style: TextStyle(
                  fontSize: isLandscape ? 13 : 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: isLandscape ? 0.8 : 1.2,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'MATTER 1.3',
                  style: TextStyle(
                    fontSize: isLandscape ? 8 : 10,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              iconSize: isLandscape ? 18 : 22,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: isLandscape ? 32 : 40,
                minHeight: isLandscape ? 32 : 40,
              ),
              icon: Icon(
                themeMode == ThemeMode.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              tooltip: 'Toggle Theme',
              onPressed: () {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
            ),
            IconButton(
              iconSize: isLandscape ? 18 : 22,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: isLandscape ? 32 : 40,
                minHeight: isLandscape ? 32 : 40,
              ),
              icon: Icon(
                Icons.settings_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              tooltip: 'Settings & Recruiter Diagnostics',
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SettingsView()));
              },
            ),
            const SizedBox(width: 6),
          ],
        );

        final offlineBanner = isLocalOnly
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 12,
                ),
                color: colorScheme.secondaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lan_outlined,
                      size: 14,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Local LAN / Thread Mesh Mode - Executing Zero-Cloud Automations via Local SQLite',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink();

        if (isLandscape) {
          return Scaffold(
            appBar: appBar,
            endDrawer: const RecruiterDebugDrawer(),
            body: Column(
              children: [
                offlineBanner,
                Expanded(
                  child: Row(
                    children: [
                      SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: IntrinsicHeight(
                          child: NavigationRail(
                            minWidth: 56,
                            selectedIndex: currentIndex,
                            labelType: NavigationRailLabelType.none,
                            onDestinationSelected: (index) {
                              ref.read(navigationIndexProvider.notifier).state =
                                  index;
                            },
                            destinations: const [
                              NavigationRailDestination(
                                icon: Icon(Icons.grid_view_rounded, size: 20),
                                selectedIcon: Icon(
                                  Icons.grid_view_sharp,
                                  size: 20,
                                ),
                                label: Text('Dashboard'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.hub_outlined, size: 20),
                                selectedIcon: Icon(Icons.hub_rounded, size: 20),
                                label: Text('Matter Mesh'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.bolt_outlined, size: 20),
                                selectedIcon: Icon(
                                  Icons.bolt_rounded,
                                  size: 20,
                                ),
                                label: Text('Energy'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.auto_mode_outlined, size: 20),
                                selectedIcon: Icon(
                                  Icons.auto_mode_rounded,
                                  size: 20,
                                ),
                                label: Text('Automation'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.psychology_outlined, size: 20),
                                selectedIcon: Icon(
                                  Icons.psychology_rounded,
                                  size: 20,
                                ),
                                label: Text('AI Copilot'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 1, thickness: 1),
                      Expanded(
                        child: IndexedStack(
                          index: currentIndex,
                          children: screens,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Portrait Layout
        return Scaffold(
          appBar: appBar,
          endDrawer: const RecruiterDebugDrawer(),
          body: Column(
            children: [
              offlineBanner,
              Expanded(
                child: IndexedStack(index: currentIndex, children: screens),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            height: 64,
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              ref.read(navigationIndexProvider.notifier).state = index;
            },
            destinations: destinations,
          ),
        );
      },
    );
  }
}
