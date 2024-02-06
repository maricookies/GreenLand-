import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Define specific interfaces
abstract class HomeNavigation {
  void navigateToProductPage(BuildContext context);
  void navigateToAddProductPage(BuildContext context);
  void navigateToProfilePage(BuildContext context);
}

// Implement specific interfaces
class ProductPageNavigation implements HomeNavigation {
  @override
  void navigateToProductPage(BuildContext context) {
    Navigator.pushNamed(context, '/product');
  }

  @override
  void navigateToAddProductPage(BuildContext context) {
  }

  @override
  void navigateToProfilePage(BuildContext context) {
  }
}

class AddProductPageNavigation implements HomeNavigation {
  @override
  void navigateToProductPage(BuildContext context) {
  }

  @override
  void navigateToAddProductPage(BuildContext context) {
    Navigator.pushNamed(context, '/addproduct');
  }

  @override
  void navigateToProfilePage(BuildContext context) {
  }
}

class ProfilePageNavigation implements HomeNavigation {
  @override
  void navigateToProductPage(BuildContext context) {
  }

  @override
  void navigateToAddProductPage(BuildContext context) {
  }

  @override
  void navigateToProfilePage(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _updateSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: HomeBody(updateSelectedIndex: _updateSelectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: 'Add Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF006032),
        unselectedItemColor: Color.fromARGB(255, 138, 175, 145),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Navigate based on selected index
          switch (index) {
            case 0:
              break;
            case 1:
              ProductPageNavigation().navigateToProductPage(context);
              break;
            case 2:
              AddProductPageNavigation().navigateToAddProductPage(context);
              break;
            case 3:
              ProfilePageNavigation().navigateToProfilePage(context);
              break;
          }
        },
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  final Function(int) updateSelectedIndex;

  const HomeBody({Key? key, required this.updateSelectedIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get current user from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;
    String welcomeText =
        user != null ? 'Welcome ${user.displayName}' : 'Welcome Admin';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Container(
            width: 150, // Adjust width as needed
            height: 150, // Adjust height as needed
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFF006032),
                width: 2, // Adjust border width as needed
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'images/logo.png', // Adjust the path to your logo image
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: Text(
            welcomeText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF006032),
            ),
          ),
        ),
        SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            ProductPageNavigation().navigateToProductPage(context);
          },
          child: HomeCard(
            icon: Icons.shopping_cart,
            label: 'Manage products',
          ),
        ),
        SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            AddProductPageNavigation().navigateToAddProductPage(context);
          },
          child: HomeCard(
            icon: Icons.add_shopping_cart,
            label: 'Add new product',
          ),
        ),
        SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            ProfilePageNavigation().navigateToProfilePage(context);
          },
          child: HomeCard(
            icon: Icons.people,
            label: 'Your profile (account)',
          ),
        ),
      ],
    );
  }
}

class HomeCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const HomeCard({Key? key, required this.icon, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Color(0xFF006032)),
            SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
