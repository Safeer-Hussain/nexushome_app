import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'presentation/splash/splash_view.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        log(
          'NexusHome FlutterError: ${details.exceptionAsString()}',
          stackTrace: details.stack,
        );
      };

      try {
        setupDependencyInjection();
      } catch (e, stack) {
        log('Error during minimal pre-runApp DI setup: $e', stackTrace: stack);
      }

      runApp(const ProviderScope(child: NexusHomeApp()));
    },
    (error, stack) {
      log('NexusHome Uncaught Zone Error: $error', stackTrace: stack);
    },
  );
}

class NexusHomeApp extends ConsumerWidget {
  const NexusHomeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return GestureDetector(
      // Global tap-outside to dismiss keyboard safely
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        title: 'NexusHome',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const SplashView(),
      ),
    );
  }
}
