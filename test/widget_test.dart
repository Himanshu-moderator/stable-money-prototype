import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stable_money_clone/main.dart';
import 'package:stable_money_clone/screens/shell/main_shell.dart';
import 'package:stable_money_clone/state/app_state.dart';
import 'package:stable_money_clone/theme/app_theme.dart';

/// The Browser preview in this environment can't render Flutter's
/// CanvasKit/skwasm output (no network path to fetch/verify the WASM
/// runtime), so visual screenshots aren't available here. These widget
/// tests pump the real widget tree instead — they exercise actual
/// navigation, state, and layout logic without needing pixels, which is
/// the stronger correctness signal for a Flutter app anyway.
void main() {
  testWidgets('Onboarding: mobile number screen renders correctly',
      (tester) async {
    await tester.pumpWidget(StableMoneyCloneApp(appState: AppState()));

    expect(find.text("What's your mobile number?"), findsOneWidget);
    expect(find.text('+91'), findsOneWidget);

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Verify mobile number'),
    );
    expect(button.onPressed, isNull, reason: 'disabled until 10 digits entered');
  });

  testWidgets('Onboarding: full flow reaches the FD tab', (tester) async {
    final appState = AppState();
    await tester.pumpWidget(StableMoneyCloneApp(appState: appState));

    // Mobile number
    await tester.enterText(find.byType(TextField), '7007090053');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Verify mobile number'));
    await tester.pumpAndSettle();

    expect(find.text('OTP please?'), findsOneWidget);
    expect(appState.pendingMobile, '7007090053');

    // OTP (auto-submits on 6th digit)
    final otpFields = find.byType(TextField);
    for (var i = 0; i < 6; i++) {
      await tester.enterText(otpFields.at(i), '${i + 1}');
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Verify your identity'), findsOneWidget);
    expect(appState.profile.mobile, '7007090053');

    // PAN/KYC
    await tester.enterText(find.byType(TextField), 'ABCDE1234F');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Profile details'), findsOneWidget);

    // Profile setup — minimum required fields. The form is a long
    // ListView, so scroll each target into view before interacting.
    await tester.enterText(
      find.widgetWithText(TextField, 'Enter your full name'),
      'Himanshu Chaudhary',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'you@email.com'),
      'himanshu@example.com',
    );
    await _scrollToAndTap(tester, find.text('Male'));
    await _scrollToAndTap(
      tester,
      find.widgetWithText(ElevatedButton, 'Complete profile'),
    );
    await tester.pumpAndSettle();

    // Lands on MainShell -> FD tab
    expect(find.text('stable money'), findsOneWidget);
    expect(find.textContaining('Choose your FD'), findsOneWidget);
    expect(appState.profile.fullName, 'Himanshu Chaudhary');
    expect(appState.profile.pan, 'ABCDE1234F');
  });

  testWidgets('FD tab shows the bank list and quick filters', (tester) async {
    final appState = AppState();
    await tester.pumpWidget(_mainShellHarness(appState));
    await tester.pumpAndSettle();

    expect(find.text("What's on your mind?"), findsOneWidget);
    expect(find.text('Gold & Silver'), findsOneWidget);

    await _scrollToVisible(tester, find.text('Most booked banks and NBFCs'));
    expect(find.text('Most booked banks and NBFCs'), findsOneWidget);
    expect(find.text('Suryoday SF Bank'), findsWidgets);
    expect(find.text('View all FDs'), findsWidgets);
  });

  testWidgets('Bonds tab shows bond cards and the rate table', (tester) async {
    final appState = AppState();
    await tester.pumpWidget(_mainShellHarness(appState));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav-bonds')));
    await tester.pumpAndSettle();

    await _scrollToVisible(tester, find.text('Popular Bonds for you'));
    expect(find.text('Popular Bonds for you'), findsOneWidget);

    await _scrollToVisible(tester, find.text('Bond rates at a glance'));
    expect(find.text('Bond rates at a glance'), findsOneWidget);

    await _scrollToVisible(tester, find.text('Questions and Answers'));
    expect(find.text('Questions and Answers'), findsOneWidget);
  });

  testWidgets('FD Card tab shows the benefits comparison table',
      (tester) async {
    final appState = AppState();
    await tester.pumpWidget(_mainShellHarness(appState));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav-fd-card')));
    await tester.pumpAndSettle();

    expect(find.text('LIFETIME FREE'), findsOneWidget);

    await _scrollToVisible(tester, find.text('Compare benefits'));
    expect(find.text('Compare benefits'), findsOneWidget);
    expect(find.text('Lounge Access'), findsOneWidget);
  });

  testWidgets('Passbook starts empty and updates after a booking',
      (tester) async {
    final appState = AppState();
    await tester.pumpWidget(_mainShellHarness(appState));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav-passbook')));
    await tester.pumpAndSettle();

    expect(find.text('₹0'), findsWidgets);
    expect(find.text('You have not invested yet'), findsOneWidget);

    // Book an FD end-to-end and confirm it lands in the passbook.
    await tester.tap(find.byKey(const ValueKey('nav-fd')));
    await tester.pumpAndSettle();

    await _scrollToVisible(tester, find.text('Suryoday SF Bank'));
    await tester.tap(find.text('Suryoday SF Bank').first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Book now'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Test Nominee');
    await _scrollToAndTap(tester, find.text('Spouse'));
    await _scrollToAndTap(
      tester,
      find.widgetWithText(ElevatedButton, 'Continue to payment'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Pay ₹'));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('FD booked!'), findsOneWidget);
    expect(appState.portfolio.length, 1);
    expect(appState.netWorth, 100000);

    await tester.tap(find.text('View in Passbook'));
    await tester.pumpAndSettle();

    // Lands back on Passbook > Overview, now reflecting the booking.
    expect(find.text('You have not invested yet'), findsNothing);
    expect(find.textContaining('1,00,000'), findsWidgets);
  });
}

Widget _mainShellHarness(AppState appState) {
  appState.updateProfile(fullName: 'Test User', email: 'test@example.com');
  return MaterialApp(
    theme: AppTheme.light,
    home: MainShell(appState: appState),
  );
}

/// Scrolls the nearest [Scrollable] until [finder] is inflated, without
/// tapping it — for assertions on far-down content in a long ListView.
Future<void> _scrollToVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 30,
  );
  await tester.pumpAndSettle();
}

/// Scrolls [finder] into view, then taps it.
Future<void> _scrollToAndTap(WidgetTester tester, Finder finder) async {
  await _scrollToVisible(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
