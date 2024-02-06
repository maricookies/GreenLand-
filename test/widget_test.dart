import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenland_organicfarm/features/app/splash_screen/splash_screen.dart';

void main() {
  testWidgets('SplashScreen UI Test', (WidgetTester tester) async {
    // Build the SplashScreen widget
    await tester.pumpWidget(MaterialApp(
      home: SplashScreen(
        child: Container(), // Provide a child widget for testing
      ),
      navigatorObservers: [MockNavigatorObserver()],
    ));

    // Wait for the SplashScreen to fully render and the animation to complete
    await tester.pumpAndSettle();

    // Verify that the 'Welcome to GreenLand Organic Farm' text is displayed
    expect(find.text('Welcome to GreenLand Organic Farm'), findsOneWidget);

    // Ensure that the SplashScreen navigates to the child widget after animation completes
    expect(find.byType(Container), findsNothing);
  });
}

class MockNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Ensure that the SplashScreen navigates to the child widget after animation completes
    expect(find.byType(Container), findsOneWidget);
  }
}
