import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../../core/platform/matter_native_bridge.dart';
import '../models/automation_rule_model.dart';
import '../models/scene_model.dart';

class AutomationRepository {
  final AppDatabase appDatabase;
  final MatterNativeBridge matterBridge;

  AutomationRepository({required this.appDatabase, required this.matterBridge});

  Future<List<SceneModel>> getAllScenes() async {
    final db = await appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('scenes');
    return maps.map((m) => SceneModel.fromMap(m)).toList();
  }

  Future<List<AutomationRuleModel>> getAllRules() async {
    final db = await appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'automation_rules',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => AutomationRuleModel.fromMap(m)).toList();
  }

  Future<void> executeScene(SceneModel scene) async {
    final db = await appDatabase.database;
    final actions = jsonDecode(scene.deviceActionsJson) as List<dynamic>;

    final now = DateTime.now().millisecondsSinceEpoch;
    for (final act in actions) {
      final map = act as Map<String, dynamic>;
      final deviceId = map['deviceId'] as String;
      final updates = <String, dynamic>{'updated_at': now};

      if (map.containsKey('isPowered'))
        updates['is_powered'] = map['isPowered'];
      if (map.containsKey('brightness'))
        updates['brightness'] = map['brightness'];
      if (map.containsKey('colorTemp'))
        updates['color_temp'] = map['colorTemp'];
      if (map.containsKey('targetTemp'))
        updates['target_temp'] = map['targetTemp'];
      if (map.containsKey('hvacMode')) updates['hvac_mode'] = map['hvacMode'];
      if (map.containsKey('isLocked')) updates['is_locked'] = map['isLocked'];
      if (map.containsKey('position')) updates['position'] = map['position'];

      await db.update(
        'devices',
        updates,
        where: 'id = ?',
        whereArgs: [deviceId],
      );
    }

    await matterBridge.triggerAutomationScene(
      sceneId: scene.id,
      deviceCount: actions.length,
    );
  }

  Future<void> toggleRule(String id, bool isEnabled) async {
    final db = await appDatabase.database;
    await db.update(
      'automation_rules',
      {'is_enabled': isEnabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> createRule(AutomationRuleModel rule) async {
    final db = await appDatabase.database;
    await db.insert(
      'automation_rules',
      rule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteRule(String id) async {
    final db = await appDatabase.database;
    await db.delete('automation_rules', where: 'id = ?', whereArgs: [id]);
  }
}
