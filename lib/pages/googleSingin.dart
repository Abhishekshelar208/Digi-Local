// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/foundation.dart'; // For kIsWeb
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:skillhub/pages/createShops.dart';
// import 'package:skillhub/pages/home_pageforStudent.dart';
//
// class googleSignIn extends StatefulWidget {
//   googleSignIn({Key? key}) : super(key: key);
//
//   @override
//   State<googleSignIn> createState() => _googleSignInState();
// }
//
// class _googleSignInState extends State<googleSignIn> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   bool isLoading = false;
//
//   void _handleGoogleSignIn(BuildContext context) async {
//     try {
//       GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
//       if (kIsWeb) {
//         // For web, use signInWithPopup
//         await FirebaseAuth.instance
//             .signInWithPopup(googleAuthProvider)
//             .then((userCredential) {
//           if (userCredential.user != null) {
//             //Navigate to the next page after successful sign-in
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => CreateStudentID(),
//               ),
//             );
//           }
//         });
//       } else {
//         // For mobile, use signInWithProvider
//         await FirebaseAuth.instance
//             .signInWithProvider(googleAuthProvider)
//             .then((userCredential) {
//           if (userCredential.user != null) {
//             // Navigate to the next page after successful sign-in
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => CreateStudentID(),
//               ),
//             );
//           }
//         });
//       }
//     } catch (error) {
//       print("Error: $error");
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Error: $error")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: Container(
//         height: screenHeight,
//         width: screenWidth,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topRight,
//             end: Alignment.bottomLeft,
//             colors: [
//               Color(0xFF0a5d94),
//               Color(0xFF000000),
//
//             ],
//           ),
//         ),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.symmetric(
//               vertical: screenHeight * 0.05,
//               horizontal: screenWidth * 0.04,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(height: screenHeight * 0.20),
//                 Center(
//                   child: Container(
//                     height: 180,
//                     width: 180,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(55),
//                       border: Border.all(
//                         color: Colors.grey,
//                         width: 2.0,
//                       ),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(55),
//                       child: Image.asset(
//                         'lib/assets/images/logo3.png',
//                         height: 110,
//                         width: 110,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.04),
//                 Text(
//                   "Welcome to SkillHub",
//                   style: GoogleFonts.blinker(
//                     color: Colors.white, // Set color to white to ensure the gradient is visible
//                     fontSize: screenWidth * 0.1,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   "Code. Collaborate. Conquer. 🚀",
//                   style: GoogleFonts.blinker(
//                     color: Colors.white60, // Set color to white to ensure the gradient is visible
//                     fontSize: screenWidth * 0.055,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.1),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Find Your Perfect Coding Partner\n    Collaborate, Code, and Grow!",
//                       style: GoogleFonts.blinker(
//                         color: Colors.white60, // Set color to white to ensure the gradient is visible
//                         fontSize: screenWidth * 0.045,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: screenHeight * 0.035),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       _handleGoogleSignIn(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF3cb1eb), // Background color changed to red
//                       foregroundColor: Colors.white, // Text color white for contrast
//                       padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Increased size
//                       minimumSize: Size(200, 0), // Explicitly setting width and height
//                     ),
//                     child: Text(
//                       "Get Started",
//                       style: GoogleFonts.blinker(
//                         color: Colors.white, // Set color to white to ensure the gradient is visible
//                         fontSize: screenWidth * 0.055,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digilocal/pages/createShops.dart';
import 'package:digilocal/pages/home_pageforStudent.dart';

class googleSignIn extends StatefulWidget {
  googleSignIn({Key? key}) : super(key: key);

  @override
  State<googleSignIn> createState() => _googleSignInState();
}

class _googleSignInState extends State<googleSignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  void _handleGoogleSignIn(BuildContext context) async {
    try {
      GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
      if (kIsWeb) {
        // For web, use signInWithPopup
        await FirebaseAuth.instance
            .signInWithPopup(googleAuthProvider)
            .then((userCredential) {
          if (userCredential.user != null) {
            //Navigate to the next page after successful sign-in
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CreateUserID(),
              ),
            );
          }
        });
      } else {
        // For mobile, use signInWithProvider
        await FirebaseAuth.instance
            .signInWithProvider(googleAuthProvider)
            .then((userCredential) {
          if (userCredential.user != null) {
            // Navigate to the next page after successful sign-in
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CreateUserID(),
              ),
            );
          }
        });
      }
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xffF2F0EF), //off white
              Color(0xffF2F0EF), //off white
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.05,
              horizontal: screenWidth * 0.04,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.20),
                Center(
                  child: Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.grey,
                        width: 2.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        'lib/assets/images/digiLocalLogo.jpg',
                        height: 110,
                        width: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                FittedBox(
                  child: Text(
                    "Welcome to DigiLocal",
                    style: GoogleFonts.blinker(
                      color: Colors.deepOrangeAccent, // Set color to white to ensure the gradient is visible
                      fontSize: screenWidth * 0.1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                FittedBox(
                  child: Text(
                    "Go Digital. Get Customers. Grow Fast. 🚀",
                    style: GoogleFonts.blinker(
                      color: Colors.black, // Set color to white to ensure the gradient is visible
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.150),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Take Your Business Online Instantly\n Create, Share, and Grow Faster 🚀",
                      style: GoogleFonts.blinker(
                        color: Colors.grey[700], // Set color to white to ensure the gradient is visible
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.035),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _handleGoogleSignIn(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent, // Background color changed to red
                      foregroundColor: Colors.white, // Text color white for contrast
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10), // Increased size
                      minimumSize: Size(200, 0), // Explicitly setting width and height
                    ),
                    child: Text(
                      "Get Started",
                      style: GoogleFonts.blinker(
                        color: Colors.white, // Set color to white to ensure the gradient is visible
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
