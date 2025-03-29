import 'package:digilocal/pages/displayJobs.dart';
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
    FilterUsersPage(),
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
      backgroundColor: const Color(0xFF141528),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C2039),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor:Color(0xffF2F0EF), //off white
          elevation: 0,
          selectedItemColor: Colors.black, // Selected icon color
          unselectedItemColor: Colors.black54, // Unselected icon color
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          items: List.generate(5, (index) {
            if (index == 2) {
              // The 3rd button with a circular background
              return BottomNavigationBarItem(
                icon: Container(
                  height: 63,
                  width: 63,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepOrangeAccent,
                  ),
                  child: Center(
                    child: Image.asset(
                      _getIconForIndex(index),
                      height: 32,
                      width: 32,
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
                      ? Colors.black // Blue for selected icon
                      : Colors.black54 // Gray for unselected icon
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
        return 'lib/assets/icons/search.png'; // Middle icon
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
        return 'Search'; // Middle label
      case 3:
        return 'Jobs';
      case 4:
        return 'Profile';
      default:
        return '';
    }
  }
}


