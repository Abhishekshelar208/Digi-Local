import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:digilocal/pages/editShopSectionsMenu.dart';
import 'package:digilocal/pages/shopListPage.dart';
import 'package:digilocal/pages/userdatapageforall.dart';

class ShopManagementScreen extends StatefulWidget {
  const ShopManagementScreen({Key? key}) : super(key: key);

  @override
  State<ShopManagementScreen> createState() => _ShopManagementScreenState();
}

class _ShopManagementScreenState extends State<ShopManagementScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child("DigiLocal");
  
  Map<String, dynamic>? shopData;
  String? shopId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShopData();
  }

  Future<void> _fetchShopData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseEvent event = await _database.orderByChild("shopInfo/Email").equalTo(user.email).once();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          shopId = data.keys.first;
          shopData = Map<String, dynamic>.from(data.values.first);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Shop',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFFEF4444)),
            onPressed: () async {
              bool? confirmLogout = await _showLogoutDialog();
              if (confirmLogout == true) {
                await _auth.signOut();
                // Navigate to login screen
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : shopData == null
              ? _buildNoShopState()
              : SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildShopHeader(),
                      SizedBox(height: 24),
                      _buildQuickActions(),
                      SizedBox(height: 24),
                      _buildManagementOptions(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildNoShopState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store_outlined,
              size: 80,
              color: Color(0xFF94A3B8),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Shop Found',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Create a shop to get started',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(16),
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
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_business, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Create Shop',
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
        ],
      ),
    );
  }

  Widget _buildShopHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: shopData!["shopInfo"]["shopImage"] != null
                ? Image.network(
                    shopData!["shopInfo"]["shopImage"],
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 100,
                    width: 100,
                    color: Color(0xFFF1F5F9),
                    child: Icon(Icons.store, size: 50, color: Color(0xFF94A3B8)),
                  ),
          ),
          SizedBox(height: 16),
          Text(
            shopData!["shopInfo"]["shopName"] ?? "Shop",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            shopData!["category"] ?? "",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.visibility_rounded,
            title: 'Preview Shop',
            color: Color(0xFF6366F1),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDataPageForAll(userData: shopData!),
                ),
              );
            },
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.edit_rounded,
            title: 'Edit Shop',
            color: Color(0xFF10B981),
            onTap: () {
              if (shopId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditShopSectionsMenu(
                      shopId: shopId!,
                      shopData: shopData!,
                    ),
                  ),
                ).then((_) => _fetchShopData()); // Refresh after edit
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.inventory_2_outlined,
            title: 'Products',
            subtitle: 'Manage your products',
            onTap: () {
              // Navigate to products
            },
          ),
          Divider(height: 1),
          _buildSettingItem(
            icon: Icons.local_offer_outlined,
            title: 'Offers & Coupons',
            subtitle: 'Create discounts',
            onTap: () {
              // Navigate to offers
            },
          ),
          Divider(height: 1),
          _buildSettingItem(
            icon: Icons.share_outlined,
            title: 'Share Shop',
            subtitle: 'Share your shop link',
            onTap: () {
              // Share functionality
            },
          ),
          Divider(height: 1),
          _buildSettingItem(
            icon: Icons.settings_outlined,
            title: 'Shop Settings',
            subtitle: 'Configure your shop',
            onTap: () {
              if (shopId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditShopSectionsMenu(
                      shopId: shopId!,
                      shopData: shopData!,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Color(0xFF64748B), size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: Color(0xFF64748B),
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
      onTap: onTap,
    );
  }

  Future<bool?> _showLogoutDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Color(0xFFEF4444)),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
