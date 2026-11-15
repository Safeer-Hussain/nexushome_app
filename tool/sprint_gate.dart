// ignore_for_file: avoid_print
import 'dart:io';

Future<void> main(List<String> args) async {
  print('====================================================================');
  print('NEXUSHOME SPRINT GATEKEEPER');
  print('Quality Verification & Autonomous Release Protocol');
  print(
    '====================================================================\n',
  );

  final isWindows = Platform.isWindows;
  final shell = isWindows ? 'cmd.exe' : 'bash';
  final flag = isWindows ? '/c' : '-c';

  // Phase 1: Dependency Verification
  await _runPhase('Phase 1: Dependency Verification (flutter pub get)', shell, [
    flag,
    'flutter pub get',
  ]);

  // Phase 2: Code Formatting
  await _runPhase(
    'Phase 2: Code Hygiene & Formatting (dart format lib test tool)',
    shell,
    [flag, 'dart format lib test tool'],
  );

  // Phase 3: Static Analysis
  await _runPhase(
    'Phase 3: Static Analysis Gate (flutter analyze --no-fatal-infos --no-pub)',
    shell,
    [flag, 'flutter analyze --no-fatal-infos --no-pub'],
  );

  // Phase 4: Automated Test Suite
  await _runPhase(
    'Phase 4: Automated Test Execution (flutter test --no-pub)',
    shell,
    [flag, 'flutter test --no-pub'],
  );

  // Phase 5: Connected Physical Device Logcat Audit (Optional)
  print('Phase 5: Checking for connected Android devices via ADB...');
  try {
    final adbDevicesResult = await Process.run('adb', ['devices']);
    final output = adbDevicesResult.stdout.toString();
    final lines = output
        .split('\n')
        .where((l) => l.trim().isNotEmpty && !l.startsWith('List'))
        .toList();

    if (lines.isNotEmpty) {
      print(
        'Connected device detected. Auditing adb logcat for RenderFlex & Hero tag crashes...',
      );
      final logcatResult = await Process.run('adb', ['logcat', '-d']);
      final logs = logcatResult.stdout.toString();

      if (logs.contains('RenderFlex overflowed') ||
          logs.contains('There are multiple heroes that share the same tag')) {
        print(
          'CRITICAL RUNTIME ERROR detected in device logcat: RenderFlex overflow or duplicate Hero tag found!',
        );
        exit(1);
      } else {
        print('Device logcat audit PASSED (0 fatal rendering exceptions).');
      }
    } else {
      print(
        'No physical Android device connected via ADB. Skipping logcat audit.',
      );
    }
  } catch (_) {
    print(
      'ADB not available in system environment. Skipping device runtime check.',
    );
  }

  print(
    '\n====================================================================',
  );
  print('ALL SPRINT GATES PASSED - READY FOR PRODUCTION COMMIT');
  print('====================================================================');
}

Future<void> _runPhase(
  String title,
  String executable,
  List<String> arguments,
) async {
  print('--> $title');
  final result = await Process.run(executable, arguments, runInShell: true);

  if (result.stdout.toString().trim().isNotEmpty) {
    print(result.stdout.toString().trim());
  }

  if (result.exitCode != 0) {
    if (result.stderr.toString().trim().isNotEmpty) {
      print('ERROR: ${result.stderr.toString().trim()}');
    }
    print('\nFAILED at $title (Exit Code ${result.exitCode})');
    exit(result.exitCode);
  }
  print('PASSED: $title\n');
}
