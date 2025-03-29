import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'create_offers.dart';

String formatDeadline(String dateString) {
  try {
    DateTime date = DateTime.parse(dateString); // Parse the date
    return DateFormat('d MMM y').format(date); // Format to "23 Dec"
  } catch (e) {
    return dateString; // Return original if parsing fails
  }
}



class OfferListPage extends StatefulWidget {
  @override
  _OfferListPageState createState() => _OfferListPageState();
}



class _OfferListPageState extends State<OfferListPage> {
  final DatabaseReference _database =
  FirebaseDatabase.instance.ref().child("offers");
  List<Map<String, dynamic>> offers = [];

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
  void initState() {
    super.initState();
    _fetchChallenges();
  }

  Future<void> _fetchChallenges() async {
    _database.onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> challengesData =
        event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          offers = challengesData.entries.map((entry) {
            return {
              "id": entry.key,
              "name": entry.value["name"],
              "description": entry.value["description"],
              "coupon": entry.value["coupon"],
              "deadline": entry.value["deadline"],
              "creator": entry.value["creator"],
            };
          }).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF), //off white,
      appBar: AppBar(
        title: Text(
          "Discounts & Offers",
          style: GoogleFonts.blinker(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          SizedBox(height: 16), // Space after AppBar
          Expanded(
            child: ListView.builder(
              itemCount: offers.length,
              itemBuilder: (context, index) {
                var challenge = offers[index];
                return Container(
                  height: 150, // Increased card height
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                    ),
                    elevation: 4,
                    color: boxColors[index % boxColors.length], // Assigning colors sequentially
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  child: Text(
                                    challenge["name"],
                                    style: GoogleFonts.blinker(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                SizedBox(height: 5),
                                FittedBox(
                                  child: Text(
                                    "Created By: ${challenge["creator"]}",
                                    style: GoogleFonts.blinker(color: Colors.white,fontSize: 17,fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text("Ends At: ${formatDeadline(challenge["deadline"])}",
                                  style: GoogleFonts.blinker(color: Colors.black54,fontSize: 17, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              foregroundColor: boxColors[index % boxColors.length], // Button text color
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OffersDetailPage(
                                      challengeId: challenge["id"],
                                      challenge: challenge),
                                ),
                              );
                            },
                            child: Text("View",style: GoogleFonts.blinker(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateOffersPage()),
          );
        },
        label: Icon(Icons.add,color: Colors.black,),
        backgroundColor: Colors.white, // Matching theme
      ),
    );
  }
}







class OffersDetailPage extends StatefulWidget {
  final String challengeId;
  final Map<String, dynamic> challenge;

  OffersDetailPage({required this.challengeId, required this.challenge});

  @override
  _OffersDetailPageState createState() => _OffersDetailPageState();
}

class _OffersDetailPageState extends State<OffersDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _studentsRef =
  FirebaseDatabase.instance.ref().child("users");
  final DatabaseReference _challengesRef =
  FirebaseDatabase.instance.ref().child("offers");
  List<Map<String, String>> joinedUsers = [];
  bool _isUserJoined = false; // Track if the user has joined

  @override
  void initState() {
    super.initState();
    _fetchJoinedUsers();
  }

  Future<void> _fetchJoinedUsers() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DatabaseReference joinedUsersRef =
    _challengesRef.child(widget.challengeId).child("joinedUsers");

    joinedUsersRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        List<Map<String, String>> users = [];
        Map<dynamic, dynamic> usersData =
        event.snapshot.value as Map<dynamic, dynamic>;

        bool isUserJoined = false; // Track if logged-in user is in the list

        usersData.forEach((key, value) {
          users.add({"name": value["name"], "email": value["email"]});

          if (value["email"] == user.email) {
            isUserJoined = true;
          }
        });

        setState(() {
          joinedUsers = users;
          _isUserJoined = isUserJoined; // Update the state
        });
      }
    });
  }

  Future<void> _joinChallenge() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DataSnapshot studentsSnapshot = await _studentsRef.get();
    String? userName;

    if (studentsSnapshot.exists) {
      Map<dynamic, dynamic> studentsData =
      studentsSnapshot.value as Map<dynamic, dynamic>;
      studentsData.forEach((key, student) {
        if (student["email"] == user.email) {
          userName = student["name"];
        }
      });
    }

    if (userName == null) return;

    DatabaseReference challengeRef =
    _challengesRef.child(widget.challengeId).child("joinedUsers");

    DataSnapshot joinedUsersSnapshot = await challengeRef.get();
    if (joinedUsersSnapshot.exists) {
      Map<dynamic, dynamic> joinedUsersData =
      joinedUsersSnapshot.value as Map<dynamic, dynamic>;
      if (joinedUsersData.values.any((userData) => userData["email"] == user.email)) {
        return;
      }
    }

    await challengeRef.push().set({
      "name": userName,
      "email": user.email,
    });

    _fetchJoinedUsers(); // Refresh list after joining
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text(
          "Offer Details",
          style: GoogleFonts.blinker(
              fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card with a scrollable content area
              SizedBox(
                width: double.infinity,
                height: 350,
                child: Card(
                  color: Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              widget.challenge["name"],
                              style: GoogleFonts.blinker(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "About Offer:",
                            style: GoogleFonts.blinker(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700]),
                          ),
                          Text(
                            widget.challenge["description"],
                            style: GoogleFonts.blinker(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Coupon Code:",
                            style: GoogleFonts.blinker(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700]),
                          ),
                          Text(
                            widget.challenge["coupon"],
                            style: GoogleFonts.blinker(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Ends At: ${formatDeadline(widget.challenge["deadline"])}",
                            style: GoogleFonts.blinker(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700]),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Shop Name: ${widget.challenge["creator"]}",
                            style: GoogleFonts.blinker(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     ElevatedButton(
              //       onPressed: _joinChallenge,
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.deepOrangeAccent,
              //         foregroundColor: Colors.white,
              //         padding:
              //         EdgeInsets.symmetric(horizontal: 60, vertical: 15),
              //         minimumSize: Size(200, 0),
              //       ),
              //       child: Text(
              //         "Join Offer",
              //         style: GoogleFonts.blinker(
              //             fontSize: 18,
              //             fontWeight: FontWeight.bold,
              //             color: Colors.white),
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: 20),
              //
              // // Show Chat Button Only If User Has Joined
              // if (_isUserJoined)
              //   Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       ElevatedButton(
              //         onPressed: () {
              //           // Navigate to chat screen
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => ChatScreenForCommunity(
              //                   challengeId: widget.challengeId,
              //                 )),
              //           );
              //         },
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.blue,
              //           foregroundColor: Colors.white,
              //           padding:
              //           EdgeInsets.symmetric(horizontal: 60, vertical: 15),
              //           minimumSize: Size(200, 0),
              //         ),
              //         child: Text(
              //           "Open Chat",
              //           style: GoogleFonts.blinker(
              //               fontSize: 18,
              //               fontWeight: FontWeight.bold,
              //               color: Colors.white),
              //         ),
              //       ),
              //     ],
              //   ),

              // SizedBox(height: 30),
              // Text(
              //   "Community Members",
              //   style: GoogleFonts.blinker(
              //       fontSize: 26,
              //       fontWeight: FontWeight.w600,
              //       color: Colors.black),
              // ),
              // SizedBox(height: 10),
              // ListView.builder(
              //   shrinkWrap: true,
              //   itemCount: joinedUsers.length,
              //   itemBuilder: (context, index) {
              //     var user = joinedUsers[index];
              //     return Card(
              //       color: Colors.white,
              //       shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(20)),
              //       margin: EdgeInsets.symmetric(vertical: 5),
              //       child: ListTile(
              //         title: Text(user["name"] ?? "Unknown",
              //             style: GoogleFonts.blinker(
              //                 fontSize: 22,
              //                 fontWeight: FontWeight.bold,
              //                 color: Colors.grey[700])),
              //         subtitle: Text(user["email"] ?? "No email",
              //             style: GoogleFonts.blinker(
              //                 fontSize: 18,
              //                 fontWeight: FontWeight.w500,
              //                 color: Colors.black54)),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}






class ChatScreenForCommunity extends StatefulWidget {
  final String challengeId;
  ChatScreenForCommunity({required this.challengeId});

  @override
  _ChatScreenForCommunityState createState() => _ChatScreenForCommunityState();
}

class _ChatScreenForCommunityState extends State<ChatScreenForCommunity> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref();
  final TextEditingController _messageController = TextEditingController();
  String? userName;
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _listenForMessages();
  }

  void _fetchUserName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference studentsRef =
      FirebaseDatabase.instance.ref().child("students");
      DataSnapshot snapshot = await studentsRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> studentsData =
        snapshot.value as Map<dynamic, dynamic>;
        studentsData.forEach((key, student) {
          if (student["email"] == user.email) {
            setState(() {
              userName = student["name"];
            });
          }
        });
      }
    }
  }

  void _listenForMessages() {
    DatabaseReference chatRef =
    _chatRef.child("challenges").child(widget.challengeId).child("chat");
    chatRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        List<Map<String, String>> chatMessages = [];
        Map<dynamic, dynamic> messagesData =
        event.snapshot.value as Map<dynamic, dynamic>;
        messagesData.forEach((key, value) {
          chatMessages.add({
            "sender": value["sender"],
            "message": value["message"],
            "time": value["time"]
          });
        });

        chatMessages.sort((a, b) => a["time"]!.compareTo(b["time"]!));

        setState(() {
          messages = chatMessages;
        });
      }
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || userName == null) return;
    User? user = _auth.currentUser;
    if (user == null) return;

    DatabaseReference chatRef =
    _chatRef.child("challenges").child(widget.challengeId).child("chat");

    await chatRef.push().set({
      "sender": userName,
      "message": _messageController.text.trim(),
      "time": DateTime.now().toIso8601String(),
    });


    _messageController.clear();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF), //off white,
      appBar: AppBar(
        title: Text(
          "Community Chat",
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                bool isMe = message["sender"] == userName;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue.shade400 : Color(0xFF4dc590),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message["sender"]!,
                          style: GoogleFonts.blinker(
                              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          message["message"]!,
                          style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[100]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style:  GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(14),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
