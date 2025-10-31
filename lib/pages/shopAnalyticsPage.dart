import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopAnalytics extends StatefulWidget {
  @override
  _ShopAnalyticsState createState() => _ShopAnalyticsState();
}

class _ShopAnalyticsState extends State<ShopAnalytics> with SingleTickerProviderStateMixin {
  int visitorCount = 0;
  int bookingsCount = 0;
  int offerCount = 0;
  int reviewsCount = 0;
  List<Map<String, dynamic>> offerDetailsList = [];
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;

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
    _loadAllData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _fetchVisitorCount(),
      _loadBookingsCount(),
      _displayOfferCountInCard(),
      _loadOfferDetails(),
    ]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchVisitorCount() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) return;
    
    String userEmail = currentUser.email!;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child("DigiLocal");
    DatabaseEvent event = await dbRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      Map<dynamic, dynamic> shops = snapshot.value as Map<dynamic, dynamic>;
      for (var shopID in shops.keys) {
        var shopData = shops[shopID];
        if (shopData["shopInfo"] != null && shopData["shopInfo"]["shopEmail"] == userEmail) {
          DatabaseReference visitedRef = dbRef.child(shopID).child("StoreVisitedUsersEmails");
          DatabaseEvent visitedEvent = await visitedRef.once();
          DataSnapshot visitedSnapshot = visitedEvent.snapshot;
          if (visitedSnapshot.value != null) {
            setState(() {
              visitorCount = (visitedSnapshot.value as Map<dynamic, dynamic>).length;
            });
          }
          break;
        }
      }
    }
  }

  Future<void> _loadBookingsCount() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) return;
    
    String userEmail = currentUser.email!;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child("online Bookings");
    DatabaseEvent event = await dbRef.once();
    DataSnapshot snapshot = event.snapshot;

    int count = 0;
    if (snapshot.value != null) {
      Map<dynamic, dynamic> bookings = snapshot.value as Map<dynamic, dynamic>;
      bookings.forEach((key, booking) {
        if (booking["shopEmail"] == userEmail) {
          count++;
        }
      });
    }
    setState(() {
      bookingsCount = count;
    });
  }

  Future<void> _displayOfferCountInCard() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) return;
    
    String userEmail = currentUser.email!;
    DatabaseReference offersRef = FirebaseDatabase.instance.ref().child("offers");
    DatabaseEvent event = await offersRef.orderByChild("creator_email").equalTo(userEmail).once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      Map<dynamic, dynamic> offersData = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        offerCount = offersData.length;
      });
    }
  }

  Future<void> _loadOfferDetails() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) return;
    
    String userEmail = currentUser.email!;
    DatabaseReference offersRef = FirebaseDatabase.instance.ref().child("offers");
    DatabaseEvent event = await offersRef.orderByChild("creator_email").equalTo(userEmail).once();
    DataSnapshot snapshot = event.snapshot;

    List<Map<String, dynamic>> offersData = [];
    if (snapshot.exists) {
      Map<dynamic, dynamic> offers = snapshot.value as Map<dynamic, dynamic>;
      offers.forEach((offerID, offerData) {
        String offerName = offerData["name"] ?? "Unnamed Offer";
        Map<dynamic, dynamic>? likedUsersEmail = offerData["LikedUsersEmail"];
        Map<dynamic, dynamic>? dislikeUsersEmail = offerData["DislikeUsersEmail"];
        
        int likedCount = likedUsersEmail?.length ?? 0;
        int dislikeCount = dislikeUsersEmail?.length ?? 0;
        
        offersData.add({
          "name": offerName,
          "likedCount": likedCount,
          "dislikeCount": dislikeCount,
        });
      });
    }
    setState(() {
      offerDetailsList = offersData;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double paddingValue = screenWidth > 800 ? 80.0 : 24.0;
    bool isDesktop = screenWidth > 800;

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
          "Analytics Dashboard",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page Header
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF6366F1).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(Icons.analytics, color: Colors.white, size: 28),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Shop Performance",
                                  style: GoogleFonts.inter(
                                    fontSize: isDesktop ? 32 : 24,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Track your business metrics",
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),

                      // Key Metrics Grid
                      _buildMetricsGrid(isDesktop),
                      SizedBox(height: 32),

                      // Divider
                      Container(
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
                      SizedBox(height: 32),

                      // Offers Performance Section
                      if (offerDetailsList.isNotEmpty) ...[
                        Text(
                          "Offers Performance",
                          style: GoogleFonts.inter(
                            fontSize: isDesktop ? 28 : 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "See how your offers are performing",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 24),
                        _buildOffersSection(isDesktop),
                      ],

                      SizedBox(height: 32),

                      // Quick Actions
                      _buildQuickActions(isDesktop),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildMetricsGrid(bool isDesktop) {
    List<Map<String, dynamic>> metrics = [
      {
        "icon": Icons.visibility_outlined,
        "title": "Total Visitors",
        "value": visitorCount,
        "color": Color(0xFF6366F1),
        "trend": "+12%",
      },
      {
        "icon": Icons.event_available,
        "title": "Online Bookings",
        "value": bookingsCount,
        "color": Color(0xFF10B981),
        "trend": "+8%",
      },
      {
        "icon": Icons.local_offer_outlined,
        "title": "Active Offers",
        "value": offerCount,
        "color": Color(0xFFF59E0B),
        "trend": "+5%",
      },
      {
        "icon": Icons.star_outline,
        "title": "Reviews",
        "value": reviewsCount,
        "color": Color(0xFFEC4899),
        "trend": "N/A",
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.2 : 1.1,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 100)),
          builder: (context, animValue, child) {
            return Opacity(
              opacity: animValue,
              child: Transform.scale(
                scale: 0.8 + (animValue * 0.2),
                child: _buildMetricCard(metrics[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetricCard(Map<String, dynamic> metric) {
    return Container(
      padding: EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: metric["color"].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(metric["icon"], color: metric["color"], size: 20),
              ),
              if (metric["trend"] != "N/A")
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    metric["trend"],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          Flexible(
            child: Text(
              "${metric["value"]}",
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 2),
          Text(
            metric["title"],
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOffersSection(bool isDesktop) {
    return Column(
      children: offerDetailsList.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> offer = entry.value;
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 100)),
          builder: (context, animValue, child) {
            return Opacity(
              opacity: animValue,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - animValue)),
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(20),
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
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.local_offer, color: Colors.white, size: 20),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              offer["name"],
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildOfferStat(
                                Icons.thumb_up_outlined,
                                "Likes",
                                offer["likedCount"],
                                Color(0xFF10B981),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Color(0xFFE2E8F0),
                            ),
                            Expanded(
                              child: _buildOfferStat(
                                Icons.thumb_down_outlined,
                                "Dislikes",
                                offer["dislikeCount"],
                                Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildOfferStat(IconData icon, String label, int value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 8),
            Text(
              "$value",
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                "Quick Actions",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton("Create Offer", Icons.add_circle_outline),
              _buildActionButton("View Bookings", Icons.event_note),
              _buildActionButton("Check Reviews", Icons.star_border),
              _buildActionButton("Export Data", Icons.download),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
