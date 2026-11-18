import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../../core/platform/matter_native_bridge.dart';
import '../models/emergency_event_model.dart';

class EmergencyRepository {
  final AppDatabase appDatabase;
  final MatterNativeBridge matterBridge;

  EmergencyRepository({required this.appDatabase, required this.matterBridge});

  Future<List<EmergencyEventModel>> getActiveEmergencies() async {
    final db = await appDatabase.database;
    final maps = await db.query(
      'emergency_events',
      where: 'is_resolved = 0',
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => EmergencyEventModel.fromMap(m)).toList();
  }

  Future<List<EmergencyEventModel>> getAllEmergencyHistory() async {
    final db = await appDatabase.database;
    final maps = await db.query(
      'emergency_events',
      orderBy: 'timestamp DESC',
      limit: 50,
    );
    return maps.map((m) => EmergencyEventModel.fromMap(m)).toList();
  }

  Future<void> recordEmergency(EmergencyEventModel event) async {
    final db = await appDatabase.database;
    await db.insert(
      'emergency_events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await matterBridge.triggerEmergencyOverride(
      eventType: event.type.name,
      sourceDevice: event.sourceDeviceName,
    );
  }

  Future<void> resolveEmergency(String id) async {
    final db = await appDatabase.database;
    await db.update(
      'emergency_events',
      {'is_resolved': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> resolveAllEmergencies() async {
    final db = await appDatabase.database;
    await db.update('emergency_events', {
      'is_resolved': 1,
    }, where: 'is_resolved = 0');
  }
}
