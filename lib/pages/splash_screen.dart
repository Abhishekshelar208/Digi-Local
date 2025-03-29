import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digilocal/pages/splash_services.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashServicesForStudent _splashServices = SplashServicesForStudent();

  @override
  void initState() {
    super.initState();
    _splashServices.checkLoginStatus(context);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
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
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //SizedBox(height: screenHeight * 0.20),
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
              // SizedBox(height: screenHeight * 0.04),
              // Text(
              //   "Welcome to SkillHub",
              //   style: GoogleFonts.blinker(
              //     color: Colors.deepOrangeAccent, // Set color to white to ensure the gradient is visible
              //     fontSize: screenWidth * 0.1,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
              // Text(
              //   "Code. Collaborate. Conquer. 🚀",
              //   style: GoogleFonts.blinker(
              //     color: Colors.black, // Set color to white to ensure the gradient is visible
              //     fontSize: screenWidth * 0.055,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ), // Responsive spacing
            ],
          ),
        ),
      ),
    );
  }
}
