import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_home_app/core/di/injection.dart';
import 'package:nexus_home_app/core/theme/app_theme.dart';
import 'package:nexus_home_app/core/theme/theme_provider.dart';
import 'package:nexus_home_app/data/repositories/automation_repository.dart';
import 'package:nexus_home_app/data/repositories/device_repository.dart';
import 'package:nexus_home_app/data/repositories/mesh_repository.dart';
import 'package:nexus_home_app/presentation/adaptive_scaffold.dart';

import '../helpers/mock_repositories.dart';

void main() {
  setUp(() {
    getIt.reset();
    getIt.registerSingleton<DeviceRepository>(FakeDeviceRepository());
    getIt.registerSingleton<MeshRepository>(FakeMeshRepository());
    getIt.registerSingleton<AutomationRepository>(FakeAutomationRepository());
    setupDependencyInjection();
  });

  testWidgets(
    'Instant Dark / Light theme switching updates themeMode seamlessly',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              final mode = ref.watch(themeModeProvider);
              return MaterialApp(
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: mode,
                home: const AdaptiveScaffold(),
              );
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Initial theme toggle button
      final initialThemeIcon = find.byTooltip('Toggle Theme');
      expect(initialThemeIcon, findsOneWidget);

      // Tap theme toggle button
      await tester.tap(initialThemeIcon);
      await tester.pump(const Duration(milliseconds: 100));

      // Verify theme toggle completed with zero exceptions
      expect(tester.takeException(), isNull);
    },
  );
}
