import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digilocal/shop_owner_app/screens/dashboard/shop_dashboard_screen.dart';
import 'package:digilocal/pages/onlineBookingForSHop.dart';
import 'package:digilocal/shop_owner_app/screens/products/products_management_screen.dart';
import 'package:digilocal/pages/all_chats_page.dart';
import 'package:digilocal/shop_owner_app/screens/shop/shop_management_screen.dart';

import '../../customer_app/screens/cart/cart_screen.dart';
import '../../pages/displayJobs.dart';
import '../../pages/home_screen.dart';
import '../../pages/offersDisplay_page.dart';
import '../../pages/onlineBookingsForCustomer.dart';
import '../../pages/profile.dart';

class OwnerMainScreen extends StatefulWidget {
  const OwnerMainScreen({Key? key}) : super(key: key);

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  int _selectedIndex = 0;

  // List of pages for shop owner navigation
  static final List<Widget> _pages = <Widget>[
    // ShopDashboardScreen(),      // Analytics & overview
    // OnlineBookingsForShop(),    // Order management (reused)
    // ProductsManagementScreen(), // Product management
    // AllChats(),                 // Chat with customers (reused)
    // ShopManagementScreen(),     // Shop profile & settings
    HomeScreen(),
    CartScreen(),
    OnlineBookingsForShop(),
    JobsListPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Color(0xFFFFFFFF),
            elevation: 0,
            selectedItemColor: Color(0xFF6366F1),
            unselectedItemColor: Color(0xFF6B7280),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            items: [
              // Dashboard Tab
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0
                        ? Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.dashboard_rounded,
                    size: 24,
                  ),
                ),
                label: 'Dashboard',
              ),

              // Orders Tab
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedIndex == 1
                            ? Color(0xFF6366F1).withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        size: 24,
                      ),
                    ),
                    // Notification badge (will be dynamic later)
                    // Positioned(
                    //   right: -2,
                    //   top: -2,
                    //   child: Container(
                    //     padding: EdgeInsets.all(4),
                    //     decoration: BoxDecoration(
                    //       color: Color(0xFFEF4444),
                    //       shape: BoxShape.circle,
                    //     ),
                    //     constraints: BoxConstraints(
                    //       minWidth: 18,
                    //       minHeight: 18,
                    //     ),
                    //     child: Text(
                    //       '5',
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 10,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //       textAlign: TextAlign.center,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                label: 'Orders',
              ),

              // Products Tab (highlighted center)
              BottomNavigationBarItem(
                icon: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _selectedIndex == 2
                        ? LinearGradient(
                            colors: [
                              Color(0xFF6366F1),
                              Color(0xFF8B5CF6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _selectedIndex != 2 ? Color(0xFFF1F5F9) : null,
                    boxShadow: _selectedIndex == 2
                        ? [
                            BoxShadow(
                              color: Color(0xFF6366F1).withOpacity(0.4),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.inventory_2_rounded,
                      size: 28,
                      color: _selectedIndex == 2
                          ? Colors.white
                          : Color(0xFF6B7280),
                    ),
                  ),
                ),
                label: '',
              ),

              // Chats Tab
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 3
                        ? Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chat_bubble_rounded,
                    size: 24,
                  ),
                ),
                label: 'Chats',
              ),

              // Shop Tab
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 4
                        ? Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.store_rounded,
                    size: 24,
                  ),
                ),
                label: 'Shop',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
