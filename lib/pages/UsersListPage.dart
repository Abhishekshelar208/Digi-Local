import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digilocal/pages/userdatapageforall.dart';

class UsersListPage extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> usersList;

  UsersListPage({required this.category, required this.usersList});

  final List<Color> boxColors = [
    // Color(0xFF8f98ff),
    // Color(0xFFfda88b),
    // Color(0xFF4dc590),
    // Color(0xFF66a3da),
    // Color(0xFFff8181),
    // Color(0xFFDCB0F2),
    // Color(0xFFF6CF71),


    Color(0xFF6cd5c6),
    Color(0xFFfda88b),
    Color(0xFF9bbef5),
    Color(0xFFf59fd6),
    Color(0xFFbba1f1),
    Color(0xFF8ec7d3),
    Color(0xFFa0d69a),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text(
          category,
          style: GoogleFonts.blinker(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: usersList.isEmpty
          ? Center(
          child: Text("No users found in this category",
              style: TextStyle(fontSize: 16, color: Colors.black)))
          : ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: usersList.length,
        itemBuilder: (context, index) {
          var user = usersList[index];
          return _buildUserCard(user, context, index);
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, BuildContext context, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: boxColors[index % boxColors.length],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: CircleAvatar(
                backgroundColor: Color(0xffF2F0EF),
                radius: 40,
                backgroundImage: NetworkImage(user["profilePicture"]),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user["fullName"],
                    style: GoogleFonts.blinker(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 6),
                  FittedBox(
                    child: Text(
                      user["userTitle"],
                      style: GoogleFonts.blinker(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserDataPageForAll(userData: user["userData"]),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: boxColors[index % boxColors.length], // Button text color
              ),
              child: Text("Open",style: GoogleFonts.blinker(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),),
            ),
          ],
        ),
      ),
    );
  }
}
