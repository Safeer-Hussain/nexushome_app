import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_home_app/core/di/injection.dart';
import 'package:nexus_home_app/core/theme/app_theme.dart';
import 'package:nexus_home_app/data/repositories/automation_repository.dart';
import 'package:nexus_home_app/data/repositories/device_repository.dart';
import 'package:nexus_home_app/data/repositories/emergency_repository.dart';
import 'package:nexus_home_app/data/repositories/mesh_repository.dart';
import 'package:nexus_home_app/domain/entities/emergency_event.dart';
import 'package:nexus_home_app/presentation/common/widgets/emergency_alert_banner.dart';
import 'package:nexus_home_app/presentation/providers/device_provider.dart';
import 'package:nexus_home_app/presentation/providers/emergency_provider.dart';

import '../helpers/mock_repositories.dart';

void main() {
  late FakeDeviceRepository deviceRepo;
  late FakeEmergencyRepository emergencyRepo;

  setUp(() {
    getIt.reset();
    deviceRepo = FakeDeviceRepository();
    emergencyRepo = FakeEmergencyRepository();
    getIt.registerSingleton<DeviceRepository>(deviceRepo);
    getIt.registerSingleton<MeshRepository>(FakeMeshRepository());
    getIt.registerSingleton<AutomationRepository>(FakeAutomationRepository());
    getIt.registerSingleton<EmergencyRepository>(emergencyRepo);
    setupDependencyInjection();
  });

  testWidgets(
    'EmergencyAlertBanner renders emergency details and dismisses on tap',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          deviceListProvider.overrideWith(
            (ref) => DeviceListNotifier(deviceRepo),
          ),
          emergencyRepositoryProvider.overrideWithValue(emergencyRepo),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(body: EmergencyAlertBanner()),
          ),
        ),
      );
      await tester.pump();

      // Initially no active emergency, banner is hidden
      expect(find.byType(EmergencyAlertBanner), findsOneWidget);
      expect(find.text('CRITICAL EMERGENCY OVERRIDE ACTIVE'), findsNothing);

      // Trigger smoke emergency
      await container
          .read(emergencyProvider.notifier)
          .triggerEmergency(
            type: EmergencyType.smoke,
            sourceDeviceId: 'dev_smoke_kitchen',
            sourceDeviceName: 'Kitchen Smoke Detector',
            room: 'Kitchen',
          );
      await tester.pumpAndSettle();

      expect(find.text('CRITICAL EMERGENCY OVERRIDE ACTIVE'), findsOneWidget);
      expect(find.text('Exit Doors: UNLOCKED'), findsOneWidget);
      expect(find.text('Lighting: 2700K AMBER'), findsOneWidget);

      // Tap dismiss icon button
      final dismissBtn = find.byTooltip('Dismiss Alert');
      expect(dismissBtn, findsOneWidget);
      await tester.tap(dismissBtn);
      await tester.pumpAndSettle();

      expect(find.text('CRITICAL EMERGENCY OVERRIDE ACTIVE'), findsNothing);
    },
  );

  testWidgets(
    'EmergencyAlertBanner is safe without overflow on 800x360 landscape viewport',
    (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          deviceListProvider.overrideWith(
            (ref) => DeviceListNotifier(deviceRepo),
          ),
          emergencyRepositoryProvider.overrideWithValue(emergencyRepo),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(emergencyProvider.notifier)
          .triggerEmergency(
            type: EmergencyType.waterLeak,
            sourceDeviceId: 'dev_water_leak',
            sourceDeviceName: 'Basement Sensor',
            room: 'Solar Garage',
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(body: EmergencyAlertBanner()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('CRITICAL EMERGENCY OVERRIDE ACTIVE'), findsOneWidget);
      expect(find.text('Main Water: SHUT OFF'), findsOneWidget);
    },
  );
}
