import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../../core/platform/matter_native_bridge.dart';
import '../models/mesh_node_model.dart';

class MeshRepository {
  final AppDatabase appDatabase;
  final MatterNativeBridge matterBridge;

  MeshRepository({required this.appDatabase, required this.matterBridge});

  Future<List<MeshNodeModel>> getAllNodes() async {
    final db = await appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mesh_nodes',
      orderBy: 'hop_count ASC, node_name ASC',
    );
    return maps.map((m) => MeshNodeModel.fromMap(m)).toList();
  }

  Future<void> addNode(MeshNodeModel node) async {
    final db = await appDatabase.database;
    await db.insert(
      'mesh_nodes',
      node.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> runMeshDiagnostics() async {
    return await matterBridge.runMeshDiagnostics();
  }
}
