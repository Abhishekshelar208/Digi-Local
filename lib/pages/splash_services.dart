// // lib/firebase_services/splash_services.dart
//
// import 'dart:async';
//
// import 'package:college/ui/home_screen_for_student.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:college/ui/create_student_id.dart';
// import 'package:college/ui/home_screen.dart';
// import 'package:college/ui/auth/login_screen.dart';
// import 'package:college/ui/introscreen.dart';
//
// class SplashServicesForStudent {
//   void checkLoginStatus(BuildContext context) async {
//     try {
//       await Firebase.initializeApp(); // Ensure Firebase is initialized
//
//       Timer(
//         const Duration(milliseconds: 2500),
//             () {
//           final auth = FirebaseAuth.instance;
//           final user = auth.currentUser;
//
//           if (user != null) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => HomeScreenForStdudent()),   //homescreen(): use this for admin app
//             );
//           } else {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => CreateStudentID()),      //adminloginscreen(): use this for admin app
//             );
//           }
//         },
//       );
//     } catch (e) {
//       // Handle any errors during Firebase initialization
//       print('Error initializing Firebase: $e');
//       // You can show an error message or navigate to an error screen if needed
//     }
//   }
// }




import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'googleSingin.dart';
import 'home_pageforStudent.dart';


class SplashServicesForStudent {
  /// This method checks the login status of the user and navigates accordingly.
  Future<void> checkLoginStatus(BuildContext context) async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      // Delay to show splash screen for 2.5 seconds
      await Future.delayed(const Duration(milliseconds: 2500));

      if (user != null) {
        // User is logged in, redirect to HomeScreenForStudent
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreenForStdudent()),
        );
      } else {
        // User is not logged in, redirect to CreateStudentID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => googleSignIn()),
        );
      }
    } catch (e) {
      print('Error checking login status: $e');
      // Optionally, navigate to an error screen or show an error message
    }
  }
}
