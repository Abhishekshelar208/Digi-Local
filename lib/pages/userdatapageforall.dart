import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digilocal/pages/requestPage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AllReviewsPage.dart';
import 'fullscreenimageview.dart';
import 'displayServicesGridVise.dart';

class UserDataPageForAll extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserDataPageForAll({super.key, required this.userData});

  @override
  State<UserDataPageForAll> createState() => _UserDataPageForAllState();
}

class _UserDataPageForAllState extends State<UserDataPageForAll> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isFavorite = false;

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
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Color(0xFF64748B),
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorite ? "Added to favorites" : "Removed from favorites"),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: Color(0xFF64748B)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Share functionality"),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingValue, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Welcome Badge
                _buildWelcomeBadge(),
                SizedBox(height: 40),

                // 2. Hero Section with Image and Info
                _buildHeroSection(screenWidth),
                SizedBox(height: 50),

                // 3. Statistics Section
                _buildStatisticsSection(screenWidth),
                SizedBox(height: 50),

                _buildDivider(),

                // 4. Services Section
                SizedBox(height: 30),
                _buildSectionTitle("Services We Offer", screenWidth),
                SizedBox(height: 30),
                ServicesGrid(services: widget.userData["services"]),
                SizedBox(height: 50),

                // 5. Products Category Section
                _buildSectionTitle("Our Products Category", screenWidth),
                SizedBox(height: 30),
                ServicesGrid(services: widget.userData["products"]),
                SizedBox(height: 50),

                // 6. Coupons Section
                if ((widget.userData["coupons"] as List?)?.isNotEmpty ?? false) ...[
                  _buildSectionTitle("🎉 Exclusive Coupons", screenWidth),
                  SizedBox(height: 30),
                  _buildCouponsSection(),
                  SizedBox(height: 50),
                ],

                _buildDivider(),

                // 6.5 Featured Products Section
                if ((widget.userData["Products"] as List?)?.isNotEmpty ?? false) ...[
                  SizedBox(height: 30),
                  _buildSectionTitle("Our Featured Products", screenWidth),
                  SizedBox(height: 30),
                  _buildFeaturedProductsSection(screenWidth),
                  SizedBox(height: 50),
                  _buildDivider(),
                ],

                // 7. Events Section
                if ((widget.userData["Events"] as List?)?.isNotEmpty ?? false) ...[
                  SizedBox(height: 30),
                  _buildSectionTitle("Upcoming Events", screenWidth),
                  SizedBox(height: 30),
                  _buildEventsSection(screenWidth),
                  SizedBox(height: 50),
                ],

                // 8. Offers Section
                if ((widget.userData["Offers"] as List?)?.isNotEmpty ?? false) ...[
                  _buildSectionTitle("Latest Offers & Discounts", screenWidth),
                  SizedBox(height: 30),
                  _buildOffersSection(),
                  SizedBox(height: 50),
                ],

                _buildDivider(),

                // 9. Delivery Section
                if ((widget.userData["deliverySettings"]?["available"] ?? false) == true) ...[
                  SizedBox(height: 30),
                  _buildSectionTitle("Delivery Information", screenWidth),
                  SizedBox(height: 30),
                  _buildDeliverySection(screenWidth),
                  SizedBox(height: 50),
                ],

                // 10. Payment Methods Section
                if ((widget.userData["paymentMethods"] as List?)?.isNotEmpty ?? false) ...[
                  _buildDivider(),
                  SizedBox(height: 30),
                  _buildSectionTitle("Accepted Payment Methods", screenWidth),
                  SizedBox(height: 30),
                  _buildPaymentMethodsSection(),
                  SizedBox(height: 50),
                ],

                // 11. Shop Gallery Section
                if ((widget.userData["shopGallery"] as List?)?.isNotEmpty ?? false) ...[
                  _buildDivider(),
                  SizedBox(height: 30),
                  _buildSectionTitle("Shop Gallery", screenWidth),
                  SizedBox(height: 30),
                  _buildShopGallerySection(screenWidth),
                  SizedBox(height: 50),
                ],

                // 12. Videos Section
                if ((widget.userData["videos"] as List?)?.isNotEmpty ?? false) ...[
                  _buildDivider(),
                  SizedBox(height: 30),
                  _buildSectionTitle("Videos", screenWidth),
                  SizedBox(height: 30),
                  _buildVideosSection(screenWidth),
                  SizedBox(height: 50),
                ],

                // 13. FAQs Section
                if ((widget.userData["faqs"] as List?)?.isNotEmpty ?? false) ...[
                  _buildDivider(),
                  SizedBox(height: 30),
                  _buildSectionTitle("Frequently Asked Questions", screenWidth),
                  SizedBox(height: 30),
                  _buildFAQsSection(),
                  SizedBox(height: 50),
                ],

                // 14. Reviews Section
                _buildDivider(),
                SizedBox(height: 30),
                _buildSectionTitle("Customer Reviews", screenWidth),
                SizedBox(height: 30),
                _buildReviewsSection(),
                SizedBox(height: 50),

                // 15. Footer / Contact Section
                _buildDivider(),
                SizedBox(height: 30),
                _buildFooterSection(),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      // Floating Action Button - Chat with Shop
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
              MaterialPageRoute(
                builder: (context) => RequestPage(
                  userId: widget.userData["accountLinks"]["email"],
                ),
              ),
            );
          },
          icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
          label: Text(
            "Chat",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  // Welcome Badge
  Widget _buildWelcomeBadge() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 1000),
        curve: Curves.elasticOut,
        builder: (context, animValue, child) {
          return Transform.scale(
            scale: animValue,
            child: Container(
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text(
                      "Welcome to ${widget.userData["shopInfo"]["shopName"]} 👋",
                      style: GoogleFonts.inter(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Hero Section
  Widget _buildHeroSection(double screenWidth) {
    bool isMobile = screenWidth < 800;

    if (isMobile) {
      return Column(
        children: [
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
                      return Icon(Icons.store, size: 50, color: Colors.grey);
                    },
                  ),
                ),
              ),
            ),
          SizedBox(height: 20),
          Text(
            "Hi Everyone! I'm",
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.userData["shopInfo"]["shopName"],
            style: GoogleFonts.inter(
              fontSize: 36,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: Color(0xFF64748B), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.userData["shopInfo"]["address"] ?? "No address",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Desktop layout
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 50),
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
                  width: screenWidth * 0.30,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.store, size: 50, color: Colors.grey);
                  },
                ),
              ),
            ),
          ),
        SizedBox(width: 50),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                widget.userData["shopInfo"]["shopName"],
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
                  Icon(Icons.location_on, color: Color(0xFF64748B), size: 20),
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
            ],
          ),
        ),
      ],
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title, double screenWidth) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: screenWidth > 800 ? 48 : 32,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
        );
      },
    );
  }

  // Divider
  Widget _buildDivider() {
    return Container(
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
    );
  }

  // Statistics Section
  Widget _buildStatisticsSection(double screenWidth) {
    bool isMobile = screenWidth < 800;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _buildStatCard("Products", "${widget.userData["NoofProducts"]}+", Icons.inventory_2, isMobile),
        _buildStatCard("Timings", "${widget.userData["ShopTimings"]}", Icons.access_time, isMobile),
        _buildStatCard("Experience", "${widget.userData["yearsofExperience"]}Y", Icons.workspace_premium, isMobile),
        _buildStatCard("Rating", "${widget.userData["googleRating"]}+", Icons.star, isMobile),
        _buildStatCard("Visits", "${widget.userData["totalVisits"] ?? 0}", Icons.people, isMobile),
        _buildStatCard("Avg", "${(widget.userData["averageRating"] ?? 0.0).toStringAsFixed(1)}⭐", Icons.star_rate, isMobile),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, bool isMobile) {
    return Container(
      width: isMobile ? 160 : 180,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Color(0xFF6366F1), size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 28 : 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Coupons Section
  Widget _buildCouponsSection() {
    List<dynamic> coupons = widget.userData["coupons"] ?? [];
    
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: coupons.map<Widget>((coupon) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_offer, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                coupon.toString(),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Featured Products Section
  Widget _buildFeaturedProductsSection(double screenWidth) {
    List<dynamic> products = widget.userData["Products"] ?? [];
    bool isDesktop = screenWidth > 800;

    if (isDesktop) {
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 25,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index], isDesktop);
        },
      );
    } else {
      return SizedBox(
        height: 450,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: products.length,
          itemBuilder: (context, index) {
            return Container(
              width: screenWidth * 0.85,
              margin: EdgeInsets.only(right: 16),
              child: _buildProductCard(products[index], isDesktop),
            );
          },
        ),
      );
    }
  }

  Widget _buildProductCard(dynamic product, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFFAFAFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF64748B).withOpacity(0.12),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            if (product["image"] != null && product["image"].isNotEmpty)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => FullScreenImageView(
                      imageUrl: product["image"],
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    product["image"],
                    width: double.infinity,
                    height: isDesktop ? 280 : 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: isDesktop ? 280 : 200,
                      color: Colors.grey[100],
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 16),
            // Product Title
            Text(
              product["title"] ?? "No Title",
              style: GoogleFonts.inter(
                fontSize: 20,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            // Product Description
            Text(
              product["description"] ?? "No Description",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            Spacer(),
            // Product Price
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${product["productprice"] ?? "No Price"}",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Buy Now Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final url = product["purchaseLink"] ?? "";
                    _launchURL(url);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Buy Now",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Events Section
  Widget _buildEventsSection(double screenWidth) {
    List<dynamic> events = widget.userData["Events"] ?? [];

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        itemBuilder: (context, index) {
          var event = events[index];
          return Container(
            width: screenWidth > 800 ? 350 : 280,
            margin: EdgeInsets.only(right: 20),
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
                if (event["image"] != null && event["image"].isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      event["image"],
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey[100],
                        child: Icon(Icons.event, size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event["title"] ?? "No Title",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        event["description"] ?? "No Description",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Offers Section
  Widget _buildOffersSection() {
    List<dynamic> offers = widget.userData["Offers"] ?? [];

    return Column(
      children: offers.map<Widget>((offer) {
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(20),
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
                  Icon(Icons.local_offer, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      offer["title"] ?? "No Title",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                offer["description"] ?? "No Description",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.95),
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Delivery Section
  Widget _buildDeliverySection(double screenWidth) {
    return Container(
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
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: Color(0xFF6366F1)),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Payment Methods Section
  Widget _buildPaymentMethodsSection() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
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
    );
  }

  // Shop Gallery Section
  Widget _buildShopGallerySection(double screenWidth) {
    return GridView.builder(
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
    );
  }

  // Videos Section
  Widget _buildVideosSection(double screenWidth) {
    return SizedBox(
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
    );
  }

  // FAQs Section
  Widget _buildFAQsSection() {
    return Column(
      children: List.generate((widget.userData["faqs"] as List).length, (index) {
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
    );
  }

  // Reviews Section
  Widget _buildReviewsSection() {
    return StreamBuilder<DatabaseEvent>(
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
            int ratingCompare = (b.value["rating"] ?? 0).compareTo(a.value["rating"] ?? 0);
            if (ratingCompare != 0) return ratingCompare;
            return (b.value["timestamp"] ?? 0).compareTo(a.value["timestamp"] ?? 0);
          });

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
              OutlinedButton.icon(
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
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        );
      },
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

  // Footer Section
  Widget _buildFooterSection() {
    return Container(
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
            "Contact Shop",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.email, color: Color(0xFF6366F1), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.userData["shopInfo"]["shopEmail"],
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.phone, color: Color(0xFF6366F1), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.userData["shopInfo"]["ContactNo"],
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (url.isNotEmpty) {
      Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not launch $url")),
          );
        }
      }
    }
  }
}
