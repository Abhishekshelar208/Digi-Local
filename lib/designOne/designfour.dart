











import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'package:url_launcher/url_launcher.dart';

import '../pages/fullscreenimageview.dart';

import 'AchivementsSliders/achivementsliderfordesignone.dart';
import 'ConnectwithMe/connectwithmefordesignone.dart';
import 'ExperienceSliders/experiencesliderfordesignone.dart';
import 'ProjectSliders/projectsliderfordesignone.dart';
import 'marqueechips.dart';


class DesignFour extends StatefulWidget {
  final Map<String, dynamic> userData;

  DesignFour({required this.userData});

  @override
  _DesignFourState createState() => _DesignFourState();
}

class _DesignFourState extends State<DesignFour> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;
  late ScrollController _scrollController;
  double _scrollRotationAngle = 0.0;
  double _scrollSpeedMultiplier = 0.001; // Control the scroll rotation speed

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for the first animation
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    // Define the height animation (from 50 to 250)
    _heightAnimation = Tween<double>(
      begin: 270,
      end: 370,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Define the rotation animation (from 0 to 2 * pi)
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159, // 360 degrees in radians
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Define the opacity animation (from 0 to 1)
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the first animation when the screen loads
    _animationController.forward();

    // Initialize the scroll controller for the second animation
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Handle scroll events to rotate the image
  void _handleScroll() {
    setState(() {
      // Calculate the rotation angle based on scroll position
      _scrollRotationAngle = _scrollController.offset * _scrollSpeedMultiplier;
    });
  }




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

  // Stats Section Widget
  Widget _buildStatsSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xffE8E7E3),
            blurRadius: 0.5,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard("Months of Experience", "${widget.userData["MonthsofExperience"]}+"),
              SizedBox(width: 25),
              _buildStatCard("Internship Completed", "${widget.userData["InternshipsCompleted"]}+"),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard("Projects Completed", "${widget.userData["NoofProjectsCompleted"]}+"),
              SizedBox(width: 25),
              _buildStatCard("No of Skills", "${widget.userData["NoofSKills"]}+"),
            ],
          ),
        ],
      ),
    );
  }

  // Reusable Widget for Statistic Card
  Widget _buildStatCard(String title, String value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen width
        double screenWidth = MediaQuery.of(context).size.width;

        // Check if the device is a mobile or PC
        bool isMobile = screenWidth < 600;

        return Container(
          height: isMobile ? 100 : 150, // Smaller height for mobile
          width: isMobile ? 160 : 200,  // Adjust width based on screen size
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(isMobile ? 8 : 16), // Adjust padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isMobile ? 14 : 16, // Font size for mobile/PC
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12), // Responsive spacing
              Text(
                value,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isMobile ? 34 : 42, // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = MediaQuery
              .of(context)
              .size
              .width;

          // Responsive sizes based on screen width
          double fontSize = screenWidth > 800
              ? 24
              : screenWidth > 600
              ? 20
              : 16;
          double headingFontSize = screenWidth > 800
              ? 45
              : screenWidth > 600
              ? 35
              : 25;
          double paddingValue = screenWidth > 800
              ? 40
              : screenWidth > 600
              ? 30
              : 16;
          return Scaffold(
            backgroundColor: Color(0xffE8E7E3),
            body: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Update the rotation angle when the user scrolls
                _handleScroll();
                return true;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      // LayoutBuilder(
                      //   builder: (context, constraints) {
                      //     double screenWidth = MediaQuery.of(context).size.width;
                      //     bool isMobile = screenWidth < 600;
                      //
                      //     return Padding(
                      //       padding: EdgeInsets.only(
                      //         top: isMobile ? 50 : 50, // Extra top space for PC
                      //       ),
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         mainAxisSize: MainAxisSize.min,
                      //         children: [
                      //           ElevatedButton(
                      //             onPressed: () {},
                      //             style: ElevatedButton.styleFrom(
                      //               backgroundColor: Colors.white,
                      //               minimumSize: Size(
                      //                 0,
                      //                 isMobile ? 50 : 50, // Increased button height for PC
                      //               ),
                      //             ),
                      //             child: Text(
                      //               "Hello, I'm ${widget.userData["personalInfo"]["fullName"].toString().split(" ").first} 👋",
                      //               style: GoogleFonts.blinker(
                      //                 fontSize: isMobile ? 18.0 : 20.0, // Larger font size for PC
                      //                 color: Colors.black,
                      //                 fontWeight: FontWeight.w500,
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     );
                      //   },
                      // ),

                      // SizedBox(height: 30),
                      // LayoutBuilder(
                      //   builder: (context, constraints) {
                      //     double screenHeight = MediaQuery.of(context).size.height;
                      //     double screenWidth = MediaQuery.of(context).size.width;
                      //     bool isMobile = screenWidth < 600;
                      //
                      //     return Padding(
                      //       padding: const EdgeInsets.all(20.0),
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           GradientText(
                      //             isMobile
                      //                 ? "Hi, I'm ${widget.userData["personalInfo"]["fullName"]}\n– Creating, Learning &\n Growing Every Day!"
                      //                 : "Hi Everyone, I'm ${widget.userData["personalInfo"]["fullName"]}\nCreating & Growing Every Day!", // 2 lines for PC
                      //             style: GoogleFonts.blinker(
                      //               fontSize: isMobile ? screenWidth * 0.0860 : 70, // Bigger font for PC
                      //               fontWeight: FontWeight.w600,
                      //             ),
                      //             colors: [
                      //               Colors.black,       // Darkest shade
                      //               Colors.black,       // Darkest shade
                      //               Colors.black,       // Darkest shade
                      //               Colors.black,       // Darkest shade
                      //               // Colors.grey[800]!,  // Dark grey
                      //               // Colors.grey[500]!,  // Medium grey
                      //               // Colors.grey[300]!,  // Light grey
                      //             ],
                      //
                      //           ),
                      //         ],
                      //       ),
                      //     );
                      //   },
                      // ),
                      //
                      // SizedBox(height: 30),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     ElevatedButton.icon(
                      //       onPressed: () async {
                      //         final String resumeUrl = widget.userData["resumefile"] ?? "";
                      //         if (resumeUrl.isNotEmpty) {
                      //           Uri uri = Uri.parse(resumeUrl);
                      //           if (await canLaunchUrl(uri)) {
                      //             await launchUrl(uri, mode: LaunchMode.externalApplication);
                      //           } else {
                      //             print("Could not launch $resumeUrl");
                      //           }
                      //         } else {
                      //           print("No resume file available to download.");
                      //         }
                      //       },
                      //       icon: Image.asset(
                      //         "lib/assets/icons/resume.png",
                      //         color: Colors.white,
                      //         width: 15,
                      //         height: 15,
                      //         fit: BoxFit.contain,
                      //       ),
                      //       label: Padding(
                      //         padding: const EdgeInsets.all(8.0),
                      //         child: Text(
                      //           "Resume",
                      //           style: GoogleFonts.blinker(
                      //             fontSize: 18.0,
                      //             fontWeight: FontWeight.w500,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       ),
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor: Colors.black,
                      //         side: const BorderSide(color: Colors.white, width: 0.5),
                      //         shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(100),
                      //         ),
                      //         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: 40,
                      // ),
                      // // Animated image with bounce and rotation
                      // LayoutBuilder(
                      //   builder: (context, constraints) {
                      //     double screenWidth = MediaQuery.of(context).size.width;
                      //     bool isMobile = screenWidth < 600;
                      //
                      //     return Padding(
                      //       padding: EdgeInsets.only(top: isMobile ? 0 : 50), // Add space from the top for PC
                      //       child: AnimatedBuilder(
                      //         animation: _animationController,
                      //         builder: (context, child) {
                      //           return Opacity(
                      //             opacity: _opacityAnimation.value,
                      //             child: Transform.rotate(
                      //               // Combine both rotations (initial and scroll-based)
                      //               angle: _rotationAnimation.value + _scrollRotationAngle,
                      //               child: Container(
                      //                 height: isMobile
                      //                     ? _heightAnimation.value
                      //                     : _heightAnimation.value * 1.31, // Increase size for PC
                      //                 width: isMobile
                      //                     ? _heightAnimation.value
                      //                     : _heightAnimation.value * 1.31,
                      //                 child: Image.asset(
                      //                   "lib/assets/images/circleImage-removebg-preview.png",
                      //                   fit: BoxFit.cover,
                      //                 ),
                      //               ),
                      //             ),
                      //           );
                      //         },
                      //       ),
                      //     );
                      //   },
                      // ),
                      //
                      //
                      // SizedBox(
                      //   height: 50,
                      // ),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            // PC layout
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 50),
                                // Profile Image for PC
                                if (widget.userData["personalInfo"]["profilePicture"].isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => FullScreenImageView(
                                          imageUrl: widget.userData["personalInfo"]["profilePicture"],
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          widget.userData["personalInfo"]["profilePicture"],
                                          height: 550,
                                          width: constraints.maxWidth * 0.30,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(Icons.person, size: 50, color: Colors.grey);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 50),

                                // Right-side Information
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // ElevatedButton(
                                        //   onPressed: () {},
                                        //   style: ElevatedButton.styleFrom(
                                        //     backgroundColor: const Color(0xff1E1E1E),
                                        //   ),
                                        //   child: Text(
                                        //     "About",
                                        //     style: GoogleFonts.blinker(
                                        //       fontSize: 18.0,
                                        //       color: Colors.white,
                                        //       fontWeight: FontWeight.w500,
                                        //     ),
                                        //   ),
                                        // ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Hi Everyone! I'm",
                                          style: GoogleFonts.blinker(
                                            fontSize: 30,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          "${widget.userData["personalInfo"]["fullName"]}",
                                          style: GoogleFonts.blinker(
                                            fontSize: 40,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          widget.userData["personalInfo"]["aboutyourself"] ?? "No Details" ?? "No Details",
                                          style: GoogleFonts.blinker(
                                            fontSize: 20,
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          children: [
                                            _buildStatsSection(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Mobile layout
                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // ElevatedButton(
                                  //   onPressed: () {},
                                  //   style: ElevatedButton.styleFrom(
                                  //     backgroundColor: const Color(0xff1E1E1E),
                                  //   ),
                                  //   child: Text(
                                  //     "About",
                                  //     style: GoogleFonts.blinker(
                                  //       fontSize: 18.0,
                                  //       color: Colors.white,
                                  //       fontWeight: FontWeight.w500,
                                  //     ),
                                  //   ),
                                  // ),
                                  SizedBox(height: 30,),
                                  if (widget.userData["personalInfo"]["profilePicture"].isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => FullScreenImageView(
                                            imageUrl: widget.userData["personalInfo"]["profilePicture"],
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image.network(
                                            widget.userData["personalInfo"]["profilePicture"],
                                            height: 300,
                                            width: 250,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(Icons.person, size: 50, color: Colors.grey);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Hi Everyone! I'm",
                                              style: GoogleFonts.blinker(
                                                fontSize: 30,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "${widget.userData["personalInfo"]["fullName"]}",
                                          style: GoogleFonts.blinker(
                                            fontSize: 40,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, // Align everything to the left
                                      children: [
                                        Text(
                                          widget.userData["personalInfo"]["aboutyourself"] ?? "No Details" ?? "No Details",
                                          style: GoogleFonts.blinker(
                                            fontSize: 20,
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.left, // Align text to the left
                                        ),
                                        SizedBox(height: 40),
                                        Row(
                                          children: [
                                            _buildStatsSection(),
                                          ],

                                        ),
                                        SizedBox(height: 30),// This will also align to the left
                                      ],
                                    ),
                                  )

                                ],
                              ),
                            );
                          }
                        },
                      ),


                      SizedBox(
                        height: constraints.maxWidth > 800 ? 50 : 10, // 40 for PC, 10 for mobile
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final String resumeUrl = widget.userData["resumefile"] ?? "";
                              if (resumeUrl.isNotEmpty) {
                                Uri uri = Uri.parse(resumeUrl);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  print("Could not launch $resumeUrl");
                                }
                              } else {
                                print("No resume file available to download.");
                              }
                            },
                            icon: Image.asset(
                              "lib/assets/icons/resume.png",
                              color: Colors.white,
                              width: 15,
                              height: 15,
                              fit: BoxFit.contain,
                            ),
                            label: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Resume",
                                style: GoogleFonts.blinker(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              side: const BorderSide(color: Colors.white, width: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Divider(
                        color: Colors.black54,
                        thickness: 1,
                        height: 20,
                      ),



                      SizedBox(
                        height: constraints.maxWidth > 800 ? 100 : 100, // 40 for PC, 0 for mobile
                      ),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1E1E1E),
                            ),
                            child: Text(
                              "Skills",
                              style: GoogleFonts.blinker(
                                fontSize: 18.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xffE8E7E3),
                          border: Border.all(color: Colors.black, width: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: 55,
                        width: MediaQuery.of(context).size.width > 600 ? 1100 : 400, // 600 for PC, 400 for mobile
                        child: MarqueeChips(
                          velocity: 30.0, // Adjust scrolling speed if needed
                          chips: (widget.userData["skills"] as List<dynamic>).map<Widget>((skill) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                skill.toString(),
                                style: GoogleFonts.blinker(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(height: 50,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1E1E1E),
                            ),
                            child: Text(
                              "Tools / Software",
                              style: GoogleFonts.blinker(
                                fontSize: 18.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xffE8E7E3),
                          border: Border.all(color: Colors.black, width: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: 55,
                        width: MediaQuery.of(context).size.width > 600 ? 1100 : 400, // 600 for PC, 400 for mobile
                        child: MarqueeChips(
                          velocity: 30.0, // Adjust scrolling speed if needed
                          chips: (widget.userData["tools"] as List<dynamic>).map<Widget>((skill) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                skill.toString(),
                                style: GoogleFonts.blinker(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(height: 50,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1E1E1E),
                            ),
                            child: Text(
                              "Soft Skills",
                              style: GoogleFonts.blinker(
                                fontSize: 18.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      // ExperienceSlider(experience: userData["experiences"]),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xffE8E7E3),
                          border: Border.all(color: Colors.black, width: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: 55,
                        width: MediaQuery.of(context).size.width > 600 ? 1100 : 400, // 600 for PC, 400 for mobile
                        child: MarqueeChips(
                          velocity: 30.0, // Adjust scrolling speed if needed
                          chips: (widget.userData["softSkills"] as List<dynamic>).map<Widget>((skill) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                skill.toString(),
                                style: GoogleFonts.blinker(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(
                        height: 50,
                      ),

                      Divider(
                        color: Colors.black54,
                        thickness: 1,
                        height: 20,
                      ),




                      SizedBox(
                        height: 30,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1E1E1E),
                            ),
                            child: Text(
                              "Projects",
                              style: GoogleFonts.blinker(
                                fontSize: 18.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("My Latest ",style: GoogleFonts.blinker(
                            fontSize: 35,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),),
                          Text("Projects",style: GoogleFonts.blinker(
                            fontSize: 35,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ProjectSliderForDesignOne(projects: widget.userData["projects"]),

                      SizedBox(
                        height: 50,
                      ),

                      Divider(
                        color: Colors.black54,
                        thickness: 1,
                        height: 20,
                      ),




                      SizedBox(
                        height: 30,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1E1E1E),
                            ),
                            child: Text(
                              "Achievements",
                              style: GoogleFonts.blinker(
                                fontSize: 18.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("My ",style: GoogleFonts.blinker(
                            fontSize: 35,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),),
                          Text("Achievements",style: GoogleFonts.blinker(
                            fontSize: 35,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      EventSliderForDesigeOne(
                        events: widget.userData["achievements"],
                      ),
                      SizedBox(
                        height: 30,
                      ),

                      SizedBox(
                        height: 50,
                      ),

                      Divider(
                        color: Colors.black54,
                        thickness: 1,
                        height: 20,
                      ),




                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1E1E1E),
                            ),
                            child: Text(
                              "Experiences",
                              style: GoogleFonts.blinker(
                                fontSize: 18.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("My ",style: GoogleFonts.blinker(
                            fontSize: 35,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),),
                          Text("Experiences",style: GoogleFonts.blinker(
                            fontSize: 35,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ExperienceSectionForDesignOne(
                        offers: widget.userData["Offers"] as List<dynamic>,
                      ),
                      ConnectWithMedesignOne(userData: widget.userData,)


                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
}