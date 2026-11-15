import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_home_app/presentation/providers/mesh_provider.dart';

import '../helpers/mock_repositories.dart';

void main() {
  group('MeshListNotifier Unit Tests', () {
    late FakeMeshRepository repository;
    late MeshListNotifier notifier;

    setUp(() {
      repository = FakeMeshRepository();
      notifier = MeshListNotifier(repository);
    });

    test('Loads initial mesh nodes into state', () async {
      await notifier.loadMesh();
      expect(notifier.state.length, equals(2));
      expect(notifier.state.first.nodeName, equals('Nexus Border Router 01'));
    });

    test('Runs self-healing diagnostics and optimizes nodes', () async {
      await notifier.loadMesh();
      final metrics = await notifier.runSelfHealingDiagnostics();

      expect(metrics['status'], equals('HEALTHY'));
      expect(metrics['averageHopLatencyMs'], equals(14.2));
      expect(notifier.state.first.rssi, equals(-30));
    });

    test('Commissions new node and appends to mesh state', () async {
      await notifier.loadMesh();
      final initialCount = notifier.state.length;

      await notifier.commissionNewNode(
        deviceId: 'dev_test_plug',
        nodeName: 'Smart Plug Node',
        protocol: 'Thread 1.3',
        nodeType: 'router',
      );

      expect(notifier.state.length, equals(initialCount + 1));
      expect(notifier.state.last.nodeName, equals('Smart Plug Node'));
      expect(notifier.state.last.nodeType, equals('router'));
    });
  });
}
