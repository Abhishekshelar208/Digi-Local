
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pages/AllReviewsPage.dart';
import '../pages/displayServicesGridVise.dart';
import '../pages/fullscreenimageview.dart';

import 'AchivementsSliders/achivementsliderfordesignone.dart';
import 'ConnectwithMe/connectwithmefordesignone.dart';
import 'ExperienceSliders/experiencesliderfordesignone.dart';
import 'ProjectSliders/projectsliderfordesignone.dart';
import 'marqueechips.dart';

class DesignOne extends StatefulWidget {
  final Map<String, dynamic> userData;

  DesignOne({required this.userData});

  @override
  _DesignOneState createState() => _DesignOneState();
}

class _DesignOneState extends State<DesignOne> with SingleTickerProviderStateMixin {
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
              _buildStatCard("Products Category", "${widget.userData["NoofProducts"]}+"),
              SizedBox(width: 25),
              _buildStatCard("Shop Timings", "${widget.userData["ShopTimings"]}"),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard("Years of Experience", "${widget.userData["yearsofExperience"]}+"),
              SizedBox(width: 25),
              _buildStatCard("Google Rating", "${widget.userData["googleRating"]}+"),
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
          height: isMobile ? 110 : 160,
          width: isMobile ? 160 : 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFF8FAFC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF64748B).withOpacity(0.08),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Color(0xFF64748B),
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: Color(0xFF0F172A),
                  fontSize: isMobile ? 32 : 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, double screenWidth) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: screenWidth > 800 ? 48 : 32,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w900,
        letterSpacing: -1,
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Color(0xFF6366F1)),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (index < rating && rating % 1 != 0) {
          return Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "Just now";
    try {
      DateTime dateTime = DateTime.parse(timestamp.toString());
      Duration difference = DateTime.now().difference(dateTime);
      
      if (difference.inDays > 365) {
        return "${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago";
      } else if (difference.inDays > 30) {
        return "${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago";
      } else if (difference.inDays > 0) {
        return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
      } else if (difference.inHours > 0) {
        return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago";
      } else {
        return "Just now";
      }
    } catch (e) {
      return "Recently";
    }
  }

  void _showWriteReviewDialog(BuildContext context) {
    double rating = 5.0;
    TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            "Write a Review",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6366F1),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rate your experience",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1.0;
                        });
                      },
                    );
                  }),
                ),
                SizedBox(height: 24),
                Text(
                  "Write your review",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: reviewController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Share your experience...",
                    hintStyle: GoogleFonts.inter(color: Color(0xFF94A3B8)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
                    ),
                  ),
                  style: GoogleFonts.inter(fontSize: 15),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reviewController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please write a review"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                User? user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please log in to write a review"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Fetch user name from users database
                String userName = user.displayName ?? "Anonymous";
                try {
                  DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");
                  DatabaseEvent userEvent = await usersRef.orderByChild("email").equalTo(user.email).once();
                  if (userEvent.snapshot.value != null) {
                    Map<dynamic, dynamic> userData = userEvent.snapshot.value as Map;
                    if (userData.isNotEmpty) {
                      var userInfo = userData.values.first;
                      userName = userInfo["name"] ?? user.displayName ?? user.email?.split('@')[0] ?? "Anonymous";
                    }
                  }
                } catch (e) {
                  print("Error fetching user name: $e");
                }

                String shopEmailKey = widget.userData["accountLinks"]["email"].toString().replaceAll('.', '_');
                DatabaseReference reviewRef = FirebaseDatabase.instance
                    .ref("reviews/$shopEmailKey")
                    .push();

                try {
                  await reviewRef.set({
                    "userName": userName,
                    "userEmail": user.email,
                    "rating": rating,
                    "review": reviewController.text.trim(),
                    "timestamp": DateTime.now().toIso8601String(),
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text("Review posted successfully!"),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to post review. Try again."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              child: Text(
                "Submit",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
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
            backgroundColor: Color(0xffFAFAFA),
            body: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Update the rotation angle when the user scrolls
                _handleScroll();
                return true;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth > 800 ? 80.0 : 24.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: screenWidth > 800 ? 60 : 30),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double screenWidth = MediaQuery.of(context).size.width;
                          bool isMobile = screenWidth < 600;

                          return Padding(
                            padding: EdgeInsets.only(
                              top: isMobile ? 40 : 60,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF6366F1).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {},
                                  borderRadius: BorderRadius.circular(50),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 28 : 40,
                                      vertical: isMobile ? 16 : 18,
                                    ),
                                    child: Text(
                                      "Welcome to ${widget.userData["shopInfo"]["shopName"]} 👋",
                                      style: GoogleFonts.inter(
                                        fontSize: isMobile ? 16.0 : 18.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: screenWidth > 800 ? 80 : 50),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double screenHeight = MediaQuery.of(context).size.height;
                          double screenWidth = MediaQuery.of(context).size.width;
                          bool isMobile = screenWidth < 600;

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 20.0 : 60.0,
                              vertical: 20.0,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  isMobile
                                      ? "Welcome! Enjoy top-quality\nproducts and exceptional service."
                                      : "Hello Everyone, Welcome to ${widget.userData["shopInfo"]["shopName"]}",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: isMobile ? screenWidth * 0.075 : 64,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    height: 1.2,
                                    letterSpacing: -1.5,
                                  ),
                                ),
                                if (!isMobile) SizedBox(height: 16),
                                if (!isMobile)
                                  Text(
                                    "Bringing You the Best Products Every Day!",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.width > 800 ? 100 : 30,
                      ),
                      // Animated image with bounce and rotation
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


                      SizedBox(
                        height: 50,
                      ),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            // PC layout
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 50),
                                // Profile Image for PC
                                if (widget.userData["shopInfo"]["shopImage"].isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => FullScreenImageView(
                                          imageUrl: widget.userData["shopInfo"]["shopImage"],
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(24),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFF64748B).withOpacity(0.15),
                                              blurRadius: 30,
                                              offset: Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(24),
                                          child: Image.network(
                                            widget.userData["shopInfo"]["shopImage"],
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
                                          "Welcome to",
                                          style: GoogleFonts.inter(
                                            fontSize: 20,
                                            color: Color(0xFF6366F1),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          "${widget.userData["shopInfo"]["shopName"]}",
                                          style: GoogleFonts.inter(
                                            fontSize: 48,
                                            color: Color(0xFF0F172A),
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -1,
                                          ),
                                        ),
                          SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              color: Color(0xFF64748B),
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                widget.userData["shopInfo"]["address"] ?? "No address",
                                                style: GoogleFonts.inter(
                                                  fontSize: 18,
                                                  color: Color(0xFF64748B),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                _buildStatCard("Products Category", "${widget.userData["NoofProducts"]}+"),
                                                SizedBox(width: 25),
                                                _buildStatCard("Shop Timings", "${widget.userData["ShopTimings"]}"),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                _buildStatCard("Years of Experience", "${widget.userData["yearsofExperience"]}+"),
                                                SizedBox(width: 25),
                                                _buildStatCard("Google Rating", "${widget.userData["googleRating"]}+"),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                _buildStatCard("Total Visits", "${widget.userData["totalVisits"] ?? 0}"),
                                                SizedBox(width: 25),
                                                _buildStatCard("Avg Rating", "${(widget.userData["averageRating"] ?? 0.0).toStringAsFixed(1)}⭐"),
                                              ],
                                            ),
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
                                  if (widget.userData["shopInfo"]["shopImage"].isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => FullScreenImageView(
                                            imageUrl: widget.userData["shopInfo"]["shopImage"],
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(24),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFF64748B).withOpacity(0.15),
                                                blurRadius: 30,
                                                offset: Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(24),
                                            child: Image.network(
                                              widget.userData["shopInfo"]["shopImage"],
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
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                color: Color(0xFF6366F1),
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "${widget.userData["shopInfo"]["shopName"]}",
                                          style: GoogleFonts.inter(
                                            fontSize: 36,
                                            color: Color(0xFF0F172A),
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 16),
                                    height: 1,
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, // Align everything to the left
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              color: Color(0xFF64748B),
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                widget.userData["shopInfo"]["address"] ?? "No address",
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  color: Color(0xFF64748B),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 40),
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                _buildStatCard("Products", "${widget.userData["NoofProducts"]}+"),
                                                SizedBox(width: 25),
                                                _buildStatCard("Timings", "${widget.userData["ShopTimings"]}"),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                _buildStatCard("Experience", "${widget.userData["yearsofExperience"]}Y"),
                                                SizedBox(width: 25),
                                                _buildStatCard("Rating", "${widget.userData["googleRating"]}+"),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                _buildStatCard("Visits", "${widget.userData["totalVisits"] ?? 0}"),
                                                SizedBox(width: 25),
                                                _buildStatCard("Avg", "${(widget.userData["averageRating"] ?? 0.0).toStringAsFixed(1)}⭐"),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 30),
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
                        height: constraints.maxWidth > 800 ? 80 : 60,
                      ),



                      SizedBox(
                        height: constraints.maxWidth > 800 ? 100 : 100, // 40 for PC, 0 for mobile
                      ),


                      Text(
                        "Services We Offered",
                        style: GoogleFonts.inter(
                          fontSize: screenWidth > 800 ? 48 : 32,
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),

                      ServicesGrid(services: widget.userData["services"]),

                      SizedBox(height: 50,),

                      Text(
                        "Our Products Category",
                        style: GoogleFonts.inter(
                          fontSize: screenWidth > 800 ? 48 : 32,
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),

                      ServicesGrid(services: widget.userData["products"]),

                      SizedBox(height: 50,),

                      Text(
                        "Use Our Coupons",
                        style: GoogleFonts.inter(
                          fontSize: screenWidth > 800 ? 48 : 32,
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFF8FAFC), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: Color(0xFFE2E8F0), width: 2),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF64748B).withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        height: 65,
                        width: MediaQuery.of(context).size.width > 600 ? 1100 : double.infinity,
                        child: MarqueeChips(
                          velocity: 30.0,
                          chips: (widget.userData["coupons"] as List<dynamic>).map<Widget>((skill) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8.0),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF6366F1).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                skill.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(
                        height: 50,
                      ),

                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFFE2E8F0),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),




                      SizedBox(
                        height: 30,
                      ),

                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Our Featured Products",
                        style: GoogleFonts.inter(
                          fontSize: screenWidth > 800 ? 48 : 32,
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ProjectSliderForDesignOne(projects: widget.userData["Products"]),

                      SizedBox(
                        height: 50,
                      ),

                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFFE2E8F0),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),




                      SizedBox(
                        height: 30,
                      ),

                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     ElevatedButton(
                      //       onPressed: () {},
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor: const Color(0xff1E1E1E),
                      //       ),
                      //       child: Text(
                      //         "Shop Features",
                      //         style: GoogleFonts.blinker(
                      //           fontSize: 18.0,
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Our Upcoming Events",
                        style: GoogleFonts.inter(
                          fontSize: screenWidth > 800 ? 48 : 32,
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      EventSliderForDesigeOne(
                        events: widget.userData["Events"],
                      ),
                      SizedBox(
                        height: 30,
                      ),

                      SizedBox(
                        height: 50,
                      ),

                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFFE2E8F0),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),




                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Latest Offers & Discounts",
                        style: GoogleFonts.inter(
                          fontSize: screenWidth > 800 ? 48 : 32,
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ExperienceSectionForDesignOne(
                        offers: widget.userData["Offers"] as List<dynamic>,
                      ),
                      SizedBox(height: 50),

                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFFE2E8F0),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Delivery Information Section
                      if ((widget.userData["deliverySettings"]?["available"] ?? false) == true) ...[
                        SizedBox(height: 30),
                        _buildSectionTitle("Delivery Information", screenWidth),
                        SizedBox(height: 30),
                        Container(
                          padding: EdgeInsets.all(screenWidth > 800 ? 40 : 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Color(0xFFE2E8F0), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF64748B).withOpacity(0.08),
                                blurRadius: 20,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((widget.userData["deliverySettings"]?["radius"] ?? "").isNotEmpty)
                                _buildInfoItem(Icons.location_on, "Delivery Radius", widget.userData["deliverySettings"]["radius"]),
                              if ((widget.userData["deliverySettings"]?["minimumOrder"] ?? "").isNotEmpty) ...[
                                SizedBox(height: 16),
                                _buildInfoItem(Icons.shopping_cart, "Minimum Order", widget.userData["deliverySettings"]["minimumOrder"]),
                              ],
                              if ((widget.userData["deliverySettings"]?["deliveryFee"] ?? "").isNotEmpty) ...[
                                SizedBox(height: 16),
                                _buildInfoItem(Icons.currency_rupee, "Delivery Fee", widget.userData["deliverySettings"]["deliveryFee"]),
                              ],
                              if ((widget.userData["deliverySettings"]?["timings"] ?? "").isNotEmpty) ...[
                                SizedBox(height: 16),
                                _buildInfoItem(Icons.access_time, "Delivery Time", widget.userData["deliverySettings"]["timings"]),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 50),
                      ],

                      // Payment Methods Section
                      if ((widget.userData["paymentMethods"] as List?)?.isNotEmpty ?? false) ...[
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFFE2E8F0),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        _buildSectionTitle("Accepted Payment Methods", screenWidth),
                        SizedBox(height: 30),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: (widget.userData["paymentMethods"] as List).map<Widget>((method) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Color(0xFF6366F1), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF64748B).withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF6366F1).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      method.toString().contains("UPI")
                                          ? Icons.qr_code
                                          : method.toString().contains("Card")
                                              ? Icons.credit_card
                                              : method.toString().contains("Cash")
                                                  ? Icons.money
                                                  : method.toString().contains("Bank")
                                                      ? Icons.account_balance
                                                      : Icons.payment,
                                      color: Color(0xFF6366F1),
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    method.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 50),
                      ],

                      // Shop Gallery Section
                      if ((widget.userData["shopGallery"] as List?)?.isNotEmpty ?? false) ...[
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFFE2E8F0),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        _buildSectionTitle("Shop Gallery", screenWidth),
                        SizedBox(height: 30),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: screenWidth > 800 ? 4 : 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1,
                          ),
                          itemCount: (widget.userData["shopGallery"] as List).length,
                          itemBuilder: (context, index) {
                            String imageUrl = (widget.userData["shopGallery"] as List)[index];
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => FullScreenImageView(imageUrl: imageUrl),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Color(0xFFE2E8F0), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF64748B).withOpacity(0.08),
                                      blurRadius: 20,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) => Container(
                                      color: Colors.grey.shade100,
                                      child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 50),
                      ],

                      // Videos Section
                      if ((widget.userData["videos"] as List?)?.isNotEmpty ?? false) ...[
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFFE2E8F0),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        _buildSectionTitle("Videos", screenWidth),
                        SizedBox(height: 30),
                        SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (widget.userData["videos"] as List).length,
                            itemBuilder: (context, index) {
                              var video = (widget.userData["videos"] as List)[index];
                              return Container(
                                width: screenWidth > 800 ? 400 : 300,
                                margin: EdgeInsets.only(right: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    _launchURL(video["url"] ?? "");
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Color(0xFFE2E8F0), width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF64748B).withOpacity(0.08),
                                          blurRadius: 20,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                              child: Image.network(
                                                video["thumbnail"] ?? "",
                                                height: 200,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stack) => Container(
                                                  height: 200,
                                                  color: Colors.grey.shade100,
                                                  child: Icon(Icons.video_library, size: 64, color: Colors.grey),
                                                ),
                                              ),
                                            ),
                                            Positioned.fill(
                                              child: Center(
                                                child: Container(
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF6366F1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Text(
                                            video["title"] ?? "Video",
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0F172A),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 50),
                      ],

                      // FAQs Section
                      if ((widget.userData["faqs"] as List?)?.isNotEmpty ?? false) ...[
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFFE2E8F0),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        _buildSectionTitle("Frequently Asked Questions", screenWidth),
                        SizedBox(height: 30),
                        ...List.generate((widget.userData["faqs"] as List).length, (index) {
                          var faq = (widget.userData["faqs"] as List)[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Color(0xFFE2E8F0), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF64748B).withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Theme(
                              data: ThemeData().copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                leading: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF6366F1).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Q${index + 1}",
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF6366F1),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  faq["question"] ?? "",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(72, 0, 16, 16),
                                    child: Text(
                                      faq["answer"] ?? "",
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        color: Color(0xFF64748B),
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 50),
                      ],

                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFFE2E8F0),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Reviews Section
                      SizedBox(height: 30),
                      _buildSectionTitle("Customer Reviews", screenWidth),
                      SizedBox(height: 30),

                      // Reviews List
                      StreamBuilder<DatabaseEvent>(
                        stream: FirebaseDatabase.instance
                            .ref("reviews/${widget.userData["accountLinks"]["email"].toString().replaceAll('.', '_')}")
                            .onValue,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text("Error loading reviews"));
                          }

                          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                            return Container(
                              padding: EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Color(0xFFE2E8F0), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF64748B).withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.reviews_outlined, size: 64, color: Colors.grey[300]),
                                    SizedBox(height: 16),
                                    Text(
                                      "No reviews yet. Be the first to review!",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          Map<dynamic, dynamic> reviewsMap = snapshot.data!.snapshot.value as Map;
                          List<MapEntry> reviewsList = reviewsMap.entries.toList()
                            ..sort((a, b) {
                              // Sort by rating (descending), then by timestamp (newest first)
                              int ratingCompare = (b.value["rating"] ?? 0).compareTo(a.value["rating"] ?? 0);
                              if (ratingCompare != 0) return ratingCompare;
                              return (b.value["timestamp"] ?? 0).compareTo(a.value["timestamp"] ?? 0);
                            });

                          // Show only first 2 reviews
                          List<MapEntry> displayedReviews = reviewsList.take(2).toList();
                          bool hasMoreReviews = reviewsList.length > 2;

                          return Column(
                            children: [
                              ...displayedReviews.map((entry) {
                              var review = entry.value;
                              return Container(
                                margin: EdgeInsets.only(bottom: 20),
                                padding: EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Color(0xFFE2E8F0), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF64748B).withOpacity(0.08),
                                      blurRadius: 20,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (review["userName"]?.toString().isNotEmpty == true
                                                  ? review["userName"][0]
                                                  : "U").toUpperCase(),
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                review["userName"] ?? "Anonymous",
                                                style: GoogleFonts.inter(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                _formatTimestamp(review["timestamp"]),
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: Color(0xFF64748B),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _buildStars(review["rating"]?.toDouble() ?? 0.0),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        review["review"] ?? "",
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          color: Color(0xFF475569),
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            if (hasMoreReviews) ...[
                              SizedBox(height: 24),
                              Container(
                                width: screenWidth > 800 ? 600 : double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AllReviewsPage(
                                          shopEmail: widget.userData["accountLinks"]["email"],
                                          shopName: widget.userData["shopInfo"]["shopName"],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.arrow_forward, size: 20),
                                  label: Text(
                                    "See All Reviews (${reviewsList.length})",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Color(0xFF6366F1),
                                    side: BorderSide(color: Color(0xFF6366F1), width: 2),
                                    padding: EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                          );
                        },
                      ),

                      SizedBox(height: 50),

                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFFE2E8F0),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 30),
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