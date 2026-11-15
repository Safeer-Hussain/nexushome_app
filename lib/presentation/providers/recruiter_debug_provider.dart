import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecruiterDebugState {
  final int simulatedLatencyMs;
  final bool force503CloudOutage;
  final bool peakTariffSpikeActive;
  final bool motionAlertInjected;

  const RecruiterDebugState({
    this.simulatedLatencyMs = 450,
    this.force503CloudOutage = false,
    this.peakTariffSpikeActive = false,
    this.motionAlertInjected = false,
  });

  RecruiterDebugState copyWith({
    int? simulatedLatencyMs,
    bool? force503CloudOutage,
    bool? peakTariffSpikeActive,
    bool? motionAlertInjected,
  }) {
    return RecruiterDebugState(
      simulatedLatencyMs: simulatedLatencyMs ?? this.simulatedLatencyMs,
      force503CloudOutage: force503CloudOutage ?? this.force503CloudOutage,
      peakTariffSpikeActive:
          peakTariffSpikeActive ?? this.peakTariffSpikeActive,
      motionAlertInjected: motionAlertInjected ?? this.motionAlertInjected,
    );
  }
}

final recruiterDebugProvider =
    StateNotifierProvider<RecruiterDebugNotifier, RecruiterDebugState>((ref) {
      return RecruiterDebugNotifier();
    });

class RecruiterDebugNotifier extends StateNotifier<RecruiterDebugState> {
  RecruiterDebugNotifier() : super(const RecruiterDebugState());

  void setLatency(int ms) {
    state = state.copyWith(simulatedLatencyMs: ms);
  }

  void toggle503Outage() {
    state = state.copyWith(force503CloudOutage: !state.force503CloudOutage);
  }

  void togglePeakTariff() {
    state = state.copyWith(peakTariffSpikeActive: !state.peakTariffSpikeActive);
  }

  void toggleMotionAlert() {
    state = state.copyWith(motionAlertInjected: !state.motionAlertInjected);
  }
}
