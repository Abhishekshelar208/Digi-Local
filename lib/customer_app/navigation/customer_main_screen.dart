import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digilocal/pages/home_screen.dart';
import 'package:digilocal/customer_app/screens/cart/cart_screen.dart';

import '../../pages/displayJobs.dart';
import '../../pages/onlineBookingsForCustomer.dart';
import '../../pages/profile.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({Key? key}) : super(key: key);

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _selectedIndex = 0;

  // List of pages for customer navigation
  static final List<Widget> _pages = <Widget>[
    // HomeScreen(),              // Browse shops by category
    // CartScreen(),              // Shopping cart
    // OrdersListScreen(),        // Order history & tracking
    // AllChats(),                // Chat with shops
    // CustomerProfileScreen(),   // Customer profile
    HomeScreen(),
    CartScreen(),
    OnlineBookingsForCustomer(),
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
            selectedItemColor: Color(0xFF4C6EF5),
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
              // Home Tab
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0
                        ? Color(0xFF4C6EF5).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.home_rounded,
                    size: 24,
                  ),
                ),
                label: 'Home',
              ),

              // Cart Tab
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedIndex == 1
                            ? Color(0xFF4C6EF5).withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.shopping_cart_rounded,
                        size: 24,
                      ),
                    ),
                    // Cart badge (will be dynamic later)
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
                    //       '3',
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
                label: 'Cart',
              ),

              // Orders Tab (highlighted center)
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
                              Color(0xFF3B82F6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _selectedIndex != 2 ? Color(0xFFF1F5F9) : null,
                    boxShadow: _selectedIndex == 2
                        ? [
                            BoxShadow(
                              color: Color(0xFF4C6EF5).withOpacity(0.4),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.receipt_long_rounded,
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
                        ? Color(0xFF4C6EF5).withOpacity(0.1)
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

              // Profile Tab
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 4
                        ? Color(0xFF4C6EF5).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 24,
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
