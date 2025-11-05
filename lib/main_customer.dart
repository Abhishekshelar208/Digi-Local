import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:digilocal/customer_app/navigation/customer_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const DigiLocalCustomerApp());
}

class DigiLocalCustomerApp extends StatelessWidget {
  const DigiLocalCustomerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DigiLocal - Shop Local, Save More',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF4ECDC4),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Color(0xFFF8F9FA),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      debugShowCheckedModeBanner: false,
      home: CustomerMainScreen(),
    );
  }
}
