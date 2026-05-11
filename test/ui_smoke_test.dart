import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reset/main.dart';
import 'package:reset/models/activity_type.dart';
import 'package:reset/models/break_log.dart';
import 'package:reset/models/user_settings.dart';
import 'package:reset/state/reset_app_state.dart';
import 'package:reset/widgets/countdown_ring.dart';

void main() {
  testWidgets('polished shell renders home stats and settings', (tester) async {
    final now = DateTime(2026, 5, 10, 12);
    final state = ResetAppState.test(
      now: () => now,
      settings: const UserSettings(notificationsEnabled: false),
      logs: [
        BreakLog(
          id: '1',
          timestamp: now,
          activityType: ActivityType.walk,
          durationSeconds: 300,
          completed: true,
        ),
      ],
    );

    await tester.pumpWidget(ResetApp(appState: state));

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CountdownRing &&
            widget.semanticsLabel == 'Break countdown timer',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('reset-bottom-navigation')),
      findsOneWidget,
    );
    expect(find.text('Reset'), findsOneWidget);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Activity Breakdown'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Reminder Interval'), findsOneWidget);
  });

  testWidgets('polished break flow opens without changing behavior', (
    tester,
  ) async {
    final state = ResetAppState.test(
      now: () => DateTime(2026, 5, 10, 12),
      settings: const UserSettings(notificationsEnabled: false),
    );

    await tester.pumpWidget(ResetApp(appState: state));
    await tester.tap(find.byKey(const ValueKey('home-primary-action')));
    await tester.pumpAndSettle();

    expect(find.text('Break Time'), findsOneWidget);
    expect(find.byKey(const ValueKey('break-countdown-ring')), findsOneWidget);
    expect(find.byKey(const ValueKey('break-primary-action')), findsOneWidget);
    expect(state.totalBreaks, 0);
  });
}
