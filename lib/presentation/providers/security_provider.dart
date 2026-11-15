import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection.dart';
import '../../data/models/security_event_model.dart';
import '../../data/repositories/security_repository.dart';
import '../../domain/entities/security_event_entity.dart';

final securityModeProvider = StateProvider<String>((ref) => 'Armed Home');

final securityEventsProvider =
    StateNotifierProvider<SecurityEventsNotifier, List<SecurityEventEntity>>((
      ref,
    ) {
      final repo = getIt<SecurityRepository>();
      return SecurityEventsNotifier(repo);
    });

class SecurityEventsNotifier extends StateNotifier<List<SecurityEventEntity>> {
  final SecurityRepository _repository;

  SecurityEventsNotifier(this._repository) : super([]) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    final events = await _repository.getSecurityEvents();
    state = events;
  }

  Future<void> triggerAlert({
    required String title,
    required String deviceName,
    required String room,
    required String severity,
  }) async {
    final event = SecurityEventModel(
      id: 'sec_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      deviceId: 'dev_sensor_trigger',
      deviceName: deviceName,
      room: room,
      severity: severity,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await _repository.addSecurityEvent(event);
    state = [event, ...state];
  }
}
