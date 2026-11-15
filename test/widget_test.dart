import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_home_app/core/di/injection.dart';
import 'package:nexus_home_app/main.dart';
import 'package:nexus_home_app/presentation/splash/splash_view.dart';

void main() {
  setUp(() {
    getIt.reset();
    setupDependencyInjection();
  });

  testWidgets('NexusHomeApp startup smoke test mounts SplashView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: NexusHomeApp()));

    expect(find.byType(SplashView), findsOneWidget);
    expect(find.text('NEXUSHOME'), findsOneWidget);
    expect(find.text('Matter & Thread Mesh IoT Sanctuary'), findsOneWidget);
  });
}
