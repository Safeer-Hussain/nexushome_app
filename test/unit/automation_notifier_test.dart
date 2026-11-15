import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_home_app/core/di/injection.dart';
import 'package:nexus_home_app/data/repositories/automation_repository.dart';
import 'package:nexus_home_app/domain/entities/automation_rule_entity.dart';
import 'package:nexus_home_app/presentation/providers/automation_provider.dart';

import '../helpers/mock_repositories.dart';

void main() {
  group('Automation & Rules Notifier Unit Tests', () {
    late FakeAutomationRepository repository;
    late ProviderContainer container;
    late RulesListNotifier rulesNotifier;
    late ScenesListNotifier scenesNotifier;

    setUp(() {
      repository = FakeAutomationRepository();
      getIt.reset();
      getIt.registerSingleton<AutomationRepository>(repository);

      container = ProviderContainer();
      rulesNotifier = container.read(rulesListProvider.notifier);
      scenesNotifier = container.read(scenesListProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('Loads scenes and rules from repository', () async {
      await scenesNotifier.loadScenes();
      await rulesNotifier.loadRules();

      expect(scenesNotifier.state.length, equals(2));
      expect(scenesNotifier.state.first.title, equals('Good Morning'));
      expect(rulesNotifier.state.length, equals(1));
    });

    test('Toggles rule enabled state immutably', () async {
      await rulesNotifier.loadRules();
      final rule = rulesNotifier.state.first;
      expect(rule.isEnabled, isTrue);

      await rulesNotifier.toggleRule(rule.id);
      expect(rulesNotifier.state.first.isEnabled, isFalse);
    });

    test('Creates new automation rule and inserts at top', () async {
      await rulesNotifier.loadRules();
      final initialCount = rulesNotifier.state.length;

      final newRule = AutomationRuleEntity(
        id: 'rule_solar_buffer',
        title: 'Solar Buffer Rule',
        triggerType: 'Solar Gen > 4 kW',
        triggerValue: '4000',
        actionType: 'Pre-cool HVAC',
        actionTarget: 'Living Room',
        isEnabled: true,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await rulesNotifier.createRule(newRule);
      expect(rulesNotifier.state.length, equals(initialCount + 1));
      expect(rulesNotifier.state.first.title, equals('Solar Buffer Rule'));
    });

    test('Deletes automation rule by ID', () async {
      await rulesNotifier.loadRules();
      final ruleId = rulesNotifier.state.first.id;

      await rulesNotifier.deleteRule(ruleId);
      expect(rulesNotifier.state.any((r) => r.id == ruleId), isFalse);
    });
  });
}
