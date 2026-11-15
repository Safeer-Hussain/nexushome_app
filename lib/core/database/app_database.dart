import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  Database? _db;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (kIsWeb) {
      path = 'nexushome_web.db';
    } else {
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        path = join(docsDir.path, 'nexushome.db');
      } catch (_) {
        final dbDir = await getDatabasesPath();
        path = join(dbDir, 'nexushome.db');
      }
    }

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Support in-memory DB for pure unit testing
  Future<void> initInMemory() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    _db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Devices Table
    await db.execute('''
      CREATE TABLE devices (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        room TEXT NOT NULL,
        type TEXT NOT NULL,
        protocol TEXT NOT NULL,
        is_powered INTEGER NOT NULL DEFAULT 0,
        brightness INTEGER NOT NULL DEFAULT 80,
        color_temp INTEGER NOT NULL DEFAULT 3500,
        target_temp REAL NOT NULL DEFAULT 22.0,
        current_temp REAL NOT NULL DEFAULT 22.5,
        hvac_mode TEXT NOT NULL DEFAULT 'cool',
        is_locked INTEGER NOT NULL DEFAULT 1,
        position INTEGER NOT NULL DEFAULT 0,
        power_watts REAL NOT NULL DEFAULT 0.0,
        rssi INTEGER NOT NULL DEFAULT -55,
        pairing_code TEXT,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 2. Mesh Nodes Table
    await db.execute('''
      CREATE TABLE mesh_nodes (
        id TEXT PRIMARY KEY,
        device_id TEXT NOT NULL,
        node_name TEXT NOT NULL,
        node_type TEXT NOT NULL,
        protocol TEXT NOT NULL,
        rssi INTEGER NOT NULL,
        hop_count INTEGER NOT NULL,
        status TEXT NOT NULL,
        x_pos REAL NOT NULL,
        y_pos REAL NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 3. Automation Rules Table
    await db.execute('''
      CREATE TABLE automation_rules (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        trigger_type TEXT NOT NULL,
        trigger_value TEXT NOT NULL,
        action_type TEXT NOT NULL,
        action_target TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');

    // 4. Scenes Table
    await db.execute('''
      CREATE TABLE scenes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        device_actions_json TEXT NOT NULL
      )
    ''');

    // 5. Security Events Table
    await db.execute('''
      CREATE TABLE security_events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        device_id TEXT NOT NULL,
        device_name TEXT NOT NULL,
        room TEXT NOT NULL,
        severity TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');

    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Seed Initial Devices
    final initialDevices = [
      {
        'id': 'dev_living_ambient_light',
        'name': 'Living Room Ambient Light',
        'room': 'Living Room',
        'type': 'light',
        'protocol': 'Thread 1.3',
        'is_powered': 1,
        'brightness': 85,
        'color_temp': 3200,
        'target_temp': 22.0,
        'current_temp': 22.4,
        'hvac_mode': 'cool',
        'is_locked': 1,
        'position': 0,
        'power_watts': 24.5,
        'rssi': -48,
        'pairing_code': '8234-9120-441',
        'updated_at': now,
      },
      {
        'id': 'dev_living_hvac',
        'name': 'Living Climate Controller',
        'room': 'Living Room',
        'type': 'hvac',
        'protocol': 'Matter over Wi-Fi',
        'is_powered': 1,
        'brightness': 0,
        'color_temp': 0,
        'target_temp': 21.5,
        'current_temp': 22.8,
        'hvac_mode': 'cool',
        'is_locked': 1,
        'position': 0,
        'power_watts': 840.0,
        'rssi': -52,
        'pairing_code': '4510-8821-903',
        'updated_at': now,
      },
      {
        'id': 'dev_main_entrance_lock',
        'name': 'Front Portal Deadbolt',
        'room': 'Living Room',
        'type': 'lock',
        'protocol': 'Thread 1.3',
        'is_powered': 1,
        'brightness': 0,
        'color_temp': 0,
        'target_temp': 22.0,
        'current_temp': 22.0,
        'hvac_mode': 'off',
        'is_locked': 1,
        'position': 0,
        'power_watts': 4.2,
        'rssi': -44,
        'pairing_code': '1940-5562-110',
        'updated_at': now,
      },
      {
        'id': 'dev_living_blinds',
        'name': 'Panoramic Smart Blinds',
        'room': 'Living Room',
        'type': 'blinds',
        'protocol': 'Thread 1.3',
        'is_powered': 1,
        'brightness': 0,
        'color_temp': 0,
        'target_temp': 22.0,
        'current_temp': 22.0,
        'hvac_mode': 'off',
        'is_locked': 0,
        'position': 70,
        'power_watts': 18.0,
        'rssi': -61,
        'pairing_code': '9941-2301-447',
        'updated_at': now,
      },
      {
        'id': 'dev_master_ceiling_light',
        'name': 'Master Suite Chandelier',
        'room': 'Master Suite',
        'type': 'light',
        'protocol': 'Thread 1.3',
        'is_powered': 0,
        'brightness': 50,
        'color_temp': 2700,
        'target_temp': 21.0,
        'current_temp': 21.8,
        'hvac_mode': 'cool',
        'is_locked': 1,
        'position': 0,
        'power_watts': 0.0,
        'rssi': -58,
        'pairing_code': '3310-4491-002',
        'updated_at': now,
      },
      {
        'id': 'dev_kitchen_island_light',
        'name': 'Culinary Luminaire Array',
        'room': 'Kitchen',
        'type': 'light',
        'protocol': 'BLE Mesh',
        'is_powered': 1,
        'brightness': 100,
        'color_temp': 4500,
        'target_temp': 22.0,
        'current_temp': 23.1,
        'hvac_mode': 'off',
        'is_locked': 1,
        'position': 0,
        'power_watts': 65.0,
        'rssi': -50,
        'pairing_code': '7781-4402-998',
        'updated_at': now,
      },
      {
        'id': 'dev_office_workstation_light',
        'name': 'Studio Task Spotlight',
        'room': 'Home Office',
        'type': 'light',
        'protocol': 'Thread 1.3',
        'is_powered': 1,
        'brightness': 90,
        'color_temp': 4000,
        'target_temp': 22.0,
        'current_temp': 22.0,
        'hvac_mode': 'off',
        'is_locked': 1,
        'position': 0,
        'power_watts': 28.0,
        'rssi': -42,
        'pairing_code': '8830-1124-775',
        'updated_at': now,
      },
      {
        'id': 'dev_garage_inverter_monitor',
        'name': 'Solar Inverter Hub',
        'room': 'Solar Garage',
        'type': 'sensor',
        'protocol': 'Matter over Wi-Fi',
        'is_powered': 1,
        'brightness': 0,
        'color_temp': 0,
        'target_temp': 24.0,
        'current_temp': 24.5,
        'hvac_mode': 'off',
        'is_locked': 1,
        'position': 0,
        'power_watts': 35.0,
        'rssi': -40,
        'pairing_code': '1240-9903-881',
        'updated_at': now,
      },
    ];

    for (final dev in initialDevices) {
      await db.insert('devices', dev);
    }

    // Seed Mesh Nodes
    final initialNodes = [
      {
        'id': 'node_border_router',
        'device_id': 'dev_border_router_hub',
        'node_name': 'Nexus Border Router 01',
        'node_type': 'border_router',
        'protocol': 'Thread 1.3',
        'rssi': -32,
        'hop_count': 0,
        'status': 'active',
        'x_pos': 0.50,
        'y_pos': 0.50,
        'updated_at': now,
      },
      {
        'id': 'node_router_living',
        'device_id': 'dev_living_ambient_light',
        'node_name': 'Living Room Router Node',
        'node_type': 'router',
        'protocol': 'Thread 1.3',
        'rssi': -48,
        'hop_count': 1,
        'status': 'active',
        'x_pos': 0.28,
        'y_pos': 0.32,
        'updated_at': now,
      },
      {
        'id': 'node_router_kitchen',
        'device_id': 'dev_kitchen_island_light',
        'node_name': 'Kitchen Relay Node',
        'node_type': 'router',
        'protocol': 'Thread 1.3',
        'rssi': -50,
        'hop_count': 1,
        'status': 'active',
        'x_pos': 0.72,
        'y_pos': 0.30,
        'updated_at': now,
      },
      {
        'id': 'node_end_lock',
        'device_id': 'dev_main_entrance_lock',
        'node_name': 'Entrance Deadbolt Node',
        'node_type': 'end_device',
        'protocol': 'Thread 1.3',
        'rssi': -44,
        'hop_count': 2,
        'status': 'active',
        'x_pos': 0.20,
        'y_pos': 0.70,
        'updated_at': now,
      },
      {
        'id': 'node_end_blinds',
        'device_id': 'dev_living_blinds',
        'node_name': 'Panoramic Blinds Node',
        'node_type': 'end_device',
        'protocol': 'Thread 1.3',
        'rssi': -61,
        'hop_count': 2,
        'status': 'active',
        'x_pos': 0.42,
        'y_pos': 0.82,
        'updated_at': now,
      },
      {
        'id': 'node_end_office',
        'device_id': 'dev_office_workstation_light',
        'node_name': 'Office Task Node',
        'node_type': 'end_device',
        'protocol': 'Thread 1.3',
        'rssi': -42,
        'hop_count': 2,
        'status': 'active',
        'x_pos': 0.78,
        'y_pos': 0.68,
        'updated_at': now,
      },
    ];

    for (final node in initialNodes) {
      await db.insert('mesh_nodes', node);
    }

    // Seed Quick Scenes
    final initialScenes = [
      {
        'id': 'scene_good_morning',
        'title': 'Good Morning',
        'description':
            'Warm lighting, disarm indoor sensors, adjust climate to 22.0°C',
        'icon_name': 'wb_sunny_rounded',
        'device_actions_json': jsonEncode([
          {
            'deviceId': 'dev_living_ambient_light',
            'isPowered': 1,
            'brightness': 70,
            'colorTemp': 3000,
          },
          {
            'deviceId': 'dev_living_hvac',
            'isPowered': 1,
            'targetTemp': 22.0,
            'hvacMode': 'cool',
          },
          {'deviceId': 'dev_living_blinds', 'position': 80},
        ]),
      },
      {
        'id': 'scene_away_armed',
        'title': 'Away & Armed',
        'description': 'Power off lighting, arm perimeter deadbolts, eco thermostat 25.0°C',
        'icon_name': 'shield_rounded',
        'device_actions_json': jsonEncode([
          {'deviceId': 'dev_living_ambient_light', 'isPowered': 0},
          {'deviceId': 'dev_master_ceiling_light', 'isPowered': 0},
          {'deviceId': 'dev_kitchen_island_light', 'isPowered': 0},
          {'deviceId': 'dev_office_workstation_light', 'isPowered': 0},
          {'deviceId': 'dev_main_entrance_lock', 'isLocked': 1},
          {
            'deviceId': 'dev_living_hvac',
            'isPowered': 1,
            'targetTemp': 25.0,
            'hvacMode': 'eco',
          },
        ]),
      },
      {
        'id': 'scene_cinema_mode',
        'title': 'Cinema Mode',
        'description':
            'Dim living light to 15%, close panoramic blinds, silent HVAC',
        'icon_name': 'movie_filter_rounded',
        'device_actions_json': jsonEncode([
          {
            'deviceId': 'dev_living_ambient_light',
            'isPowered': 1,
            'brightness': 15,
            'colorTemp': 2400,
          },
          {'deviceId': 'dev_living_blinds', 'position': 0},
          {
            'deviceId': 'dev_living_hvac',
            'targetTemp': 21.0,
            'hvacMode': 'cool',
          },
        ]),
      },
      {
        'id': 'scene_eco_peak_saver',
        'title': 'Eco Peak Saver',
        'description':
            'Shed non-critical wattage, prioritize solar battery discharge',
        'icon_name': 'energy_savings_leaf_rounded',
        'device_actions_json': jsonEncode([
          {'deviceId': 'dev_living_ambient_light', 'brightness': 40},
          {
            'deviceId': 'dev_living_hvac',
            'targetTemp': 24.5,
            'hvacMode': 'eco',
          },
          {'deviceId': 'dev_kitchen_island_light', 'brightness': 50},
        ]),
      },
    ];

    for (final scn in initialScenes) {
      await db.insert('scenes', scn);
    }

    // Seed Automation Rules
    final initialRules = [
      {
        'id': 'rule_solar_overgeneration',
        'title': 'Solar Peak Generation Buffer',
        'trigger_type': 'Solar Gen > 4.5 kW',
        'trigger_value': '4500',
        'action_type': 'Pre-cool living room to 20°C',
        'action_target': 'dev_living_hvac',
        'is_enabled': 1,
        'created_at': now - 86400000,
      },
      {
        'id': 'rule_sunset_ambient',
        'title': 'Astronomical Sunset Lighting',
        'trigger_type': 'Sunset Detection',
        'trigger_value': 'sunset',
        'action_type': 'Illuminate warm architectural glow 60%',
        'action_target': 'dev_living_ambient_light',
        'is_enabled': 1,
        'created_at': now - 43200000,
      },
      {
        'id': 'rule_perimeter_night_lock',
        'title': 'Nightfall Perimeter Lockdown',
        'trigger_type': 'Time 23:00',
        'trigger_value': '23:00',
        'action_type': 'Secure smart deadbolts & shut blinds',
        'action_target': 'dev_main_entrance_lock',
        'is_enabled': 1,
        'created_at': now - 21600000,
      },
    ];

    for (final rule in initialRules) {
      await db.insert('automation_rules', rule);
    }

    // Seed Security Events
    final initialSecurity = [
      {
        'id': 'sec_evt_01',
        'title': 'Front Door Deadbolt Secured',
        'device_id': 'dev_main_entrance_lock',
        'device_name': 'Front Portal Deadbolt',
        'room': 'Living Room',
        'severity': 'info',
        'timestamp': now - 1800000,
      },
      {
        'id': 'sec_evt_02',
        'title': 'Porch PIR Motion Verified',
        'device_id': 'dev_security_cam_01',
        'device_name': 'Entrance Security Sentinel',
        'room': 'Living Room',
        'severity': 'warning',
        'timestamp': now - 3600000,
      },
      {
        'id': 'sec_evt_03',
        'title': 'Perimeter Security Armed Away',
        'device_id': 'system_sentinel',
        'device_name': 'Nexus Sentinel Hub',
        'room': 'All Zones',
        'severity': 'info',
        'timestamp': now - 7200000,
      },
    ];

    for (final sec in initialSecurity) {
      await db.insert('security_events', sec);
    }
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
