import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/shared/widgets/app_loading_indicator.dart';

void main() {
  group('AppLoadingIndicator', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: AppLoadingIndicator()),
          ),
        ),
      );

      expect(find.byType(AppLoadingIndicator), findsOneWidget);
    });

    testWidgets('contains exactly three dot containers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: AppLoadingIndicator()),
          ),
        ),
      );

      // The widget is a Row with three child containers (one per dot)
      final row = tester.widget<Row>(find.descendant(
        of: find.byType(AppLoadingIndicator),
        matching: find.byType(Row),
      ));

      // Filter to Container children only (excluding SizedBox spacers)
      final containers = row.children.whereType<AnimatedBuilder>().toList();
      expect(containers.length, 3);
    });

    testWidgets('accepts custom dotSize without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: AppLoadingIndicator(dotSize: 12.0)),
          ),
        ),
      );

      expect(find.byType(AppLoadingIndicator), findsOneWidget);
    });

    testWidgets('widget animates (controller ticks)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: AppLoadingIndicator()),
          ),
        ),
      );

      // Pump some frames to ensure animations run without errors
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
    });
  });
}
