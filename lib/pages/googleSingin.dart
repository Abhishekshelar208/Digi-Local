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
import 'package:digilocal/core/models/user_model.dart';
import 'package:digilocal/customer_app/navigation/customer_main_screen.dart';
import 'package:digilocal/shop_owner_app/navigation/owner_main_screen.dart';
import 'package:digilocal/pages/home_pageforStudent.dart';

class GoogleSignIn extends StatefulWidget {
  const GoogleSignIn({Key? key}) : super(key: key);

  @override
  State<GoogleSignIn> createState() => _GoogleSignInState();
}

class _GoogleSignInState extends State<GoogleSignIn> {
  bool isLoading = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  UserRole? _selectedRole;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn(BuildContext context) async {
    // Check if role is selected
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select your role first"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    setState(() => isLoading = true);
    try {
      GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
      UserCredential? userCredential;
      
      if (kIsWeb) {
        // For web, use signInWithPopup
        userCredential = await FirebaseAuth.instance.signInWithPopup(googleAuthProvider);
      } else {
        // For mobile, use signInWithProvider
        userCredential = await FirebaseAuth.instance.signInWithProvider(googleAuthProvider);
      }
      
      if (userCredential.user != null && context.mounted) {
        // Check if user exists in database
        final userId = userCredential.user!.uid;
        final userSnapshot = await FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(userId)
            .get();
        
        if (userSnapshot.exists) {
          // Existing user - navigate based on their role
          final userData = userSnapshot.value as Map<dynamic, dynamic>;
          final userRole = _parseUserRole(userData['userRole']);
          
          if (context.mounted) {
            _navigateBasedOnRole(context, userRole);
          }
        } else {
          // New user - save selected role and navigate
          await _saveUserRole(userCredential.user!, _selectedRole!);
          if (context.mounted) {
            _navigateBasedOnRole(context, _selectedRole!);
          }
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $error")));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  UserRole _parseUserRole(dynamic role) {
    if (role == null) return UserRole.customer;
    String roleStr = role.toString().toLowerCase();
    switch (roleStr) {
      case 'customer':
        return UserRole.customer;
      case 'shop_owner':
      case 'shopowner':
        return UserRole.shopOwner;
      case 'both':
        return UserRole.both;
      default:
        return UserRole.customer;
    }
  }

  void _navigateBasedOnRole(BuildContext context, UserRole role) {
    Widget destination;
    
    switch (role) {
      case UserRole.customer:
        destination = CustomerMainScreen();
        break;
      case UserRole.shopOwner:
        destination = OwnerMainScreen();
        break;
      case UserRole.both:
        // For users with both roles, navigate to HomeScreenForStdudent
        destination = HomeScreenForStdudent();
        break;
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  void _showRoleSelectionDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  "Welcome to DigiLocal!",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4C6EF5),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "How would you like to use the app?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 32),
                // Customer Option
                _buildRoleCard(
                  icon: Icons.shopping_bag,
                  title: "I'm a Customer",
                  subtitle: "Browse local shops and make purchases",
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _saveUserRole(user, UserRole.customer);
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => CustomerMainScreen()),
                      );
                    }
                  },
                ),
                SizedBox(height: 16),
                // Shop Owner Option
                _buildRoleCard(
                  icon: Icons.store,
                  title: "I'm a Shop Owner",
                  subtitle: "Manage my shop and sell products",
                  gradient: LinearGradient(
                    colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _saveUserRole(user, UserRole.shopOwner);
                    if (context.mounted) {
                      // Navigate to shop creation flow
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => CreateUserID()),
                      );
                    }
                  },
                ),
                SizedBox(height: 16),
                // Both Option
                _buildRoleCard(
                  icon: Icons.people,
                  title: "Both",
                  subtitle: "I want to shop and manage my business",
                  gradient: LinearGradient(
                    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _saveUserRole(user, UserRole.both);
                    if (context.mounted) {
                      // Show app selection for users with both roles
                      // _showAppSelectionDialog(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreenForStdudent()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAppSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Choose App",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4C6EF5),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Which app would you like to open?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildAppSelectionCard(
                        icon: Icons.shopping_bag,
                        title: "Customer",
                        gradient: LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => CustomerMainScreen()),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildAppSelectionCard(
                        icon: Icons.store,
                        title: "Shop Owner",
                        gradient: LinearGradient(
                          colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => OwnerMainScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSelectionCard({
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveUserRole(User user, UserRole role) async {
    try {
      final userRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);
      
      // Check if user data already exists
      final snapshot = await userRef.get();
      
      if (!snapshot.exists) {
        // Create new user with role
        await userRef.set({
          'name': user.displayName ?? 'User',
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'profilePic': user.photoURL ?? '',
          'userRole': role.toString().split('.').last,
          'createdAt': DateTime.now().toIso8601String(),
        });
      } else {
        // Update existing user's role
        await userRef.update({
          'userRole': role.toString().split('.').last,
        });
      }
    } catch (error) {
      print('Error saving user role: $error');
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
              Color(0xFF6366F1), // Soft Indigo
              Color(0xFF3B82F6), // Vibrant Blue
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  // Slide 1 - Welcome to DigiLocal
                  _buildSlide(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    icon: Icons.store_mall_directory,
                    title: "Bringing Local Shops\nOnline in Minutes",
                    subtitle: "We empower your neighborhood stores to go digital — fast, easy, and affordable.",
                  ),
                  // Slide 2 - Power to Local Businesses
                  _buildSlide(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    icon: Icons.business_center,
                    title: "Create Your Shop Account\nin Just 2 Minutes",
                    subtitle: "Add your shop photo, products, offers, and get your online store instantly — no coding or cost needed.",
                    highlight: "Your shop. Your identity. Your customers — online.",
                  ),
                  // Slide 3 - Discover Local Deals
                  _buildSlide(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    icon: Icons.local_offer,
                    title: "Find the Best Local\nDeals Around You",
                    subtitle: "Compare products, explore offers, and get instant notifications from nearby stores — all in one app.",
                    isLastSlide: true,
                  ),
                ],
              ),
            ),
            // Page Indicator
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required double screenWidth,
    required double screenHeight,
    required IconData icon,
    required String title,
    required String subtitle,
    String? highlight,
    bool isLastSlide = false,
  }) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.05,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.05),
            // Icon/Illustration
            Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 90,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.06),
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            if (highlight != null) ...[
              SizedBox(height: screenHeight * 0.03),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  highlight,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            SizedBox(height: screenHeight * 0.06),
            // Role Selection and Button
            if (isLastSlide) ...[
              // Role Selection Text
              Text(
                "Select Your Role",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              // Role Selection Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRoleSelectionChip(
                    icon: Icons.shopping_bag,
                    label: "Customer",
                    role: UserRole.customer,
                  ),
                  SizedBox(width: 12),
                  _buildRoleSelectionChip(
                    icon: Icons.store,
                    label: "Shop Owner",
                    role: UserRole.shopOwner,
                  ),
                  SizedBox(width: 12),
                  _buildRoleSelectionChip(
                    icon: Icons.people,
                    label: "Both",
                    role: UserRole.both,
                  ),
                ],
              ),
              SizedBox(height: 24),
              // Sign Up Button
              ElevatedButton(
                onPressed: isLoading ? null : () {
                  _handleGoogleSignIn(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF4C6EF5),
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C6EF5)),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'lib/assets/images/google.png',
                            height: 20,
                            width: 20,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.login, size: 20, color: Color(0xFF4C6EF5));
                            },
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Sign up with Google",
                            style: GoogleFonts.poppins(
                              color: Color(0xFF4C6EF5),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ]
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _pageController.jumpToPage(2);
                    },
                    child: Text(
                      "Skip",
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF4C6EF5),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Next",
                          style: GoogleFonts.poppins(
                            color: Color(0xFF4C6EF5),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18, color: Color(0xFF4C6EF5)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelectionChip({
    required IconData icon,
    required String label,
    required UserRole role,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFF4C6EF5) : Colors.white,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? Color(0xFF4C6EF5) : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
