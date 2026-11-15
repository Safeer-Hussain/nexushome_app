import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../models/security_event_model.dart';

class SecurityRepository {
  final AppDatabase appDatabase;

  SecurityRepository({required this.appDatabase});

  Future<List<SecurityEventModel>> getSecurityEvents() async {
    final db = await appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'security_events',
      orderBy: 'timestamp DESC',
      limit: 20,
    );
    return maps.map((m) => SecurityEventModel.fromMap(m)).toList();
  }

  Future<void> addSecurityEvent(SecurityEventModel event) async {
    final db = await appDatabase.database;
    await db.insert(
      'security_events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
