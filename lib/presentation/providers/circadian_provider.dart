import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/circadian_state.dart';
import 'device_provider.dart';

class CircadianNotifierState {
  final CircadianState state;
  final bool isAutoSyncEnabled;
  final DateTime lastEvaluatedAt;
  final int affectedLightCount;

  const CircadianNotifierState({
    required this.state,
    this.isAutoSyncEnabled = true,
    required this.lastEvaluatedAt,
    this.affectedLightCount = 0,
  });

  CircadianNotifierState copyWith({
    CircadianState? state,
    bool? isAutoSyncEnabled,
    DateTime? lastEvaluatedAt,
    int? affectedLightCount,
  }) {
    return CircadianNotifierState(
      state: state ?? this.state,
      isAutoSyncEnabled: isAutoSyncEnabled ?? this.isAutoSyncEnabled,
      lastEvaluatedAt: lastEvaluatedAt ?? this.lastEvaluatedAt,
      affectedLightCount: affectedLightCount ?? this.affectedLightCount,
    );
  }
}

final circadianProvider =
    StateNotifierProvider<CircadianNotifier, CircadianNotifierState>((ref) {
      return CircadianNotifier(ref);
    });

class CircadianNotifier extends StateNotifier<CircadianNotifierState> {
  final Ref _ref;
  Timer? _periodicTimer;

  CircadianNotifier(this._ref)
    : super(
        CircadianNotifierState(
          state: AstronomicalSolarCalculator.calculate(),
          isAutoSyncEnabled: true,
          lastEvaluatedAt: DateTime.now(),
        ),
      ) {
    _startPeriodicEvaluation();
  }

  void _startPeriodicEvaluation() {
    _periodicTimer?.cancel();
    // Acceptance criteria: Evaluates every 15 minutes based on local astronomical time
    _periodicTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (state.isAutoSyncEnabled) {
        evaluateNow();
      }
    });
  }

  /// Evaluates astronomical solar curve and batch dispatches target Kelvin to all enabled Thread lights
  Future<void> evaluateNow({
    DateTime? simulatedTime,
    bool dispatchToLights = true,
  }) async {
    final now = simulatedTime ?? DateTime.now();
    final newCircadianState = AstronomicalSolarCalculator.calculate(time: now);

    final devices = _ref.read(deviceListProvider);
    final eligibleLights = devices
        .where((d) => d.type == 'light' && d.circadianModeEnabled)
        .toList();

    state = state.copyWith(
      state: newCircadianState,
      lastEvaluatedAt: now,
      affectedLightCount: eligibleLights.length,
    );

    if (dispatchToLights && state.isAutoSyncEnabled) {
      await _ref
          .read(deviceListProvider.notifier)
          .batchApplyCircadianKelvin(newCircadianState.targetKelvin);
    }
  }

  void toggleAutoSync() {
    final newEnabled = !state.isAutoSyncEnabled;
    state = state.copyWith(isAutoSyncEnabled: newEnabled);
    if (newEnabled) {
      evaluateNow();
    }
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }
}
