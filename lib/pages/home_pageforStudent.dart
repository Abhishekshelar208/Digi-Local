import 'package:digilocal/pages/displayJobs.dart';
import 'package:digilocal/pages/onlineBookingForSHop.dart';
import 'package:digilocal/pages/onlineBookingsForCustomer.dart';
import 'package:flutter/material.dart';
import 'package:digilocal/pages/profile.dart';

import 'ReceivedMessagesScreen.dart';
import 'all_chats_page.dart';
import 'offersDisplay_page.dart';
import 'googleAi.dart';
import 'home_screen.dart';
import 'mcqtest.dart';


class HomeScreenForStdudent extends StatefulWidget {
  @override
  _HomeScreenForStdudentState createState() => _HomeScreenForStdudentState();
}

class _HomeScreenForStdudentState extends State<HomeScreenForStdudent> {
  int _selectedIndex = 0;

  // List of pages to navigate
  static final List<Widget> _pages = <Widget>[
    HomeScreen(),
    OfferListPage(),
    OnlineBookingsForShop(),
    JobsListPage(),
    ProfilePage(),

    // StudentLikePage(),
    // RegisteredEventPage(),
    // AnnouncementPageStudent(),
    // FavouriteEventsPage(),
    // ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Pure White
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF), // Pure White
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Color(0xFFFFFFFF), // Pure White
          elevation: 0,
          selectedItemColor: Color(0xFF4C6EF5), // DigiLocal Primary Blue
          unselectedItemColor: Color(0xFF6B7280), // Muted Gray
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: List.generate(5, (index) {
            if (index == 2) {
              // The 3rd button with a circular background
              return BottomNavigationBarItem(
                icon: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF6366F1), // Soft Indigo
                        Color(0xFF3B82F6), // Vibrant Blue
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4C6EF5).withOpacity(0.4),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      _getIconForIndex(index),
                      height: 28,
                      width: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
                label: '', // Removed the label to hide text under the icon
              );
            } else {
              // Regular buttons
              return BottomNavigationBarItem(
                icon: Image.asset(
                  _getIconForIndex(index),
                  height: 24,
                  width: 24,
                  color: _selectedIndex == index
                      ? Color(0xFF4C6EF5) // DigiLocal Primary Blue for selected
                      : Color(0xFF6B7280) // Muted Gray for unselected
                ),
                label: _getLabelForIndex(index),
              );
            }
          }),
        ),
      ),
    );
  }

  // Helper function to get icons for each index
  String _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return 'lib/assets/icons/home.png';
      case 1:
        return 'lib/assets/icons/checklist.png';
      case 2:
        return 'lib/assets/icons/book.png'; // Middle icon
      case 3:
        return 'lib/assets/icons/chat.png';
      case 4:
        return 'lib/assets/icons/user.png';
      default:
        return 'lib/assets/icons/home.png';
    }
  }

  // Helper function to get labels for each index
  String _getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Offers';
      case 2:
        return 'Bookings'; // Middle label
      case 3:
        return 'Jobs';
      case 4:
        return 'Profile';
      default:
        return '';
    }
  }
}


