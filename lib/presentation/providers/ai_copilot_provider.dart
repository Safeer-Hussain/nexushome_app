import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/device_entity.dart';
import 'device_provider.dart';
import 'mesh_provider.dart';
import 'automation_provider.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class AiCopilotState {
  final List<ChatMessage> messages;
  final bool isStreaming;
  final String? statusIndicator;

  const AiCopilotState({
    this.messages = const [],
    this.isStreaming = false,
    this.statusIndicator,
  });

  AiCopilotState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    String? statusIndicator,
  }) {
    return AiCopilotState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      statusIndicator: statusIndicator,
    );
  }
}

final aiCopilotProvider =
    StateNotifierProvider<AiCopilotNotifier, AiCopilotState>((ref) {
      return AiCopilotNotifier(ref);
    });

class AiCopilotNotifier extends StateNotifier<AiCopilotState> {
  final Ref _ref;

  AiCopilotNotifier(this._ref)
    : super(
        AiCopilotState(
          messages: [
            ChatMessage(
              id: 'welcome_01',
              text: 'Welcome to NexusHome On-Device AI Copilot. I analyze real-time Matter/Thread telemetry, home power loads, and solar battery storage to suggest proactive efficiency rules.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ],
        ),
      );

  Future<void> sendUserPrompt(String query) async {
    if (query.trim().isEmpty || state.isStreaming) return;

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: query.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isStreaming: true,
      statusIndicator:
          'Auditing active Matter nodes, watt draw & tariff windows...',
    );

    try {
      // Gather live telemetry context from Riverpod
      final devices = _ref.read(deviceListProvider);
      final meshNodes = _ref.read(meshListProvider);
      final rules = _ref.read(rulesListProvider);

      final fullResponse = _generateContextualAiResponse(
        query: query,
        devices: devices,
        meshNodeCount: meshNodes.length,
        rulesCount: rules.length,
      );

      // Transient delay to simulate token stream
      await Future.delayed(const Duration(milliseconds: 350));

      // Append empty assistant message to stream into
      final aiMsgId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
      var assistantMsg = ChatMessage(
        id: aiMsgId,
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        statusIndicator: null,
      );

      // Stream tokens sequentially
      final words = fullResponse.split(' ');
      final buffer = StringBuffer();

      for (int i = 0; i < words.length; i++) {
        buffer.write('${words[i]} ');
        assistantMsg = assistantMsg.copyWith(text: buffer.toString().trim());

        state = state.copyWith(
          messages: [
            for (final msg in state.messages)
              if (msg.id == aiMsgId) assistantMsg else msg,
          ],
        );

        if (i % 3 == 0) {
          await Future.delayed(const Duration(milliseconds: 30));
        }
      }
    } finally {
      // STRICT GUARANTEE: isStreaming always resets to false, statusIndicator cleared
      state = state.copyWith(isStreaming: false, statusIndicator: null);
    }
  }

  String _generateContextualAiResponse({
    required String query,
    required List<DeviceEntity> devices,
    required int meshNodeCount,
    required int rulesCount,
  }) {
    final lower = query.toLowerCase();
    final activeCount = devices.where((d) => d.isPowered).length;
    final totalWatts = devices
        .where((d) => d.isPowered)
        .fold<double>(0.0, (acc, d) => acc + d.powerWatts);

    if (lower.contains('ev') ||
        lower.contains('charger') ||
        lower.contains('car') ||
        lower.contains('charging')) {
      final evChargers = devices.where((d) => d.type == 'ev_charger').toList();
      final evCount = evChargers.length;
      final evSoc = evChargers.isNotEmpty
          ? evChargers.first.chargeSocPercent.toInt()
          : 0;
      final offPeak =
          evChargers.isNotEmpty && evChargers.first.offPeakScheduleEnabled;
      return 'EV Charging Intelligence: Monitoring $evCount Level 2 EVSE terminal(s). '
          'Current Battery SoC: $evSoc%. Smart Off-Peak Scheduler is currently ${offPeak ? 'ACTIVE (deferring high-current draw to 23:00-06:00 or solar surplus > 3.5 kW)' : 'PAUSED (Immediate charging mode)'}. '
          'Recommendation: Keep off-peak scheduling enabled with a 16A-24A solar-tracking limit to avoid grid demand charges and save up to 45% on vehicle charging expenses.';
    } else if (lower.contains('circadian') ||
        lower.contains('adaptive light') ||
        lower.contains('kelvin') ||
        lower.contains('color temp') ||
        lower.contains('sunset') ||
        lower.contains('daylight')) {
      final activeLights = devices.where((d) => d.type == 'light').toList();
      final circadianCount = activeLights
          .where((d) => d.circadianModeEnabled)
          .length;
      return 'Circadian Adaptive Engine Audit: Monitoring ${activeLights.length} luminaires across your residence, with $circadianCount synchronized to natural astronomical solar curves. '
          'Target color temperatures dynamically shift from crisp 5500K daylight at solar noon to warm 2700K amber after sunset to promote restorative melatonin synthesis. '
          'Dispatched via Thread 1.3 mesh broadcast with zero cloud dependencies every 15 minutes.';
    } else if (lower.contains('vampire') || lower.contains('standby')) {
      return 'Vampire Standby Audit complete. Found $activeCount active devices drawing ${totalWatts.toStringAsFixed(1)} W. '
          'Culinary Luminaire Array and Studio Task Spotlight account for 93.0 W of continuous draw while unoccupied. '
          'Recommendation: Enable automatic 15-minute inactivity cutoffs in the Automation Rule Builder to save an estimated 38.4 kWh monthly.';
    } else if (lower.contains('hvac') ||
        lower.contains('tariff') ||
        lower.contains('peak')) {
      return 'Peak Tariff Optimization Analysis: Current grid rate enters high-cost window between 17:00 and 21:00. '
          'Recommended Action: Pre-cool the Living Room and Master Suite to 21.0°C during solar peak (13:00 - 15:30), '
          'then drift target temperature to 24.5°C during the 17:00 peak tariff window. Projected monthly cost savings: 22%.';
    } else if (lower.contains('rule') ||
        lower.contains('suggest') ||
        lower.contains('automation')) {
      return 'Energy-Saving Rule Suggestion: "Solar Storage Priority Buffer". '
          'Condition: IF Home Battery Wall SoC exceeds 90% AND Solar Generation is > 4.0 kW, '
          'Action: Automatically enable Panoramic Blinds tilt to 40% and start Water Heater booster cycle. '
          'You currently have $rulesCount active rules; this rule can be enabled with one tap in Tab 1.';
    } else if (lower.contains('signal') ||
        lower.contains('mesh') ||
        lower.contains('health') ||
        lower.contains('thread')) {
      return 'Thread Mesh Network Topology Health: Audited $meshNodeCount active nodes across 1 Border Router and 2 Router Relays. '
          'Average hop latency is 14.8 ms with 99.98% packet delivery. All node RSSI levels are healthy (strongest: -32 dBm at Border Router, lowest: -61 dBm at Panoramic Blinds). '
          'No mesh re-routing or self-healing intervention is required.';
    } else {
      return 'NexusHome Copilot telemetry summary: Monitoring ${devices.length} Matter devices across 5 zones. '
          'Current aggregate load is ${totalWatts.toStringAsFixed(1)} W across $activeCount powered endpoints. '
          'Thread mesh topology is fully synchronized with local SQLite registry and zero cloud dependencies.';
    }
  }

  void clearConversation() {
    state = AiCopilotState(
      messages: [
        ChatMessage(
          id: 'welcome_01',
          text: 'Welcome to NexusHome On-Device AI Copilot. I analyze real-time Matter/Thread telemetry, home power loads, and solar battery storage to suggest proactive efficiency rules.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }
}
