import 'package:digilocal/pages/shopListPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digilocal/pages/splash_screen.dart';
import 'package:digilocal/pages/userdatapageforall.dart';
import 'package:digilocal/pages/userinfopageForApp.dart';

import 'SentRequestsPage.dart';
import 'all_chats_page.dart';
import 'allsentandreciverequests.dart';
import 'alluserRequest.dart';
import 'designSelectionPage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseUsers = FirebaseDatabase.instance.ref().child("DigiLocal");
  final DatabaseReference _databaseStudents = FirebaseDatabase.instance.ref().child("users");

  String? email;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? studentData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchStudentData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        email = user.email;
      });

      _databaseUsers.orderByChild("shopInfo/Email").equalTo(email).once().then((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            userData = Map<String, dynamic>.from(data.values.first);
          });
        }
        setState(() {
          isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        print("Error fetching user data: $error");
      });
    }
  }

  Future<void> _fetchStudentData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _databaseStudents.orderByChild("email").equalTo(email).once().then((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            studentData = Map<String, dynamic>.from(data.values.first);
          });
        }
      }).catchError((error) {
        print("Error fetching student data: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF), //off white,
      appBar: AppBar(
        title: Text(
          "User Profile",
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), // Off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () async {
              // Show confirmation dialog before logging out
              bool? confirmLogout = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text("Logout Alert",style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                  content: Text("Are you sure you want to log out?",style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text("Cancel",style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text("Logout",style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),),
                    ),
                  ],
                ),
              );

              if (confirmLogout == true) {
                await FirebaseAuth.instance.signOut(); // Sign out from Firebase
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SplashScreen()), // Navigate to login screen
                );
              }
            },
            icon: Image.asset(
              color: Colors.black,
              "lib/assets/icons/logout.png",
              width: 28, // Adjust the size if needed
              height: 28,
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
                studentData == null
                    ? Center(child: Text("No User data found"))
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundImage: studentData!["shopPic"] != null && studentData!["shopPic"].isNotEmpty
                          ? NetworkImage(studentData!["shopPic"])
                          : AssetImage("lib/assets/images/finaluser.jpg") as ImageProvider,
                    ),
                    SizedBox(height: 20),
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 5,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("${studentData!["name"]}", style:  GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),),
                            Text("$email", style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey[700]),),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.person,color: Colors.grey[700],size: 30,),
                              title: Text("Contact No",style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),),
                              subtitle: Text("${studentData!["contactNo"]}",style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                // Text(
                //   "My Dashboard",
                //   style: GoogleFonts.blinker(
                //       fontSize: 26,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.deepOrangeAccent),
                // ),
                // SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllChats()),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    color: Colors.blue,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "All Chats",
                          style: GoogleFonts.blinker(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                // Text(
                //   "My Dashboard",
                //   style: GoogleFonts.blinker(
                //       fontSize: 26,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.deepOrangeAccent),
                // ),
                // SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllSentAndREcivedRequest()),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    color: Colors.deepOrangeAccent,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "My Inquires",
                          style: GoogleFonts.blinker(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                userData != null
                    ? Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDataPageForAll(userData: userData!),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        color: Colors.blue.shade400,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              "View Profile",
                              style: GoogleFonts.blinker(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShopListPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Background color changed to red
                    foregroundColor: Colors.white, // Text color white for contrast
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10), // Increased size
                    minimumSize: Size(200, 0), // Explicitly setting width and height
                  ),
                  child: Text(
                    "Create Shop Profile",
                    style: GoogleFonts.blinker(
                      color: Colors.white, // Set color to white to ensure the gradient is visible
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
