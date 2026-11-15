import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_home_app/core/theme/app_theme.dart';
import 'package:nexus_home_app/data/repositories/energy_repository.dart';
import 'package:nexus_home_app/presentation/energy/widgets/energy_chart.dart';

void main() {
  testWidgets(
    'EnergyChart renders full-width 24-hour dual-line chart cleanly',
    (tester) async {
      final sampleProfile = List.generate(
        24,
        (h) => EnergyHourlyDataPoint(
          hour: h,
          solarKwh: (h >= 6 && h <= 18) ? 3.5 : 0.0,
          loadKwh: 2.1,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnergyChart(profile: sampleProfile),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsOneWidget);
      expect(find.text('24-Hour Diurnal Energy Profile'), findsOneWidget);
      expect(find.text('Solar kW'), findsOneWidget);
      expect(find.text('Load kW'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
