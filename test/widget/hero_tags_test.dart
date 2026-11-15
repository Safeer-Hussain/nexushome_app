import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_home_app/core/di/injection.dart';
import 'package:nexus_home_app/core/theme/app_theme.dart';
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

  testWidgets('Zero duplicate Hero tag exceptions across multi-tab shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const AdaptiveScaffold(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify initial load has no hero tag conflicts
    expect(tester.takeException(), isNull);

    // Switch to Matter Mesh tab (index 1)
    await tester.tap(find.byIcon(Icons.hub_outlined));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);

    // Switch to Automation tab (index 3)
    await tester.tap(find.byIcon(Icons.auto_mode_outlined));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);

    // Switch to AI Copilot tab (index 4)
    await tester.tap(find.byIcon(Icons.psychology_outlined));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);

    // Switch back to Dashboard (index 0)
    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}
