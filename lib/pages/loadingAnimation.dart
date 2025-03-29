
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatelessWidget {
  final VoidCallback? onFinish; // Make onFinish optional

  LoadingScreen({this.onFinish});

  @override
  Widget build(BuildContext context) {
    // Call onFinish after a 3-second delay if it's provided
    Future.delayed(const Duration(seconds: 3), () {
      if (onFinish != null) onFinish!();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              child: Lottie.asset(
                height: 400,
                'lib/assets/lottieAnimations/newTimer.json',

                // width: 100,

                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Website is Creating...",
            style: GoogleFonts.blinker(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          Text(
            "It will take 2 minutes...",
            style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ],
      ),
    );
  }
}




