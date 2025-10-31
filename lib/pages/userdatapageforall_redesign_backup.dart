// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:digilocal/pages/requestPage.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import 'AllReviewsPage.dart';
// import 'fullscreenimageview.dart';
// import 'displayServicesGridVise.dart';
//
// class UserDataPageForAll extends StatefulWidget {
//   final Map<String, dynamic> userData;
//
//   const UserDataPageForAll({super.key, required this.userData});
//
//   @override
//   State<UserDataPageForAll> createState() => _UserDataPageForAllState();
// }
//
// class _UserDataPageForAllState extends State<UserDataPageForAll> with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   bool _isFavorite = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 800),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double paddingValue = screenWidth > 800 ? 80.0 : 24.0;
//
//     return Scaffold(
//       backgroundColor: Color(0xFFF8FAFC),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(
//               _isFavorite ? Icons.favorite : Icons.favorite_border,
//               color: _isFavorite ? Colors.red : Color(0xFF64748B),
//             ),
//             onPressed: () {
//               setState(() {
//                 _isFavorite = !_isFavorite;
//               });
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(_isFavorite ? "Added to favorites" : "Removed from favorites"),
//                   duration: Duration(seconds: 1),
//                   behavior: SnackBarBehavior.floating,
//                 ),
//               );
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.share, color: Color(0xFF64748B)),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text("Share functionality"),
//                   duration: Duration(seconds: 1),
//                   behavior: SnackBarBehavior.floating,
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: paddingValue, vertical: 24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 1. Welcome Badge
//                 _buildWelcomeBadge(),
//                 SizedBox(height: 40),
//
//                 // 2. Hero Section with Image and Info
//                 _buildHeroSection(screenWidth),
//                 SizedBox(height: 50),
//
//                 // 3. Statistics Section
//                 _buildStatisticsSection(screenWidth),
//                 SizedBox(height: 50),
//
//                 _buildDivider(),
//
//                 // 4. Services Section
//                 SizedBox(height: 30),
//                 _buildSectionTitle("Services We Offer", screenWidth),
//                 SizedBox(height: 30),
//                 ServicesGrid(services: widget.userData["services"]),
//                 SizedBox(height: 50),
//
//                 // 5. Products Category Section
//                 _buildSectionTitle("Our Products Category", screenWidth),
//                 SizedBox(height: 30),
//                 ServicesGrid(services: widget.userData["products"]),
//                 SizedBox(height: 50),
//
//                 // 6. Coupons Section
//                 if ((widget.userData["coupons"] as List?)?.isNotEmpty ?? false) ...[
//                   _buildSectionTitle("🎉 Exclusive Coupons", screenWidth),
//                   SizedBox(height: 30),
//                   _buildCouponsSection(),
//                   SizedBox(height: 50),
//                 ],
//
//                 _buildDivider(),
//
//                 // 7. Events Section
//                 if ((widget.userData["Events"] as List?)?.isNotEmpty ?? false) ...[
//                   SizedBox(height: 30),
//                   _buildSectionTitle("Upcoming Events", screenWidth),
//                   SizedBox(height: 30),
//                   _buildEventsSection(screenWidth),
//                   SizedBox(height: 50),
//                 ],
//
//                 // 8. Offers Section
//                 if ((widget.userData["Offers"] as List?)?.isNotEmpty ?? false) ...[
//                   _buildSectionTitle("Latest Offers & Discounts", screenWidth),
//                   SizedBox(height: 30),
//                   _buildOffersSection(),
//                   SizedBox(height: 50),
//                 ],
//
//                 _buildDivider(),
//
//                 // 9. Delivery Section
//                 if ((widget.userData["deliverySettings"]?["available"] ?? false) == true) ...[
//                   SizedBox(height: 30),
//                   _buildSectionTitle("Delivery Information", screenWidth),
//                   SizedBox(height: 30),
//                   _buildDeliverySection(screenWidth),
//                   SizedBox(height: 50),
//                 ],
//
//                 // 10. Payment Methods Section
//                 if ((widget.userData["paymentMethods"] as List?)?.isNotEmpty ?? false) ...[
//                   _buildDivider(),
//                   SizedBox(height: 30),
//                   _buildSectionTitle("Accepted Payment Methods", screenWidth),
//                   SizedBox(height: 30),
//                   _buildPaymentMethodsSection(),
//                   SizedBox(height: 50),
//                 ],
//
//                 // 11. Shop Gallery Section
//                 if ((widget.userData["shopGallery"] as List?)?.isNotEmpty ?? false) ...[
//                   _buildDivider(),
//                   SizedBox(height: 30),
//                   _buildSectionTitle("Shop Gallery", screenWidth),
//                   SizedBox(height: 30),
//                   _buildShopGallerySection(screenWidth),
//                   SizedBox(height: 50),
//                 ],
//
//                 // 12. Videos Section
//                 if ((widget.userData["videos"] as List?)?.isNotEmpty ?? false) ...[
//                   _buildDivider(),
//                   SizedBox(height: 30),
//                   _buildSectionTitle("Videos", screenWidth),
//                   SizedBox(height: 30),
//                   _buildVideosSection(screenWidth),
//                   SizedBox(height: 50),
//                 ],
//
//                 // 13. FAQs Section
//                 if ((widget.userData["faqs"] as List?)?.isNotEmpty ?? false) ...[
//                   _buildDivider(),
//                   SizedBox(height: 30),
//                   _buildSectionTitle("Frequently Asked Questions", screenWidth),
//                   SizedBox(height: 30),
//                   _buildFAQsSection(),
//                   SizedBox(height: 50),
//                 ],
//
//                 // 14. Reviews Section
//                 _buildDivider(),
//                 SizedBox(height: 30),
//                 _buildSectionTitle("Customer Reviews", screenWidth),
//                 SizedBox(height: 30),
//                 _buildReviewsSection(),
//                 SizedBox(height: 50),
//
//                 // 15. Footer / Contact Section
//                 _buildDivider(),
//                 SizedBox(height: 30),
//                 _buildFooterSection(),
//                 SizedBox(height: 100),
//               ],
//             ),
//           ),
//         ),
//       ),
//       // Floating Action Button - Chat with Shop
//       floatingActionButton: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//           ),
//           borderRadius: BorderRadius.circular(50),
//           boxShadow: [
//             BoxShadow(
//               color: Color(0xFF6366F1).withOpacity(0.4),
//               blurRadius: 20,
//               offset: Offset(0, 8),
//             ),
//           ],
//         ),
//         child: FloatingActionButton.extended(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => RequestPage(
//                   userId: widget.userData["accountLinks"]["email"],
//                 ),
//               ),
//             );
//           },
//           icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
//           label: Text(
//             "Chat",
//             style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
//           ),
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//         ),
//       ),
//     );
//   }
//
//   // Welcome Badge
//   Widget _buildWelcomeBadge() {
//     return Center(
//       child: TweenAnimationBuilder<double>(
//         tween: Tween(begin: 0.0, end: 1.0),
//         duration: Duration(milliseconds: 1000),
//         curve: Curves.elasticOut,
//         builder: (context, animValue, child) {
//           return Transform.scale(
//             scale: animValue,
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                 ),
//                 borderRadius: BorderRadius.circular(50),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Color(0xFF6366F1).withOpacity(0.4),
//                     blurRadius: 20,
//                     offset: Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
//                     SizedBox(width: 12),
//                     Text(
//                       "Welcome to ${widget.userData["shopInfo"]["shopName"]} 👋",
//                       style: GoogleFonts.inter(
//                         fontSize: 16.0,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // Hero Section
//   Widget _buildHeroSection(double screenWidth) {
//     bool isMobile = screenWidth < 800;
//
//     if (isMobile) {
//       return Column(
//         children: [
//           if (widget.userData["shopInfo"]["shopImage"].isNotEmpty)
//             GestureDetector(
//               onTap: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => FullScreenImageView(
//                     imageUrl: widget.userData["shopInfo"]["shopImage"],
//                   ),
//                 );
//               },
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(24),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Color(0xFF64748B).withOpacity(0.15),
//                       blurRadius: 30,
//                       offset: Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(24),
//                   child: Image.network(
//                     widget.userData["shopInfo"]["shopImage"],
//                     height: 300,
//                     width: 250,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Icon(Icons.store, size: 50, color: Colors.grey);
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           SizedBox(height: 20),
//           Text(
//             "Hi Everyone! I'm",
//             style: GoogleFonts.inter(
//               fontSize: 18,
//               color: Color(0xFF6366F1),
//               fontWeight: FontWeight.w600,
//               letterSpacing: 1.5,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             widget.userData["shopInfo"]["shopName"],
//             style: GoogleFonts.inter(
//               fontSize: 36,
//               color: Color(0xFF0F172A),
//               fontWeight: FontWeight.w900,
//               letterSpacing: -1,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.location_on, color: Color(0xFF64748B), size: 18),
//               SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   widget.userData["shopInfo"]["address"] ?? "No address",
//                   style: GoogleFonts.inter(
//                     fontSize: 16,
//                     color: Color(0xFF64748B),
//                     fontWeight: FontWeight.w500,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       );
//     }
//
//     // Desktop layout
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(width: 50),
//         if (widget.userData["shopInfo"]["shopImage"].isNotEmpty)
//           GestureDetector(
//             onTap: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => FullScreenImageView(
//                   imageUrl: widget.userData["shopInfo"]["shopImage"],
//                 ),
//               );
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Color(0xFF64748B).withOpacity(0.15),
//                     blurRadius: 30,
//                     offset: Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(24),
//                 child: Image.network(
//                   widget.userData["shopInfo"]["shopImage"],
//                   height: 550,
//                   width: screenWidth * 0.30,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Icon(Icons.store, size: 50, color: Colors.grey);
//                   },
//                 ),
//               ),
//             ),
//           ),
//         SizedBox(width: 50),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 20),
//               Text(
//                 "Welcome to",
//                 style: GoogleFonts.inter(
//                   fontSize: 20,
//                   color: Color(0xFF6366F1),
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: 2,
//                 ),
//               ),
//               SizedBox(height: 12),
//               Text(
//                 widget.userData["shopInfo"]["shopName"],
//                 style: GoogleFonts.inter(
//                   fontSize: 48,
//                   color: Color(0xFF0F172A),
//                   fontWeight: FontWeight.w900,
//                   letterSpacing: -1,
//                 ),
//               ),
//               SizedBox(height: 20),
//               Row(
//                 children: [
//                   Icon(Icons.location_on, color: Color(0xFF64748B), size: 20),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       widget.userData["shopInfo"]["address"] ?? "No address",
//                       style: GoogleFonts.inter(
//                         fontSize: 18,
//                         color: Color(0xFF64748B),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Section Title
//   Widget _buildSectionTitle(String title, double screenWidth) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0.0, end: 1.0),
//       duration: Duration(milliseconds: 600),
//       builder: (context, animValue, child) {
//         return Opacity(
//           opacity: animValue,
//           child: Text(
//             title,
//             style: GoogleFonts.inter(
//               fontSize: screenWidth > 800 ? 48 : 32,
//               color: Color(0xFF0F172A),
//               fontWeight: FontWeight.w900,
//               letterSpacing: -1,
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // Divider
//   Widget _buildDivider() {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 20),
//       height: 1,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.transparent,
//             Color(0xFFE2E8F0),
//             Colors.transparent,
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Statistics Section
//   Widget _buildStatisticsSection(double screenWidth) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Shop Statistics",
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF1F2937),
//           ),
//         ),
//         SizedBox(height: 16),
//         GridView.count(
//           crossAxisCount: 2,
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           crossAxisSpacing: 12,
//           mainAxisSpacing: 12,
//           childAspectRatio: 1.3,
//           children: [
//             _buildStatCard(
//               "Products",
//               "${widget.userData["NoofProducts"]}",
//               Icons.inventory_2,
//               Color(0xFF4C6EF5),
//             ),
//             _buildStatCard(
//               "Shop Timings",
//               "${widget.userData["ShopTimings"]}",
//               Icons.access_time,
//               Color(0xFF10B981),
//             ),
//             _buildStatCard(
//               "Experience",
//               "${widget.userData["yearsofExperience"]}Y",
//               Icons.workspace_premium,
//               Color(0xFFF59E0B),
//             ),
//             _buildStatCard(
//               "Avg Rating",
//               "${(widget.userData["averageRating"] ?? 0.0).toStringAsFixed(1)}⭐",
//               Icons.star_rate,
//               Color(0xFFEF4444),
//             ),
//             _buildStatCard(
//               "Total Visits",
//               "${widget.userData["totalVisits"] ?? 0}",
//               Icons.people,
//               Color(0xFF8B5CF6),
//             ),
//             _buildStatCard(
//               "Google Rating",
//               "${widget.userData["googleRating"]}",
//               Icons.star,
//               Color(0xFFEC4899),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 24),
//           ),
//           SizedBox(height: 12),
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF1F2937),
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           SizedBox(height: 4),
//           Text(
//             title,
//             style: GoogleFonts.poppins(
//               fontSize: 12,
//               color: Color(0xFF6B7280),
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 🟧 4. Categories & Features Section with Tabs
//   Widget _buildCategoriesTabSection() {
//     List<dynamic> services = widget.userData["services"] ?? [];
//     List<dynamic> coupons = widget.userData["coupons"] ?? [];
//     List<dynamic> products = widget.userData["products"] ?? [];
//     List<dynamic> events = widget.userData["Events"] ?? [];
//     List<dynamic> offers = widget.userData["Offers"] ?? [];
//
//     return Container(
//       color: Colors.white,
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: Text(
//               "Shop Offerings",
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1F2937),
//               ),
//             ),
//           ),
//           TabBar(
//             controller: _tabController,
//             isScrollable: true,
//             labelColor: Color(0xFF4C6EF5),
//             unselectedLabelColor: Color(0xFF6B7280),
//             indicatorColor: Color(0xFF4C6EF5),
//             labelStyle: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//             unselectedLabelStyle: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//             tabs: [
//               Tab(text: "Services (${services.length})"),
//               Tab(text: "Coupons (${coupons.length})"),
//               Tab(text: "Category (${products.length})"),
//               Tab(text: "Events (${events.length})"),
//               Tab(text: "Offers (${offers.length})"),
//             ],
//           ),
//           Container(
//             height: 300,
//             padding: EdgeInsets.all(16),
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildServicesTab(services),
//                 _buildCouponsTab(coupons),
//                 _buildProductCategoryTab(products),
//                 _buildEventsTab(events),
//                 _buildOffersTab(offers),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildServicesTab(List<dynamic> services) {
//     if (services.isEmpty) {
//       return Center(
//         child: Text(
//           "No services available",
//           style: GoogleFonts.poppins(color: Colors.grey),
//         ),
//       );
//     }
//     return ListView.builder(
//       itemCount: services.length,
//       itemBuilder: (context, index) {
//         return Container(
//           margin: EdgeInsets.only(bottom: 12),
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF667eea).withOpacity(0.8), Color(0xFF764ba2).withOpacity(0.8)],
//             ),
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Color(0xFF667eea).withOpacity(0.3),
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.room_service, color: Colors.white, size: 24),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   services[index].toString(),
//                   style: GoogleFonts.poppins(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildCouponsTab(List<dynamic> coupons) {
//     if (coupons.isEmpty) {
//       return Center(
//         child: Text(
//           "No coupons available",
//           style: GoogleFonts.poppins(color: Colors.grey),
//         ),
//       );
//     }
//     return ListView.builder(
//       itemCount: coupons.length,
//       itemBuilder: (context, index) {
//         return Container(
//           margin: EdgeInsets.only(bottom: 12),
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFFFF6B9D), Color(0xFFFFC837)],
//             ),
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Color(0xFFFF6B9D).withOpacity(0.3),
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.local_offer, color: Colors.white, size: 24),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   coupons[index].toString(),
//                   style: GoogleFonts.poppins(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildProductCategoryTab(List<dynamic> products) {
//     if (products.isEmpty) {
//       return Center(
//         child: Text(
//           "No product categories available",
//           style: GoogleFonts.poppins(color: Colors.grey),
//         ),
//       );
//     }
//     return Wrap(
//       spacing: 10,
//       runSpacing: 10,
//       children: products.map<Widget>((product) {
//         return Container(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: Color(0xFF667eea), width: 2),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Text(
//             product.toString(),
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF667eea),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildEventsTab(List<dynamic> events) {
//     if (events.isEmpty) {
//       return Center(
//         child: Text(
//           "No events available",
//           style: GoogleFonts.poppins(color: Colors.grey),
//         ),
//       );
//     }
//     return ListView.builder(
//       scrollDirection: Axis.horizontal,
//       itemCount: events.length,
//       itemBuilder: (context, index) {
//         var event = events[index];
//         return Container(
//           width: 250,
//           margin: EdgeInsets.only(right: 12),
//           child: Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (event["image"] != null && event["image"].isNotEmpty)
//                   ClipRRect(
//                     borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//                     child: Image.network(
//                       event["image"],
//                       height: 140,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => Container(
//                         height: 140,
//                         color: Colors.grey[200],
//                         child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
//                       ),
//                     ),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         event["title"] ?? "No Title",
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         event["description"] ?? "No Description",
//                         style: GoogleFonts.poppins(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildOffersTab(List<dynamic> offers) {
//     if (offers.isEmpty) {
//       return Center(
//         child: Text(
//           "No offers available",
//           style: GoogleFonts.poppins(color: Colors.grey),
//         ),
//       );
//     }
//     return ListView.builder(
//       itemCount: offers.length,
//       itemBuilder: (context, index) {
//         var offer = offers[index];
//         return Container(
//           margin: EdgeInsets.only(bottom: 12),
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFFFF6B9D), Color(0xFFFFC837)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Color(0xFFFF6B9D).withOpacity(0.3),
//                 blurRadius: 12,
//                 offset: Offset(0, 6),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.local_offer, color: Colors.white, size: 24),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       offer["title"] ?? "No Title",
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 8),
//               Text(
//                 offer["description"] ?? "No Description",
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   color: Colors.white.withOpacity(0.95),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // 🟪 5. Delivery Section
//   Widget _buildDeliverySection() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.delivery_dining, color: Color(0xFF4C6EF5), size: 24),
//               SizedBox(width: 12),
//               Text(
//                 "Delivery Information",
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1F2937),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           if ((widget.userData["deliverySettings"]?["radius"] ?? "").isNotEmpty)
//             _buildInfoRow(Icons.location_on, "Radius", widget.userData["deliverySettings"]["radius"]),
//           if ((widget.userData["deliverySettings"]?["minimumOrder"] ?? "").isNotEmpty)
//             _buildInfoRow(Icons.shopping_cart, "Min Order", widget.userData["deliverySettings"]["minimumOrder"]),
//           if ((widget.userData["deliverySettings"]?["deliveryFee"] ?? "").isNotEmpty)
//             _buildInfoRow(Icons.currency_rupee, "Delivery Fee", widget.userData["deliverySettings"]["deliveryFee"]),
//           if ((widget.userData["deliverySettings"]?["timings"] ?? "").isNotEmpty)
//             _buildInfoRow(Icons.access_time, "Delivery Time", widget.userData["deliverySettings"]["timings"]),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: Color(0xFF4C6EF5)),
//           SizedBox(width: 12),
//           Text(
//             "$label: ",
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF1F2937),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 color: Color(0xFF6B7280),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Payment Methods Section
//   Widget _buildPaymentMethodsSection() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.payment, color: Color(0xFF4C6EF5), size: 24),
//               SizedBox(width: 12),
//               Text(
//                 "Accepted Payment Methods",
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1F2937),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           Wrap(
//             spacing: 10,
//             runSpacing: 10,
//             children: (widget.userData["paymentMethods"] as List).map<Widget>((method) {
//               return Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Color(0xFF4CAF50), width: 2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 8,
//                       offset: Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       method.toString().contains("UPI")
//                           ? Icons.qr_code
//                           : method.toString().contains("Card")
//                               ? Icons.credit_card
//                               : method.toString().contains("Cash")
//                                   ? Icons.money
//                                   : Icons.payment,
//                       color: Color(0xFF4CAF50),
//                       size: 20,
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       method.toString(),
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Shop Gallery Section
//   Widget _buildShopGallerySection() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.photo_library, color: Color(0xFF4C6EF5), size: 24),
//               SizedBox(width: 12),
//               Text(
//                 "Shop Gallery",
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1F2937),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//               childAspectRatio: 1,
//             ),
//             itemCount: (widget.userData["shopGallery"] as List).length,
//             itemBuilder: (context, index) {
//               String imageUrl = (widget.userData["shopGallery"] as List)[index];
//               return GestureDetector(
//                 onTap: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => FullScreenImageView(imageUrl: imageUrl),
//                   );
//                 },
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.network(
//                     imageUrl,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stack) => Container(
//                       color: Colors.grey.shade200,
//                       child: Icon(Icons.broken_image, size: 32, color: Colors.grey),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Videos Section
//   Widget _buildVideosSection() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.play_circle_filled, color: Color(0xFF4C6EF5), size: 24),
//               SizedBox(width: 12),
//               Text(
//                 "Videos",
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1F2937),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           SizedBox(
//             height: 200,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: (widget.userData["videos"] as List).length,
//               itemBuilder: (context, index) {
//                 var video = (widget.userData["videos"] as List)[index];
//                 return Container(
//                   width: 280,
//                   margin: EdgeInsets.only(right: 12),
//                   child: GestureDetector(
//                     onTap: () {
//                       _launchURL(video["url"] ?? "");
//                     },
//                     child: Card(
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Stack(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//                                 child: Image.network(
//                                   video["thumbnail"] ?? "",
//                                   height: 140,
//                                   width: double.infinity,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stack) => Container(
//                                     height: 140,
//                                     color: Colors.grey.shade300,
//                                     child: Icon(Icons.video_library, size: 48, color: Colors.grey),
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 50,
//                                 left: 110,
//                                 child: Icon(Icons.play_circle_filled, color: Colors.white, size: 60),
//                               ),
//                             ],
//                           ),
//                           Padding(
//                             padding: EdgeInsets.all(12),
//                             child: Text(
//                               video["title"] ?? "Video",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 🟫 6. FAQs Section
//   Widget _buildFAQsSection() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.help_outline, color: Color(0xFF4C6EF5), size: 24),
//               SizedBox(width: 12),
//               Text(
//                 "Frequently Asked Questions",
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1F2937),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           ...List.generate(
//             (widget.userData["faqs"] as List).length,
//             (index) {
//               var faq = (widget.userData["faqs"] as List)[index];
//               return Card(
//                 margin: EdgeInsets.only(bottom: 10),
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   side: BorderSide(color: Colors.grey.shade200),
//                 ),
//                 child: ExpansionTile(
//                   leading: CircleAvatar(
//                     backgroundColor: Colors.blue.shade100,
//                     child: Text(
//                       "Q${index + 1}",
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue.shade900,
//                       ),
//                     ),
//                   ),
//                   title: Text(
//                     faq["question"] ?? "",
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black,
//                     ),
//                   ),
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           faq["answer"] ?? "",
//                           style: GoogleFonts.poppins(
//                             fontSize: 13,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ⚪ 7. Reviews Section
//   Widget _buildReviewsSection() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.rate_review, color: Color(0xFF4C6EF5), size: 24),
//               SizedBox(width: 12),
//               Text(
//                 "Customer Reviews",
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1F2937),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: () => _showWriteReviewDialog(context),
//               icon: Icon(Icons.edit, size: 20),
//               label: Text(
//                 "Write a Review",
//                 style: GoogleFonts.poppins(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: Color(0xFF4C6EF5),
//                 side: BorderSide(color: Color(0xFF4C6EF5), width: 2),
//                 padding: EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           StreamBuilder<DatabaseEvent>(
//             stream: FirebaseDatabase.instance
//                 .ref("reviews/${widget.userData["accountLinks"]["email"].toString().replaceAll('.', '_')}")
//                 .onValue,
//             builder: (context, snapshot) {
//               if (snapshot.hasError) {
//                 return Center(child: Text("Error loading reviews"));
//               }
//
//               if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
//                 return Container(
//                   padding: EdgeInsets.all(30),
//                   child: Center(
//                     child: Column(
//                       children: [
//                         Icon(Icons.reviews_outlined, size: 48, color: Colors.grey[400]),
//                         SizedBox(height: 12),
//                         Text(
//                           "No reviews yet. Be the first to review!",
//                           style: GoogleFonts.poppins(
//                             fontSize: 14,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }
//
//               Map<dynamic, dynamic> reviewsMap = snapshot.data!.snapshot.value as Map;
//               List<MapEntry> reviewsList = reviewsMap.entries.toList()
//                 ..sort((a, b) {
//                   int ratingCompare = (b.value["rating"] ?? 0).compareTo(a.value["rating"] ?? 0);
//                   if (ratingCompare != 0) return ratingCompare;
//                   return (b.value["timestamp"] ?? 0).compareTo(a.value["timestamp"] ?? 0);
//                 });
//
//               List<MapEntry> displayedReviews = reviewsList.take(2).toList();
//               bool hasMoreReviews = reviewsList.length > 2;
//
//               return Column(
//                 children: [
//                   ...displayedReviews.map((entry) {
//                     var review = entry.value;
//                     return Container(
//                       margin: EdgeInsets.only(bottom: 16),
//                       padding: EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade200),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               CircleAvatar(
//                                 backgroundColor: Color(0xFF667eea).withOpacity(0.2),
//                                 child: Text(
//                                   (review["userName"]?.toString().isNotEmpty == true
//                                           ? review["userName"][0]
//                                           : "U")
//                                       .toUpperCase(),
//                                   style: GoogleFonts.poppins(
//                                     color: Color(0xFF667eea),
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       review["userName"] ?? "Anonymous",
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                     Text(
//                                       _formatTimestamp(review["timestamp"]),
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 12,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               _buildStars(review["rating"]?.toDouble() ?? 0.0),
//                             ],
//                           ),
//                           SizedBox(height: 12),
//                           Text(
//                             review["review"] ?? "",
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               color: Colors.grey[700],
//                               height: 1.5,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                   if (hasMoreReviews) ...[
//                     SizedBox(height: 16),
//                     SizedBox(
//                       width: double.infinity,
//                       child: OutlinedButton.icon(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => AllReviewsPage(
//                                 shopEmail: widget.userData["accountLinks"]["email"],
//                                 shopName: widget.userData["shopInfo"]["shopName"],
//                               ),
//                             ),
//                           );
//                         },
//                         icon: Icon(Icons.arrow_forward, size: 20),
//                         label: Text(
//                           "See All Reviews (${reviewsList.length})",
//                           style: GoogleFonts.poppins(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Color(0xFF667eea),
//                           side: BorderSide(color: Color(0xFF667eea), width: 2),
//                           padding: EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStars(double rating) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: List.generate(5, (index) {
//         if (index < rating.floor()) {
//           return Icon(Icons.star, color: Colors.amber, size: 16);
//         } else if (index < rating && rating % 1 != 0) {
//           return Icon(Icons.star_half, color: Colors.amber, size: 16);
//         } else {
//           return Icon(Icons.star_border, color: Colors.amber, size: 16);
//         }
//       }),
//     );
//   }
//
//   String _formatTimestamp(dynamic timestamp) {
//     if (timestamp == null) return "Just now";
//     try {
//       DateTime dateTime = DateTime.parse(timestamp.toString());
//       Duration difference = DateTime.now().difference(dateTime);
//
//       if (difference.inDays > 365) {
//         return "${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago";
//       } else if (difference.inDays > 30) {
//         return "${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago";
//       } else if (difference.inDays > 0) {
//         return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
//       } else if (difference.inHours > 0) {
//         return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
//       } else if (difference.inMinutes > 0) {
//         return "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago";
//       } else {
//         return "Just now";
//       }
//     } catch (e) {
//       return "Recently";
//     }
//   }
//
//   // Footer Section
//   Widget _buildFooterSection() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Contact Shop",
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF1F2937),
//             ),
//           ),
//           SizedBox(height: 16),
//           Row(
//             children: [
//               Icon(Icons.email, color: Color(0xFF4C6EF5), size: 20),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   widget.userData["shopInfo"]["shopEmail"],
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Color(0xFF6B7280),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12),
//           Row(
//             children: [
//               Icon(Icons.phone, color: Color(0xFF4C6EF5), size: 20),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   widget.userData["shopInfo"]["ContactNo"],
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Color(0xFF6B7280),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           Divider(),
//           SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               TextButton.icon(
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Report functionality")),
//                   );
//                 },
//                 icon: Icon(Icons.flag, size: 18),
//                 label: Text(
//                   "Report Issue",
//                   style: GoogleFonts.poppins(fontSize: 13),
//                 ),
//               ),
//               Text(" • ", style: TextStyle(color: Colors.grey)),
//               TextButton.icon(
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Suggest edit functionality")),
//                   );
//                 },
//                 icon: Icon(Icons.edit, size: 18),
//                 label: Text(
//                   "Suggest Edit",
//                   style: GoogleFonts.poppins(fontSize: 13),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showWriteReviewDialog(BuildContext context) {
//     double rating = 5.0;
//     TextEditingController reviewController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) => AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: Text(
//             "Write a Review",
//             style: GoogleFonts.poppins(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF667eea),
//             ),
//           ),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Rate your experience",
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(5, (index) {
//                     return IconButton(
//                       icon: Icon(
//                         index < rating ? Icons.star : Icons.star_border,
//                         color: Colors.amber,
//                         size: 36,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           rating = index + 1.0;
//                         });
//                       },
//                     );
//                   }),
//                 ),
//                 SizedBox(height: 20),
//                 Text(
//                   "Write your review",
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 TextField(
//                   controller: reviewController,
//                   maxLines: 5,
//                   decoration: InputDecoration(
//                     hintText: "Share your experience...",
//                     hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Color(0xFF667eea)),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey[300]!),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
//                     ),
//                   ),
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 "Cancel",
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (reviewController.text.trim().isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("Please write a review"),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                   return;
//                 }
//
//                 User? user = FirebaseAuth.instance.currentUser;
//                 if (user == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("Please log in to write a review"),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                   return;
//                 }
//
//                 String userName = user.displayName ?? "Anonymous";
//                 try {
//                   DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");
//                   DatabaseEvent userEvent = await usersRef.orderByChild("email").equalTo(user.email).once();
//                   if (userEvent.snapshot.value != null) {
//                     Map<dynamic, dynamic> userData = userEvent.snapshot.value as Map;
//                     if (userData.isNotEmpty) {
//                       var userInfo = userData.values.first;
//                       userName = userInfo["name"] ?? user.displayName ?? user.email?.split('@')[0] ?? "Anonymous";
//                     }
//                   }
//                 } catch (e) {
//                   print("Error fetching user name: $e");
//                 }
//
//                 String shopEmailKey = widget.userData["accountLinks"]["email"].toString().replaceAll('.', '_');
//                 DatabaseReference reviewRef = FirebaseDatabase.instance.ref("reviews/$shopEmailKey").push();
//
//                 try {
//                   await reviewRef.set({
//                     "userName": userName,
//                     "userEmail": user.email,
//                     "rating": rating,
//                     "review": reviewController.text.trim(),
//                     "timestamp": DateTime.now().toIso8601String(),
//                   });
//
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Row(
//                         children: [
//                           Icon(Icons.check_circle, color: Colors.white),
//                           SizedBox(width: 12),
//                           Text("Review posted successfully!"),
//                         ],
//                       ),
//                       backgroundColor: Colors.green,
//                       behavior: SnackBarBehavior.floating,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   );
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("Failed to post review. Try again."),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xFF667eea),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//               child: Text(
//                 "Submit",
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _launchURL(String url) async {
//     if (url.isNotEmpty) {
//       Uri uri = Uri.parse(url);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Could not launch $url")),
//           );
//         }
//       }
//     }
//   }
// }
