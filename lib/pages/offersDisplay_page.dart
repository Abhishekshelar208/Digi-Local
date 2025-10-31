import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'create_offers.dart';

String formatDeadline(String dateString) {
  try {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('d MMM y').format(date);
  } catch (e) {
    return dateString;
  }
}

class OfferListPage extends StatefulWidget {
  @override
  _OfferListPageState createState() => _OfferListPageState();
}

class _OfferListPageState extends State<OfferListPage> with SingleTickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child("offers");
  List<Map<String, dynamic>> offers = [];
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
    _fetchChallenges();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchChallenges() async {
    _database.onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> challengesData = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          offers = challengesData.entries.map((entry) {
            final likedData = entry.value["LikedUsersEmail"] as Map<dynamic, dynamic>?;
            final dislikeData = entry.value["DislikeUsersEmail"] as Map<dynamic, dynamic>?;

            return {
              "id": entry.key,
              "name": entry.value["name"],
              "description": entry.value["description"],
              "coupon": entry.value["coupon"],
              "deadline": entry.value["deadline"],
              "creator": entry.value["creator"],
              "likedEmails": likedData ?? {},
              "dislikedEmails": dislikeData ?? {},
              "likeCount": likedData != null ? likedData.length : 0,
              "dislikeCount": dislikeData != null ? dislikeData.length : 0,
            };
          }).toList();
        });
      }
    });
  }

  Future<void> _updateReaction(String offerId, String reactionType) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      String email = user.email!;
      String node = reactionType == "like" ? "LikedUsersEmail" : "DislikeUsersEmail";
      DatabaseReference reactionRef = FirebaseDatabase.instance.ref().child("offers").child(offerId).child(node);

      await reactionRef.push().set(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Your $reactionType has been recorded."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please log in to react to this offer."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
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
          "Discounts & Offers",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingValue, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Latest Offers",
                style: GoogleFonts.inter(
                  fontSize: screenWidth > 800 ? 36 : 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Discover amazing deals and discounts from local shops",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 24),

              // Offers List
              Expanded(
                child: offers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey[300]),
                            SizedBox(height: 16),
                            Text(
                              "No offers available yet",
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          var offer = offers[index];
                          bool isLiked = currentUserEmail != null && offer["likedEmails"].values.contains(currentUserEmail);
                          bool isDisliked = currentUserEmail != null && offer["dislikedEmails"].values.contains(currentUserEmail);

                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 600 + (index * 100)),
                              builder: (context, animValue, child) {
                                return Opacity(
                                  opacity: animValue,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - animValue)),
                                    child: _buildOfferCard(offer, isLiked, isDisliked, screenWidth),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateOffersPage()),
            );
          },
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            "Create Offer",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer, bool isLiked, bool isDisliked, double screenWidth) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OffersDetailPage(
                  challengeId: offer["id"],
                  challenge: offer,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_offer, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            "Special Offer",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Offer Title
                Text(
                  offer["name"],
                  style: GoogleFonts.inter(
                    fontSize: screenWidth > 800 ? 28 : 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),

                // Shop Name
                Row(
                  children: [
                    Icon(Icons.store, color: Colors.white.withOpacity(0.9), size: 16),
                    SizedBox(width: 8),
                    Text(
                      offer["creator"],
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Deadline
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.9), size: 16),
                    SizedBox(width: 8),
                    Text(
                      "Valid until ${formatDeadline(offer["deadline"])}",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Reactions Row
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Like Button
                      InkWell(
                        onTap: () => _updateReaction(offer["id"], "like"),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "${offer["likeCount"]}",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 24),
                      // Dislike Button
                      InkWell(
                        onTap: () => _updateReaction(offer["id"], "dislike"),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "${offer["dislikeCount"]}",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

// Offers Detail Page
class OffersDetailPage extends StatefulWidget {
  final String challengeId;
  final Map<String, dynamic> challenge;

  OffersDetailPage({required this.challengeId, required this.challenge});

  @override
  _OffersDetailPageState createState() => _OffersDetailPageState();
}

class _OffersDetailPageState extends State<OffersDetailPage> with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          "Offer Details",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingValue, vertical: 40.0),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Offer Header Card
                    Container(
                      padding: EdgeInsets.all(32),
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
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.local_offer, color: Colors.white, size: 28),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  widget.challenge["name"],
                                  style: GoogleFonts.inter(
                                    fontSize: screenWidth > 800 ? 32 : 26,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          _buildInfoRow(Icons.store, "Shop", widget.challenge["creator"]),
                          SizedBox(height: 12),
                          _buildInfoRow(Icons.calendar_today, "Valid Until", formatDeadline(widget.challenge["deadline"])),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Description Card
                    Container(
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
                          Text(
                            "About This Offer",
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            widget.challenge["description"],
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Coupon Code Card
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Color(0xFF6366F1), width: 2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.confirmation_number, color: Color(0xFF6366F1), size: 24),
                              SizedBox(width: 12),
                              Text(
                                "Coupon Code",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFF6366F1), width: 2, style: BorderStyle.solid),
                            ),
                            child: Center(
                              child: Text(
                                widget.challenge["coupon"],
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF6366F1),
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Use this code at checkout to avail the offer",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 18),
        SizedBox(width: 12),
        Text(
          "$label: ",
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
