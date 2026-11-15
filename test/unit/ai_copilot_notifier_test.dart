import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_home_app/core/di/injection.dart';
import 'package:nexus_home_app/data/repositories/automation_repository.dart';
import 'package:nexus_home_app/data/repositories/device_repository.dart';
import 'package:nexus_home_app/data/repositories/mesh_repository.dart';
import 'package:nexus_home_app/presentation/providers/ai_copilot_provider.dart';

import '../helpers/mock_repositories.dart';

void main() {
  group('AiHomeCopilotNotifier Unit Tests', () {
    late ProviderContainer container;
    late AiCopilotNotifier notifier;

    setUp(() {
      getIt.reset();
      getIt.registerSingleton<DeviceRepository>(FakeDeviceRepository());
      getIt.registerSingleton<MeshRepository>(FakeMeshRepository());
      getIt.registerSingleton<AutomationRepository>(FakeAutomationRepository());

      container = ProviderContainer();
      notifier = container.read(aiCopilotProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('Initializes with default welcome assistant message', () {
      expect(notifier.state.messages.length, equals(1));
      expect(notifier.state.messages.first.isUser, isFalse);
      expect(notifier.state.isStreaming, isFalse);
      expect(notifier.state.statusIndicator, isNull);
    });

    test('sendUserPrompt streams response and strictly resets isStreaming to false in finally', () async {
      const prompt = 'Audit Vampire Standby Power Draw';
      final future = notifier.sendUserPrompt(prompt);

      // Verify streaming has started
      expect(notifier.state.isStreaming, isTrue);
      expect(
        notifier.state.messages.any((m) => m.text == prompt && m.isUser),
        isTrue,
      );

      await future;

      // Verify STRICT GUARANTEE: isStreaming resets to false and statusIndicator is null
      expect(notifier.state.isStreaming, isFalse);
      expect(notifier.state.statusIndicator, isNull);
      expect(notifier.state.messages.length, greaterThanOrEqualTo(3));
      expect(
        notifier.state.messages.last.text,
        contains('Vampire Standby Audit'),
      );
    });

    test('Handles prompt for HVAC Peak Tariffs correctly', () async {
      await notifier.sendUserPrompt('Optimize HVAC Schedule for Peak Tariffs');

      expect(notifier.state.isStreaming, isFalse);
      expect(
        notifier.state.messages.last.text,
        contains('Peak Tariff Optimization'),
      );
    });

    test('clearConversation resets back to single welcome message', () async {
      await notifier.sendUserPrompt(
        'Suggest New Energy-Saving Automation Rule',
      );
      expect(notifier.state.messages.length, greaterThan(1));

      notifier.clearConversation();
      expect(notifier.state.messages.length, equals(1));
      expect(notifier.state.isStreaming, isFalse);
    });
  });
}
