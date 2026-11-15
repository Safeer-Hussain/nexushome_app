import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection.dart';
import '../../data/models/mesh_node_model.dart';
import '../../data/repositories/mesh_repository.dart';
import '../../domain/entities/mesh_node_entity.dart';

final meshListProvider =
    StateNotifierProvider<MeshListNotifier, List<MeshNodeEntity>>((ref) {
      final repo = getIt<MeshRepository>();
      return MeshListNotifier(repo);
    });

final meshDiagnosticsProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

class MeshListNotifier extends StateNotifier<List<MeshNodeEntity>> {
  final MeshRepository _repository;

  MeshListNotifier(this._repository) : super([]) {
    loadMesh();
  }

  Future<void> loadMesh() async {
    final nodes = await _repository.getAllNodes();
    state = nodes;
  }

  Future<Map<String, dynamic>> runSelfHealingDiagnostics() async {
    final result = await _repository.runMeshDiagnostics();
    // Simulate slight signal strength improvement
    state = [
      for (final node in state)
        node.copyWith(
          rssi: node.nodeType == 'border_router'
              ? -30
              : (-42 - Random().nextInt(10)),
          status: 'active',
        ),
    ];
    return result;
  }

  Future<void> commissionNewNode({
    required String deviceId,
    required String nodeName,
    required String protocol,
    required String nodeType,
  }) async {
    final random = Random();
    final newNode = MeshNodeModel(
      id: 'node_${DateTime.now().millisecondsSinceEpoch}',
      deviceId: deviceId,
      nodeName: nodeName,
      nodeType: nodeType,
      protocol: protocol,
      rssi: -45 - random.nextInt(15),
      hopCount: nodeType == 'router' ? 1 : 2,
      status: 'active',
      xPos: 0.2 + random.nextDouble() * 0.6,
      yPos: 0.2 + random.nextDouble() * 0.6,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _repository.addNode(newNode);
    state = [...state, newNode];
  }
}
