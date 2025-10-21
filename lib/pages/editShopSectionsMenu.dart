import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'editSections/editBasicInfo.dart';
import 'editSections/editCategoryInfo.dart';
import 'editSections/editAdditionalInfo.dart';
import 'editSections/editServices.dart';
import 'editSections/editProductTypes.dart';
import 'editSections/editCoupons.dart';
import 'editSections/editEvents.dart';
import 'editSections/editProducts.dart';
import 'editSections/editOffers.dart';
import 'editSections/editSocialLinks.dart';
import 'editSections/editOperationalStatus.dart';
import 'editSections/editDeliverySettings.dart';
import 'editSections/editPaymentMethods.dart';
import 'editSections/editFAQs.dart';
import 'editSections/editVideos.dart';
import 'editSections/editShopGallery.dart';

class EditShopSectionsMenu extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditShopSectionsMenu({
    Key? key,
    required this.shopId,
    required this.shopData,
  }) : super(key: key);

  @override
  _EditShopSectionsMenuState createState() => _EditShopSectionsMenuState();
}

class _EditShopSectionsMenuState extends State<EditShopSectionsMenu> {
  late Map<String, dynamic> currentShopData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentShopData = widget.shopData;
  }

  Future<void> _refreshShopData() async {
    setState(() {
      isLoading = true;
    });

    try {
      DatabaseReference shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
      DataSnapshot snapshot = await shopRef.get();
      
      if (snapshot.exists) {
        setState(() {
          currentShopData = Map<String, dynamic>.from(snapshot.value as Map);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error refreshing data: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _navigateToSection(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    // Refresh data after returning from edit page
    await _refreshShopData();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> sections = [
      {
        'title': 'Basic Information',
        'icon': Icons.info_outline,
        'color': Color(0xFF6cd5c6),
        'page': EditBasicInfo(shopId: widget.shopId, shopData: currentShopData),
      },
      {
        'title': 'Category',
        'icon': Icons.category_outlined,
        'color': Color(0xFFfda88b),
        'page': EditCategoryInfo(shopId: widget.shopId, shopData: currentShopData),
      },
      {
        'title': 'Additional Info',
        'icon': Icons.add_circle_outline,
        'color': Color(0xFF9bbef5),
        'page': EditAdditionalInfo(shopId: widget.shopId, shopData: currentShopData),
      },
      {
        'title': 'Services',
        'icon': Icons.miscellaneous_services_outlined,
        'color': Color(0xFFf59fd6),
        'page': EditServices(shopId: widget.shopId, shopData: currentShopData),
      },
      {
        'title': 'Product Types',
        'icon': Icons.inventory_2_outlined,
        'color': Color(0xFFbba1f1),
        'page': EditProductTypes(shopId: widget.shopId, shopData: currentShopData),
      },
      {
        'title': 'Coupons',
        'icon': Icons.local_offer_outlined,
        'color': Color(0xFF8ec7d3),
        'page': EditCoupons(shopId: widget.shopId, shopData: currentShopData),
      },
      {
        'title': 'Events / Gallery',
        'icon': Icons.event_outlined,
        'color': Color(0xFFa0d69a),
        'page': EditEvents(shopId: widget.shopId, shopData: currentShopData),
      },
      {
        'title': 'Products',
        'icon': Icons.shopping_bag_outlined,
        'color': Color(0xFF6cd5c6),
        'page': EditProducts(shopId: widget.shopId, shopData: currentShopData),
      },
      {
        'title': 'Offers',
        'icon': Icons.card_giftcard_outlined,
        'color': Color(0xFFfda88b),
        'page': EditOffers(shopId: widget.shopId, shopData: currentShopData),
      },
      {
        'title': 'Social Links',
        'icon': Icons.share_outlined,
        'color': Color(0xFF9bbef5),
        'page': EditSocialLinks(shopId: widget.shopId, shopData: currentShopData),
      },
      {
        'title': 'Operational Status',
        'icon': Icons.access_time_outlined,
        'color': Color(0xFFf59fd6),
        'page': EditOperationalStatus(shopId: widget.shopId, shopData: currentShopData),
      },
      {
        'title': 'Delivery Settings',
        'icon': Icons.delivery_dining_outlined,
        'color': Color(0xFFbba1f1),
        'page': EditDeliverySettings(shopId: widget.shopId, shopData: currentShopData),
      },
      {
        'title': 'Payment Methods',
        'icon': Icons.payment_outlined,
        'color': Color(0xFF8ec7d3),
        'page': EditPaymentMethods(shopId: widget.shopId, shopData: currentShopData),
      },
      {
        'title': 'FAQs',
        'icon': Icons.help_outline,
        'color': Color(0xFFa0d69a),
        'page': EditFAQs(shopId: widget.shopId, shopData: currentShopData),
      },
      {
        'title': 'Videos',
        'icon': Icons.video_library_outlined,
        'color': Color(0xFF6cd5c6),
        'page': EditVideos(shopId: widget.shopId, shopData: currentShopData),
      },
      {
        'title': 'Shop Gallery',
        'icon': Icons.photo_library_outlined,
        'color': Color(0xFFfda88b),
        'page': EditShopGallery(shopId: widget.shopId, shopData: currentShopData),
      },
    ];

    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text(
          "Edit Shop Sections",
          style: GoogleFonts.blinker(
            fontSize: 34,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: sections.length,
          itemBuilder: (context, index) {
            final section = sections[index];
            return GestureDetector(
              onTap: () {
                _navigateToSection(section['page']);
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: section['color'],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      section['icon'],
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        section['title'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.blinker(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
    );
  }
}
