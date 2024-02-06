import 'package:flutter_test/flutter_test.dart';
import 'package:greenland_organicfarm/features/user_auth/presentation/pages/add_product.dart';

void main() {
  test('Calculate Selling Price(profit margin is 40%)', () {
    // Initialize
    CalculateSellingPrice unitTest = CalculateSellingPrice();
    
    // Test
    unitTest.calculateSellingPrice(100);
    
    // Verify
    expect(unitTest.getSellingPrice(), equals(140));
  });
}
