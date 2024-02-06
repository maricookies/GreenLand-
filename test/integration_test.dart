import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:greenland_organicfarm/features/app/splash_screen/splash_screen.dart';
import 'package:greenland_organicfarm/features/user_auth/presentation/pages/add_product.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Integration Test: SplashScreen and Calculate Selling Price', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SplashScreen(
        child: Container(), 
      ),
      navigatorObservers: [MockNavigatorObserver()],
    ));
    
    // Wait for the SplashScreen to fully render and the animation to complete
    await tester.pumpAndSettle();

    // Verify that the 'Welcome to GreenLand Organic Farm' text is displayed
    expect(find.text('Welcome to GreenLand Organic Farm'), findsOneWidget);

    // Ensure that the SplashScreen navigates to the child widget after animation completes
    expect(find.byType(Container), findsNothing);

    // Initialize the calculator
    CalculateSellingPrice unitTest = CalculateSellingPrice();
    
    // Calculate the selling price with a buying price of 100
    unitTest.calculateSellingPrice(100);
    
    // Verify that the calculated selling price is 140 (40% profit margin)
    expect(unitTest.getSellingPrice(), equals(140));
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
