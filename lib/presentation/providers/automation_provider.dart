import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection.dart';
import '../../data/models/automation_rule_model.dart';
import '../../data/models/scene_model.dart';
import '../../data/repositories/automation_repository.dart';
import '../../domain/entities/automation_rule_entity.dart';
import '../../domain/entities/scene_entity.dart';
import 'device_provider.dart';

final scenesListProvider =
    StateNotifierProvider<ScenesListNotifier, List<SceneEntity>>((ref) {
      final repo = getIt<AutomationRepository>();
      return ScenesListNotifier(repo, ref);
    });

class ScenesListNotifier extends StateNotifier<List<SceneEntity>> {
  final AutomationRepository _repository;
  final Ref _ref;

  ScenesListNotifier(this._repository, this._ref) : super([]) {
    loadScenes();
  }

  Future<void> loadScenes() async {
    final scenes = await _repository.getAllScenes();
    state = scenes;
  }

  Future<void> executeScene(SceneEntity scene) async {
    await _repository.executeScene(
      SceneModel(
        id: scene.id,
        title: scene.title,
        description: scene.description,
        iconName: scene.iconName,
        deviceActionsJson: scene.deviceActionsJson,
      ),
    );
    // Immediately reload devices in SQLite
    await _ref.read(deviceListProvider.notifier).loadDevices();
  }
}

final rulesListProvider =
    StateNotifierProvider<RulesListNotifier, List<AutomationRuleEntity>>((ref) {
      final repo = getIt<AutomationRepository>();
      return RulesListNotifier(repo);
    });

class RulesListNotifier extends StateNotifier<List<AutomationRuleEntity>> {
  final AutomationRepository _repository;

  RulesListNotifier(this._repository) : super([]) {
    loadRules();
  }

  Future<void> loadRules() async {
    final rules = await _repository.getAllRules();
    state = rules;
  }

  Future<void> toggleRule(String id) async {
    final index = state.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final updated = state[index].copyWith(isEnabled: !state[index].isEnabled);
    state = [
      for (final rule in state)
        if (rule.id == id) updated else rule,
    ];

    await _repository.toggleRule(id, updated.isEnabled);
  }

  Future<void> createRule(AutomationRuleEntity rule) async {
    final model = AutomationRuleModel.fromEntity(rule);
    await _repository.createRule(model);
    state = [rule, ...state];
  }

  Future<void> deleteRule(String id) async {
    await _repository.deleteRule(id);
    state = state.where((r) => r.id != id).toList();
  }
}
