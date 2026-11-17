import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_home_app/core/di/injection.dart';
import 'package:nexus_home_app/core/theme/app_theme.dart';
import 'package:nexus_home_app/data/models/device_model.dart';
import 'package:nexus_home_app/data/repositories/automation_repository.dart';
import 'package:nexus_home_app/data/repositories/device_repository.dart';
import 'package:nexus_home_app/data/repositories/mesh_repository.dart';
import 'package:nexus_home_app/presentation/dashboard/widgets/device_control_sheet.dart';
import 'package:nexus_home_app/presentation/providers/device_provider.dart';

import '../helpers/mock_repositories.dart';

void main() {
  late FakeDeviceRepository repo;

  setUp(() {
    getIt.reset();
    repo = FakeDeviceRepository();
    getIt.registerSingleton<DeviceRepository>(repo);
    getIt.registerSingleton<MeshRepository>(FakeMeshRepository());
    getIt.registerSingleton<AutomationRepository>(FakeAutomationRepository());
    setupDependencyInjection();
  });

  testWidgets(
    'DeviceControlSheet renders Circadian Adaptive Curve card and Kelvin presets for lights',
    (tester) async {
      final sampleLight = DeviceModel(
        id: 'dev_test_light',
        name: 'Accent Pendant Light',
        room: 'Living Room',
        type: 'light',
        protocol: 'Thread 1.3',
        isPowered: true,
        brightness: 80,
        colorTemp: 3500,
        circadianModeEnabled: true,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deviceListProvider.overrideWith((ref) => DeviceListNotifier(repo)),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(body: DeviceControlSheet(device: sampleLight)),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Circadian Adaptive Curve'), findsOneWidget);
      expect(find.text('Brightness'), findsOneWidget);
      expect(find.text('Color Temperature'), findsOneWidget);
      expect(find.text('2700K Rest'), findsOneWidget);
      expect(find.text('3500K Ambient'), findsOneWidget);
      expect(find.text('5500K Daylight'), findsOneWidget);

      // Tap 5500K preset chip
      await tester.tap(find.text('5500K Daylight'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('5500K'), findsWidgets);
    },
  );

  testWidgets(
    'Circadian controls render safely without overflow on 800x360 landscape viewport',
    (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final sampleLight = DeviceModel(
        id: 'dev_test_light_landscape',
        name: 'Dining Chandelier',
        room: 'Kitchen',
        type: 'light',
        protocol: 'Thread 1.3',
        isPowered: true,
        brightness: 90,
        colorTemp: 4000,
        circadianModeEnabled: true,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deviceListProvider.overrideWith((ref) => DeviceListNotifier(repo)),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(body: DeviceControlSheet(device: sampleLight)),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('Circadian Adaptive Curve'), findsOneWidget);
    },
  );
}
