import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectWithMedesignOne extends StatelessWidget {
  final Map<String, dynamic> userData;

  ConnectWithMedesignOne({required this.userData});

  void _launchURL(String url) async {
    if (url.isNotEmpty) {
      Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print("Could not launch $url");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        double iconSize = isMobile ? 50 : 60;
        double textSize = isMobile ? 32 : 42;
        double thankYouSize = isMobile ? 24 : 32;
        double interestSize = isMobile ? 16 : 20;

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 50 : 80,
            horizontal: isMobile ? 20 : 40,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8FAFC), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(
                "Connect with Us",
                style: GoogleFonts.inter(
                  fontSize: textSize,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Stay connected and follow us on social media",
                style: GoogleFonts.inter(
                  fontSize: interestSize,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon('lib/assets/images/newinsta.png', userData["accountLinks"]["instagram"] ?? "", iconSize),
                  SizedBox(width: isMobile ? 30 : 50),
                  _socialIcon('lib/assets/images/logo.png', 'https://wa.me/91${userData["accountLinks"]["whatsapp"] ?? ""}', iconSize),
                  SizedBox(width: isMobile ? 30 : 50),
                  _socialIcon('lib/assets/images/facebook.png', userData["accountLinks"]["facebook"] ?? "", iconSize),
                ],
              ),
              SizedBox(height: 50),
              Container(
                padding: EdgeInsets.all(isMobile ? 24 : 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF64748B).withOpacity(0.08),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Thank you for visiting our store!",
                      style: GoogleFonts.inter(
                        fontSize: thankYouSize,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "We truly appreciate your time and support for our local business.",
                      style: GoogleFonts.inter(
                        fontSize: interestSize,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _socialIcon(String assetPath, String url, double size) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _launchURL(url),
        child: Container(
          height: size,
          width: size,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: Color(0xFFE2E8F0),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF64748B).withOpacity(0.1),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(assetPath),
        ),
      ),
    );
  }
}
