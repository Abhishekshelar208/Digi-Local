import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digilocal/pages/requestPage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AllReviewsPage.dart';
import 'fullscreenimageview.dart';

class UserDataPageForAll extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserDataPageForAll({super.key, required this.userData});

  @override
  State<UserDataPageForAll> createState() => _UserDataPageForAllState();
}

class _UserDataPageForAllState extends State<UserDataPageForAll> with SingleTickerProviderStateMixin {
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = MediaQuery.of(context).size.width;
        bool isMobile = screenWidth < 600;

        return Container(
          height: isMobile ? 110 : 140,
          width: isMobile ? 160 : 190,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: Colors.white.withOpacity(0.9), size: isMobile ? 24 : 28),
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isMobile ? 28 : 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w500,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(
            "$label: ",
            style: GoogleFonts.blinker(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.blinker(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> skills = widget.userData["services"] ?? [];
    List<dynamic> tools = widget.userData["coupons"] ?? [];
    List<dynamic> softSkills = widget.userData["products"] ?? [];
    List<dynamic> achievements = widget.userData["Events"] ?? [];
    List<dynamic> experiences = widget.userData["Offers"] ?? [];
    List<dynamic> projects = widget.userData["Products"] ?? [];

    void launchURL(String url) async {
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

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Shop Details",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Header Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: Column(
                      children: [
                        // Profile Picture with animated border
                        Hero(
                          tag: 'shop_image',
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => FullScreenImageView(
                                  imageUrl: widget.userData["shopInfo"]["shopImage"],
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.white.withOpacity(0.6)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 62,
                                  backgroundImage: NetworkImage(
                                    widget.userData["shopInfo"]["shopImage"],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Operational Status Badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: (widget.userData["operationalStatus"] ?? "Open") == "Open"
                                ? Colors.greenAccent.shade700
                                : (widget.userData["operationalStatus"] ?? "Open") == "Closed"
                                    ? Colors.redAccent.shade700
                                    : Colors.orangeAccent.shade700,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  (widget.userData["operationalStatus"] ?? "Open") == "Open"
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: (widget.userData["operationalStatus"] ?? "Open") == "Open"
                                      ? Colors.green
                                      : Colors.red,
                                  size: 16,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                widget.userData["operationalStatus"] ?? "Open",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if ((widget.userData["closureReason"] ?? "").isNotEmpty) ...[
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              widget.userData["closureReason"],
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        SizedBox(height: 20),

                        // Shop Name with Verification Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                widget.userData["shopInfo"]["shopName"],
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if ((widget.userData["verificationStatus"] ?? "Unverified") == "Verified") ...[
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.verified, color: Colors.blue, size: 22),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 8),
                        // Category
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.userData["subCategory"],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Address Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 5),
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
                                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.location_on, color: Colors.white, size: 24),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Address",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            widget.userData["shopInfo"]["address"],
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),

                    // Stats Grid
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                "Products",
                                "${widget.userData["NoofProducts"]}",
                                Icons.inventory_2,
                                Color(0xFF6C63FF),
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: _buildStatCard(
                                "Shop Timings",
                                "${widget.userData["ShopTimings"]}",
                                Icons.access_time,
                                Color(0xFFFF6B9D),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                "Experience",
                                "${widget.userData["yearsofExperience"]}Y",
                                Icons.workspace_premium,
                                Color(0xFFFFC837),
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: _buildStatCard(
                                "Google Rating",
                                "${widget.userData["googleRating"]}+",
                                Icons.star,
                                Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                "Total Visits",
                                "${widget.userData["totalVisits"] ?? 0}",
                                Icons.people,
                                Color(0xFFFF5722),
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: _buildStatCard(
                                "Avg Rating",
                                "${(widget.userData["averageRating"] ?? 0.0).toStringAsFixed(1)}⭐",
                                Icons.star_rate,
                                Color(0xFF03A9F4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    // Services Section
                    _buildSectionHeader("Services Offered", Icons.room_service),
                    SizedBox(height: 15),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: skills.map<Widget>((skill) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF667eea).withOpacity(0.8), Color(0xFF764ba2).withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF667eea).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            skill.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 25),

                    // Coupons Section
                    if (tools.isNotEmpty) ...[
                      _buildSectionHeader("Available Coupons", Icons.local_offer),
                      SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: tools.map<Widget>((tool) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF6B9D), Color(0xFFFFC837)],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFFF6B9D).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.discount, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  tool.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 25),
                    ],

                    // Products Category Section
                    if (softSkills.isNotEmpty) ...[
                      _buildSectionHeader("Products Category", Icons.category),
                      SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: softSkills.map<Widget>((skill) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Color(0xFF667eea), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              skill.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF667eea),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 25),
                    ],

                    // Products Section
                    if (projects.isNotEmpty) ...[
                      _buildSectionHeader("Our Products", Icons.shopping_bag),
                      SizedBox(height: 15),
                      SizedBox(
                        height: 480,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: projects.length,
                          itemBuilder: (context, index) {
                            var project = projects[index];
                            return Container(
                              width: 300,
                              margin: EdgeInsets.only(right: 16, bottom: 10),
                              child: Card(
                                color: Colors.white,
                                elevation: 8,
                                shadowColor: Colors.black26,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product Image
                                    if (project["image"] != null && project["image"].isNotEmpty)
                                      Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => FullScreenImageView(imageUrl: project["image"]),
                                              );
                                            },
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(25),
                                                topRight: Radius.circular(25),
                                              ),
                                              child: Image.network(
                                                project["image"],
                                                width: double.infinity,
                                                height: 200,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  height: 200,
                                                  color: Colors.grey[200],
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 12,
                                            right: 12,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.7),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.inventory, color: Colors.white, size: 14),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    "${project["itemLeft"] ?? 0} left",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Title
                                            Text(
                                              project["title"] ?? "No Title",
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 8),
                                            // Description
                                            Text(
                                              project["description"] ?? "No Description",
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 12),
                                            // Price Tag
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                "₹ ${project["productprice"] ?? "N/A"}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Spacer(),
                                            // Book Now Button
                                            SizedBox(
                                              width: double.infinity,
                                              child:
                                  // ElevatedButton.icon(
                                  //   onPressed: () {
                                  //     final url = project["purchaseLink"] ?? "";
                                  //     _launchURL(url);
                                  //   },
                                  //   icon: Icon(Icons.code, color: Colors.grey[300]),
                                  //   label: Text(
                                  //     "Book Now",
                                  //     style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[300]),
                                  //   ),
                                  //   style: ElevatedButton.styleFrom(
                                  //     backgroundColor: Colors.black,
                                  //     shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(100),
                                  //     ),
                                  //     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  //   ),
                                  // ),
                                  //whatsapp messaging....
                                  // ElevatedButton.icon(
                                  //   onPressed: () {
                                  //     // Retrieve the shop's WhatsApp number from userData (shopInfo)
                                  //     String shopContact = userData["shopInfo"]["ContactNo"] ?? "";
                                  //     if (shopContact.isEmpty) {
                                  //       print("Shop contact number is not available.");
                                  //       return;
                                  //     }
                                  //
                                  //     // Build the message with product details
                                  //     String message = "I am intrested to buy this, plz book for me\n"
                                  //         "Product Name: ${project["title"] ?? "No Title"}\n"
                                  //         "Price: ${project["productprice"] ?? "No Price"}\n"
                                  //         "Image: ${project["image"] ?? "No Image"}";
                                  //
                                  //     // Construct WhatsApp URL using wa.me API
                                  //     String whatsappUrl = "https://wa.me/$shopContact?text=${Uri.encodeComponent(message)}";
                                  //
                                  //     // Launch WhatsApp with the prepared URL
                                  //     _launchURL(whatsappUrl);
                                  //   },
                                  //   icon: Icon(Icons.code, color: Colors.grey[300]),
                                  //   label: Text(
                                  //     "Book Now",
                                  //     style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[300]),
                                  //   ),
                                  //   style: ElevatedButton.styleFrom(
                                  //     backgroundColor: Colors.black,
                                  //     shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(100),
                                  //     ),
                                  //     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  //   ),
                                  // ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  String shopEmail = widget.userData["shopInfo"]["shopEmail"] ?? "";
                                                  if (shopEmail.isEmpty) {
                                                    if (!context.mounted) return;
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text("Shop email not available")),
                                                    );
                                                    return;
                                                  }

                                                  User? user = FirebaseAuth.instance.currentUser;
                                                  String customerEmail = user?.email ?? "No Email";

                                                  Map<String, dynamic> bookingData = {
                                                    "productName": project["title"] ?? "No Title",
                                                    "productPrice": project["productprice"] ?? "No Price",
                                                    "itemLeft": project["itemLeft"] ?? "No itemLeft",
                                                    "productImage": project["image"] ?? "No Image",
                                                    "shopEmail": shopEmail,
                                                    "customerEmail": customerEmail,
                                                    "timestamp": DateTime.now().toIso8601String(),
                                                  };

                                                  DatabaseReference dbRef = FirebaseDatabase.instance
                                                      .ref()
                                                      .child("online Bookings")
                                                      .push();

                                                  try {
                                                    await dbRef.set(bookingData);
                                                    if (!context.mounted) return;
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Row(
                                                          children: [
                                                            Icon(Icons.check_circle, color: Colors.white),
                                                            SizedBox(width: 12),
                                                            Text("Product Booked Successfully!"),
                                                          ],
                                                        ),
                                                        backgroundColor: Colors.green,
                                                        behavior: SnackBarBehavior.floating,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    );
                                                  } catch (e) {
                                                    if (!context.mounted) return;
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text("Failed to book. Try again."),
                                                        backgroundColor: Colors.red,
                                                        behavior: SnackBarBehavior.floating,
                                                      ),
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(0xFF667eea),
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(vertical: 14),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  elevation: 4,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.shopping_cart, size: 20),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      "Book Now",
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                    ],

                    // Offers Section
                    if (experiences.isNotEmpty) ...[
                      _buildSectionHeader("Offers & Discounts", Icons.local_offer),
                      SizedBox(height: 15),
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: experiences.length,
                          itemBuilder: (context, index) {
                            var experience = experiences[index];
                            return Container(
                              width: 300,
                              margin: EdgeInsets.only(right: 16, bottom: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFFF6B9D), Color(0xFFFFC837)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFFF6B9D).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.local_offer, color: Colors.white, size: 24),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          experience["title"] ?? "No Title",
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    experience["description"] ?? "No Description",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.95),
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                    ],

                    // Shop Features Section
                    if (achievements.isNotEmpty) ...[
                      _buildSectionHeader("Shop Features", Icons.auto_awesome),
                      SizedBox(height: 15),
                      SizedBox(
                        height: 350,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: achievements.length,
                          itemBuilder: (context, index) {
                            var achievement = achievements[index];
                            return Container(
                              width: 300,
                              margin: EdgeInsets.only(right: 16, bottom: 10),
                              child: Card(
                                color: Colors.white,
                                elevation: 8,
                                shadowColor: Colors.black26,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (achievement["image"] != null && achievement["image"].isNotEmpty)
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => FullScreenImageView(
                                              imageUrl: achievement["image"],
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(25),
                                            topRight: Radius.circular(25),
                                          ),
                                          child: Image.network(
                                            achievement["image"],
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              height: 200,
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              achievement["title"] ?? "No Title",
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              achievement["description"] ?? "No Description",
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                    ],

                    // Delivery Information Section
                    if ((widget.userData["deliverySettings"]?["available"] ?? false) == true) ...[
                      _buildSectionHeader("Delivery Information", Icons.delivery_dining),
                      SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            if ((widget.userData["deliverySettings"]?["radius"] ?? "").isNotEmpty)
                              _buildInfoRow(
                                Icons.location_on,
                                "Radius",
                                widget.userData["deliverySettings"]["radius"],
                              ),
                            if ((widget.userData["deliverySettings"]?["minimumOrder"] ?? "").isNotEmpty)
                              _buildInfoRow(
                                Icons.shopping_cart,
                                "Min Order",
                                widget.userData["deliverySettings"]["minimumOrder"],
                              ),
                            if ((widget.userData["deliverySettings"]?["deliveryFee"] ?? "").isNotEmpty)
                              _buildInfoRow(
                                Icons.currency_rupee,
                                "Delivery Fee",
                                widget.userData["deliverySettings"]["deliveryFee"],
                              ),
                            if ((widget.userData["deliverySettings"]?["timings"] ?? "").isNotEmpty)
                              _buildInfoRow(
                                Icons.access_time,
                                "Delivery Time",
                                widget.userData["deliverySettings"]["timings"],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                    ],

                    // Payment Methods Section
                    if ((widget.userData["paymentMethods"] as List?)?.isNotEmpty ?? false) ...[
                      _buildSectionHeader("Accepted Payment Methods", Icons.payment),
                      SizedBox(height: 15),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: (widget.userData["paymentMethods"] as List).map<Widget>((method) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Color(0xFF4CAF50), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4CAF50).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
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
                                    color: Color(0xFF4CAF50),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  method.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 25),
                    ],

                    // Shop Gallery Section
                    if ((widget.userData["shopGallery"] as List?)?.isNotEmpty ?? false) ...[
                      _buildSectionHeader("Shop Gallery", Icons.photo_library),
                      SizedBox(height: 15),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
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
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) => Container(
                                    color: Colors.grey.shade200,
                                    child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 25),
                    ],

                    // Videos Section
                    if ((widget.userData["videos"] as List?)?.isNotEmpty ?? false) ...[
                      _buildSectionHeader("Videos", Icons.play_circle_filled),
                      SizedBox(height: 15),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (widget.userData["videos"] as List).length,
                  itemBuilder: (context, index) {
                    var video = (widget.userData["videos"] as List)[index];
                    return Container(
                      width: 280,
                      margin: EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              launchURL(video["url"] ?? "");
                            },
                        child: Card(
                          color: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.network(
                                      video["thumbnail"] ?? "",
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) => Container(
                                        height: 140,
                                        color: Colors.grey.shade300,
                                        child: Icon(Icons.video_library, size: 48, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 50,
                                    left: 110,
                                    child: Icon(Icons.play_circle_filled, color: Colors.white, size: 60),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  video["title"] ?? "Video",
                                  style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
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
              SizedBox(height: 20),
            ],

                    // FAQs Section
                    if ((widget.userData["faqs"] as List?)?.isNotEmpty ?? false) ...[
                      _buildSectionHeader("Frequently Asked Questions", Icons.help_outline),
                      SizedBox(height: 15),
              for (var entry in (widget.userData["faqs"] as List).asMap().entries)
                Card(
                  color: Colors.white,
                  margin: EdgeInsets.only(bottom: 10),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        "Q${entry.key + 1}",
                        style: GoogleFonts.blinker(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                    title: Text(
                      entry.value["question"] ?? "",
                      style: GoogleFonts.blinker(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            entry.value["answer"] ?? "",
                            style: GoogleFonts.blinker(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 20),
            ],

                    SizedBox(height: 30),

                    // Reviews Section
                    _buildSectionHeader("Customer Reviews", Icons.rate_review),
                    SizedBox(height: 15),
                    
                    // Write Review Button
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 20),
                      child: ElevatedButton.icon(
                        onPressed: () => _showWriteReviewDialog(context),
                        icon: Icon(Icons.edit, size: 20),
                        label: Text(
                          "Write a Review",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),

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
                            padding: EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.reviews_outlined, size: 48, color: Colors.grey[400]),
                                  SizedBox(height: 12),
                                  Text(
                                    "No reviews yet. Be the first to review!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Colors.grey[600],
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
                              margin: EdgeInsets.only(bottom: 16),
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color(0xFF667eea).withOpacity(0.2),
                                        child: Text(
                                          (review["userName"]?.toString().isNotEmpty == true
                                              ? review["userName"][0]
                                              : "U").toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            color: Color(0xFF667eea),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              review["userName"] ?? "Anonymous",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              _formatTimestamp(review["timestamp"]),
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _buildStars(review["rating"]?.toDouble() ?? 0.0),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    review["review"] ?? "",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              );
                            }).toList(),
                            if (hasMoreReviews) ...[
                              SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
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
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Color(0xFF667eea),
                                    side: BorderSide(color: Color(0xFF667eea), width: 2),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 30),

                    // Inquiry Button
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6B9D), Color(0xFFFF5722)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFF6B9D).withOpacity(0.4),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.message, color: Colors.white, size: 24),
                            SizedBox(width: 12),
                            Text(
                              "Make an Inquiry",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
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
          return Icon(Icons.star, color: Colors.amber, size: 18);
        } else if (index < rating && rating % 1 != 0) {
          return Icon(Icons.star_half, color: Colors.amber, size: 18);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: 18);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Write a Review",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667eea),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rate your experience",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1.0;
                        });
                      },
                    );
                  }),
                ),
                SizedBox(height: 20),
                Text(
                  "Write your review",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: reviewController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Share your experience...",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF667eea)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
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
                        borderRadius: BorderRadius.circular(10),
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
                backgroundColor: Color(0xFF667eea),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                "Submit",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
