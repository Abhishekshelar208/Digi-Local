import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:digilocal/shop_owner_app/navigation/owner_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const DigiLocalShopOwnerApp());
}

class DigiLocalShopOwnerApp extends StatelessWidget {
  const DigiLocalShopOwnerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DigiLocal - Grow Your Business',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Color(0xFFF8F9FA),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      debugShowCheckedModeBanner: false,
      home: OwnerMainScreen(),
    );
  }
}
