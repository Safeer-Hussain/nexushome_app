import 'package:nexus_home_app/core/database/app_database.dart';
import 'package:nexus_home_app/core/platform/matter_native_bridge.dart';
import 'package:nexus_home_app/data/models/automation_rule_model.dart';
import 'package:nexus_home_app/data/models/device_model.dart';
import 'package:nexus_home_app/data/models/mesh_node_model.dart';
import 'package:nexus_home_app/data/models/scene_model.dart';
import 'package:nexus_home_app/data/repositories/automation_repository.dart';
import 'package:nexus_home_app/data/repositories/device_repository.dart';
import 'package:nexus_home_app/data/repositories/mesh_repository.dart';

class FakeDeviceRepository implements DeviceRepository {
  List<DeviceModel> devices = [];

  FakeDeviceRepository([List<DeviceModel>? initial]) {
    devices = initial != null ? List.from(initial) : _createSampleDevices();
  }

  @override
  AppDatabase get appDatabase => throw UnimplementedError();

  @override
  MatterNativeBridge get matterBridge => throw UnimplementedError();

  static List<DeviceModel> _createSampleDevices() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      DeviceModel(
        id: 'dev_living_ambient_light',
        name: 'Living Room Ambient Light',
        room: 'Living Room',
        type: 'light',
        protocol: 'Thread 1.3',
        isPowered: true,
        brightness: 85,
        colorTemp: 3200,
        targetTemp: 22.0,
        currentTemp: 22.4,
        hvacMode: 'cool',
        isLocked: true,
        position: 0,
        powerWatts: 24.5,
        rssi: -48,
        pairingCode: '8234-9120-441',
        updatedAt: now,
      ),
      DeviceModel(
        id: 'dev_living_hvac',
        name: 'Living Climate Controller',
        room: 'Living Room',
        type: 'hvac',
        protocol: 'Matter over Wi-Fi',
        isPowered: true,
        brightness: 0,
        colorTemp: 0,
        targetTemp: 21.5,
        currentTemp: 22.8,
        hvacMode: 'cool',
        isLocked: true,
        position: 0,
        powerWatts: 840.0,
        rssi: -52,
        pairingCode: '4510-8821-903',
        updatedAt: now,
      ),
      DeviceModel(
        id: 'dev_main_entrance_lock',
        name: 'Front Portal Deadbolt',
        room: 'Living Room',
        type: 'lock',
        protocol: 'Thread 1.3',
        isPowered: true,
        brightness: 0,
        colorTemp: 0,
        targetTemp: 22.0,
        currentTemp: 22.0,
        hvacMode: 'off',
        isLocked: true,
        position: 0,
        powerWatts: 4.2,
        rssi: -44,
        pairingCode: '1940-5562-110',
        updatedAt: now,
      ),
    ];
  }

  @override
  Future<List<DeviceModel>> getAllDevices() async => List.from(devices);

  @override
  Future<List<DeviceModel>> getDevicesByRoom(String room) async =>
      devices.where((d) => d.room == room).toList();

  @override
  Future<void> togglePower(String id, bool isPowered) async {
    final idx = devices.indexWhere((d) => d.id == id);
    if (idx != -1) {
      devices[idx] = DeviceModel.fromEntity(
        devices[idx].copyWith(isPowered: isPowered),
      );
    }
  }

  @override
  Future<void> updateAttributes(
    String id, {
    int? brightness,
    int? colorTemp,
    double? targetTemp,
    String? hvacMode,
    bool? isLocked,
    int? position,
  }) async {
    final idx = devices.indexWhere((d) => d.id == id);
    if (idx != -1) {
      devices[idx] = DeviceModel.fromEntity(
        devices[idx].copyWith(
          brightness: brightness,
          colorTemp: colorTemp,
          targetTemp: targetTemp,
          hvacMode: hvacMode,
          isLocked: isLocked,
          position: position,
        ),
      );
    }
  }

  @override
  Future<void> commissionDevice(DeviceModel device) async {
    devices.add(device);
  }

  @override
  Future<void> deleteDevice(String id) async {
    devices.removeWhere((d) => d.id == id);
  }
}

class FakeMeshRepository implements MeshRepository {
  List<MeshNodeModel> nodes = [];

  FakeMeshRepository() {
    final now = DateTime.now().millisecondsSinceEpoch;
    nodes = [
      MeshNodeModel(
        id: 'node_border_router',
        deviceId: 'dev_border_hub',
        nodeName: 'Nexus Border Router 01',
        nodeType: 'border_router',
        protocol: 'Thread 1.3',
        rssi: -32,
        hopCount: 0,
        status: 'active',
        xPos: 0.5,
        yPos: 0.5,
        updatedAt: now,
      ),
      MeshNodeModel(
        id: 'node_router_living',
        deviceId: 'dev_living_ambient_light',
        nodeName: 'Living Router Node',
        nodeType: 'router',
        protocol: 'Thread 1.3',
        rssi: -48,
        hopCount: 1,
        status: 'active',
        xPos: 0.3,
        yPos: 0.3,
        updatedAt: now,
      ),
    ];
  }

  @override
  AppDatabase get appDatabase => throw UnimplementedError();

  @override
  MatterNativeBridge get matterBridge => throw UnimplementedError();

  @override
  Future<List<MeshNodeModel>> getAllNodes() async => List.from(nodes);

  @override
  Future<void> addNode(MeshNodeModel node) async {
    nodes.add(node);
  }

  @override
  Future<Map<String, dynamic>> runMeshDiagnostics() async {
    return {
      'status': 'HEALTHY',
      'activeThreadRouters': 4,
      'averageHopLatencyMs': 14.2,
      'borderRouterReachability': '99.98%',
    };
  }
}

class FakeAutomationRepository implements AutomationRepository {
  List<SceneModel> scenes = [];
  List<AutomationRuleModel> rules = [];

  FakeAutomationRepository() {
    final now = DateTime.now().millisecondsSinceEpoch;
    scenes = [
      const SceneModel(
        id: 'scene_good_morning',
        title: 'Good Morning',
        description: 'Warm lighting, disarm indoor sensors',
        iconName: 'wb_sunny_rounded',
        deviceActionsJson: '[]',
      ),
      const SceneModel(
        id: 'scene_away_armed',
        title: 'Away & Armed',
        description: 'Power off lights, lock perimeter',
        iconName: 'shield_rounded',
        deviceActionsJson: '[]',
      ),
    ];
    rules = [
      AutomationRuleModel(
        id: 'rule_01',
        title: 'Nightfall Perimeter Lockdown',
        triggerType: 'Time 23:00',
        triggerValue: '23:00',
        actionType: 'Secure smart deadbolts',
        actionTarget: 'All Zones',
        isEnabled: true,
        createdAt: now,
      ),
    ];
  }

  @override
  AppDatabase get appDatabase => throw UnimplementedError();

  @override
  MatterNativeBridge get matterBridge => throw UnimplementedError();

  @override
  Future<List<SceneModel>> getAllScenes() async => List.from(scenes);

  @override
  Future<List<AutomationRuleModel>> getAllRules() async => List.from(rules);

  @override
  Future<void> executeScene(SceneModel scene) async {}

  @override
  Future<void> toggleRule(String id, bool isEnabled) async {
    final idx = rules.indexWhere((r) => r.id == id);
    if (idx != -1) {
      rules[idx] = AutomationRuleModel.fromEntity(
        rules[idx].copyWith(isEnabled: isEnabled),
      );
    }
  }

  @override
  Future<void> createRule(AutomationRuleModel rule) async {
    rules.insert(0, rule);
  }

  @override
  Future<void> deleteRule(String id) async {
    rules.removeWhere((r) => r.id == id);
  }
}
