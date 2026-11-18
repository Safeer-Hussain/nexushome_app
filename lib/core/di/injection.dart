import 'package:get_it/get_it.dart';

import '../database/app_database.dart';
import '../platform/matter_native_bridge.dart';
import '../../data/repositories/device_repository.dart';
import '../../data/repositories/mesh_repository.dart';
import '../../data/repositories/automation_repository.dart';
import '../../data/repositories/security_repository.dart';
import '../../data/repositories/energy_repository.dart';
import '../../data/repositories/emergency_repository.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerSingleton<AppDatabase>(AppDatabase.instance);
  }
  if (!getIt.isRegistered<MatterNativeBridge>()) {
    getIt.registerSingleton<MatterNativeBridge>(MatterNativeBridge());
  }
  if (!getIt.isRegistered<DeviceRepository>()) {
    getIt.registerLazySingleton<DeviceRepository>(
      () => DeviceRepository(
        appDatabase: getIt<AppDatabase>(),
        matterBridge: getIt<MatterNativeBridge>(),
      ),
    );
  }
  if (!getIt.isRegistered<MeshRepository>()) {
    getIt.registerLazySingleton<MeshRepository>(
      () => MeshRepository(
        appDatabase: getIt<AppDatabase>(),
        matterBridge: getIt<MatterNativeBridge>(),
      ),
    );
  }
  if (!getIt.isRegistered<AutomationRepository>()) {
    getIt.registerLazySingleton<AutomationRepository>(
      () => AutomationRepository(
        appDatabase: getIt<AppDatabase>(),
        matterBridge: getIt<MatterNativeBridge>(),
      ),
    );
  }
  if (!getIt.isRegistered<SecurityRepository>()) {
    getIt.registerLazySingleton<SecurityRepository>(
      () => SecurityRepository(appDatabase: getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<EnergyRepository>()) {
    getIt.registerLazySingleton<EnergyRepository>(
      () => EnergyRepository(matterBridge: getIt<MatterNativeBridge>()),
    );
  }
  if (!getIt.isRegistered<EmergencyRepository>()) {
    getIt.registerLazySingleton<EmergencyRepository>(
      () => EmergencyRepository(
        appDatabase: getIt<AppDatabase>(),
        matterBridge: getIt<MatterNativeBridge>(),
      ),
    );
  }
}
