import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExperienceSectionForDesignTwo extends StatelessWidget {
  final List<dynamic> experiences;

  ExperienceSectionForDesignTwo({required this.experiences});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // Consider width < 600px as mobile

    return Column(
      children: experiences.map((experience) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: isMobile
                  ? Column( // Mobile view: stacked layout
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        experience["title"] ?? "No Title",
                        style: GoogleFonts.blinker(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      // Text(
                      //   experience["duration"] ?? "No Duration",
                      //   style: GoogleFonts.blinker(
                      //     fontSize: 16,
                      //     color: Colors.white54,
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    experience["description"] ?? "No Description",
                    style: GoogleFonts.blinker(
                      fontSize: 18,
                      color: Colors.white60,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              )
                  : Row( // PC view: side-by-side layout
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Date (Left side)
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          experience["title"] ?? "No Title",
                          style: GoogleFonts.blinker(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        // Text(
                        //   experience["duration"] ?? "No Duration",
                        //   style: GoogleFonts.blinker(
                        //     fontSize: 16,
                        //     color: Colors.white54,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  // Description (Right side)
                  Expanded(
                    flex: 2,
                    child: Text(
                      experience["description"] ?? "No Description",
                      style: GoogleFonts.blinker(
                        fontSize: 18,
                        color: Colors.white60,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Divider for both mobile and PC
            Divider(
              color: Colors.white24,
              thickness: 1,
              height: 20,
            ),
          ],
        );
      }).toList(),
    );
  }
}
