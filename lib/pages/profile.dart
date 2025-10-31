
import 'package:digilocal/pages/onlineBookingForSHop.dart';
import 'package:digilocal/pages/shopAnalyticsPage.dart';
import 'package:digilocal/pages/shopListPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digilocal/pages/splash_screen.dart';
import 'package:digilocal/pages/userdatapageforall.dart';
import 'package:digilocal/pages/userinfopageForApp.dart';

import 'SentRequestsPage.dart';
import 'all_chats_page.dart';
import 'allsentandreciverequests.dart';
import 'alluserRequest.dart';
import 'designSelectionPage.dart';
import 'onlineBookingsForCustomer.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseUsers = FirebaseDatabase.instance.ref().child("DigiLocal");
  final DatabaseReference _databaseStudents = FirebaseDatabase.instance.ref().child("users");

  String? email;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? studentData;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _fetchUserData();
    _fetchStudentData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        email = user.email;
      });

      _databaseUsers.orderByChild("shopInfo/Email").equalTo(email).once().then((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            userData = Map<String, dynamic>.from(data.values.first);
          });
        }
        setState(() {
          isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        print("Error fetching user data: $error");
      });
    }
  }

  Future<void> _fetchStudentData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _databaseStudents.orderByChild("email").equalTo(email).once().then((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            studentData = Map<String, dynamic>.from(data.values.first);
          });
        }
      }).catchError((error) {
        print("Error fetching student data: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double paddingValue = screenWidth > 800 ? 80.0 : 24.0;

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () async {
                bool? confirmLogout = await showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Container(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFFEF4444).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.logout, color: Color(0xFFEF4444), size: 32),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Logout Confirmation",
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Are you sure you want to log out?",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text(
                                      "Cancel",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text(
                                      "Logout",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                if (confirmLogout == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SplashScreen()),
                  );
                }
              },
              icon: Icon(Icons.logout, color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingValue, vertical: 24.0),
                  child: Column(
                    children: [
                      // Profile Header
                      studentData == null
                          ? Center(
                              child: Text(
                                "No User data found",
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : Container(
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
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 56,
                                        backgroundImage: studentData!["shopPic"] != null && studentData!["shopPic"].isNotEmpty
                                            ? NetworkImage(studentData!["shopPic"])
                                            : AssetImage("lib/assets/images/finaluser.jpg") as ImageProvider,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "${studentData!["name"]}",
                                    style: GoogleFonts.inter(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "$email",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF6366F1).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.phone, color: Color(0xFF6366F1), size: 20),
                                        ),
                                        SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Contact Number",
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: Color(0xFF64748B),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "${studentData!["contactNo"]}",
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      SizedBox(height: 32),
                      // Quick Actions Section
                      Text(
                        "Quick Actions",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      _buildActionCard(
                        context,
                        icon: Icons.analytics_outlined,
                        title: "Shop Analytics",
                        description: "View your shop performance",
                        gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ShopAnalytics())),
                      ),
                      SizedBox(height: 12),
                      
                      _buildActionCard(
                        context,
                        icon: Icons.shopping_bag_outlined,
                        title: "Online Bookings (Shop)",
                        description: "Manage your shop bookings",
                        gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OnlineBookingsForShop())),
                      ),
                      SizedBox(height: 12),
                      
                      _buildActionCard(
                        context,
                        icon: Icons.bookmark_outline,
                        title: "Online Bookings (Customer)",
                        description: "View your customer bookings",
                        gradient: LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OnlineBookingsForCustomer())),
                      ),
                      SizedBox(height: 12),
                      
                      _buildActionCard(
                        context,
                        icon: Icons.chat_bubble_outline,
                        title: "All Chats",
                        description: "View all conversations",
                        gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AllChats())),
                      ),
                      SizedBox(height: 12),
                      
                      _buildActionCard(
                        context,
                        icon: Icons.inbox_outlined,
                        title: "My Inquiries",
                        description: "Manage sent and received requests",
                        gradient: LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFDB2777)]),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AllSentAndREcivedRequest())),
                      ),
                      SizedBox(height: 24),
                      
                      // Shop Profile Section
                      userData != null
                          ? Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF6366F1).withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => UserDataPageForAll(userData: userData!)),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.storefront, color: Colors.white, size: 20),
                                    SizedBox(width: 12),
                                    Text(
                                      "View Shop Profile",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF0F172A).withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ShopListPage()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_business, color: Colors.white, size: 20),
                                    SizedBox(width: 12),
                                    Text(
                                      "Create Shop Profile",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
