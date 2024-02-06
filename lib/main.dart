import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:greenland_organicfarm/features/app/splash_screen/splash_screen.dart';
import 'package:greenland_organicfarm/features/user_auth/presentation/pages/add_product.dart';
import 'package:greenland_organicfarm/features/user_auth/presentation/pages/home_page.dart';
import 'package:greenland_organicfarm/features/user_auth/presentation/pages/login_page.dart';
import 'package:greenland_organicfarm/features/user_auth/presentation/pages/product.dart';
import 'package:greenland_organicfarm/features/user_auth/presentation/pages/profile.dart';
import 'package:greenland_organicfarm/features/user_auth/presentation/pages/sign_up_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCE0Li6cw1i--g3zzgJFhdAqP9QJGfmjLQ",
      appId: "1:963081925713:web:0ae38ef0c4adbd7156f470",
      messagingSenderId: "963081925713",
      projectId: "flutterfire-greenland",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      routes: {
        '/': (context) => SplashScreen(
          child: LoginPage(),
        ),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/product': (context) => ProductPage(),
        '/addproduct': (context) => AddProductPage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
