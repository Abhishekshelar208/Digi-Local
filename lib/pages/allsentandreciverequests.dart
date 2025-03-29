import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'chat_screen.dart';

class AllSentAndREcivedRequest extends StatefulWidget {
  @override
  _AllSentAndREcivedRequestState createState() => _AllSentAndREcivedRequestState();
}

class _AllSentAndREcivedRequestState extends State<AllSentAndREcivedRequest> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF), //off white,
      appBar: AppBar(
        title: Text(
          "Request",
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        bottom: TabBar(
          labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          indicatorColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          unselectedLabelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold),
          controller: _tabController,
          tabs: [
            Tab(text: "Received Requests"),
            Tab(text: "Sent Requests"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ReceivedRequestsPage(),
          SentRequestsPage(),
        ],
      ),
    );
  }
}

// Received Requests Page
class ReceivedRequestsPage extends StatefulWidget {
  @override
  _ReceivedRequestsPageState createState() => _ReceivedRequestsPageState();
}

class _ReceivedRequestsPageState extends State<ReceivedRequestsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    User? user = _auth.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    String userEmail = user.email!;
    DatabaseEvent usersEvent = await _database.child("users").once();

    if (usersEvent.snapshot.exists) {
      Map<dynamic, dynamic> usersData = usersEvent.snapshot.value as Map<dynamic, dynamic>;

      String? userId;
      usersData.forEach((key, value) {
        if (value["email"] == userEmail) {
          userId = key;
        }
      });

      if (userId == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      DatabaseEvent requestsEvent = await _database.child("users/$userId/requests").once();
      if (requestsEvent.snapshot.exists) {
        Map<dynamic, dynamic> requestsData = requestsEvent.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          requests = requestsData.entries.map((entry) {
            return {
              "requestId": entry.key,
              "senderName": entry.value["senderName"],
              "requestText": entry.value["requestText"],
              "isAccepted": entry.value["isAccepted"],
              "senderEmail": entry.value["senderEmail"],  // Ensure sender email is included
              "receiverEmail": userEmail,  // The current user's email as receiver
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }



  Future<void> _updateRequestStatus(String requestId, String status) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference userRef = _database.child("users");

      // Find the user's unique ID based on email
      DatabaseEvent event = await userRef.orderByChild("email").equalTo(user.email).once();
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> userData = event.snapshot.value as Map<dynamic, dynamic>;
        String uniqueUserId = userData.keys.first;

        DatabaseReference requestRef = _database.child("users/$uniqueUserId/requests/$requestId");
        await requestRef.update({"isAccepted": status});  // Update status

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request marked as $status!")),
        );

        _fetchRequests();  // Refresh the UI
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    List<Color> cardColors = [
      Color(0xFF6cd5c6),
      Color(0xFFfda88b),
      Color(0xFF9bbef5),
      Color(0xFFf59fd6),
      Color(0xFFbba1f1),
      Color(0xFF8ec7d3),
      Color(0xFFa0d69a),
    ];

    return isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.deepOrangeAccent,))
        : requests.isEmpty
        ? Center(child: Text("No requests found."))
        : ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        var request = requests[index];
        Color cardColor = cardColors[index % cardColors.length];

        return Card(
          color: cardColor, // Apply color to card
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Request Message : ",
                  style:  GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black54),
                ),
                Text(
                  "${request["requestText"]}",
                  style:  GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "From - ${request["senderName"]}",
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Status: ${request["isAccepted"] ?? "Pending"}",
                      style: GoogleFonts.blinker(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: request["isAccepted"] == "Accepted"
                            ? Colors.black54
                            : request["isAccepted"] == "Rejected"
                            ? Colors.red
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (request["isAccepted"] == "Pending")
                      ElevatedButton(
                        onPressed: () => _updateRequestStatus(request["requestId"], "Accepted"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                        child: Text(
                          "Accept",
                          style:  GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    SizedBox(width: 8),
                    if (request["isAccepted"] == "Pending")
                      ElevatedButton(
                        onPressed: () => _updateRequestStatus(request["requestId"], "Rejected"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
                        child: Text(
                          "Reject",
                          style:  GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                if (request["isAccepted"] == "Accepted")
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatId: "${request["receiverEmail"].replaceAll('.', '_')}_${request["senderEmail"].replaceAll('.', '_')}",
                              receiverName: request["senderName"],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      child: Text(
                        "Let's Chat",
                        style:  GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class SentRequestsPage extends StatefulWidget {
  @override
  _SentRequestsPageState createState() => _SentRequestsPageState();
}

class _SentRequestsPageState extends State<SentRequestsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child("users");
  List<Map<String, dynamic>> sentRequests = [];
  bool isLoading = true;

  final List<Color> boxColors = [
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
    _fetchSentRequests();
  }

  Future<void> _fetchSentRequests() async {
    User? user = _auth.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    String userEmail = user.email!;
    List<Map<String, dynamic>> tempRequests = [];

    DatabaseEvent usersEvent = await _database.once();
    if (usersEvent.snapshot.exists) {
      Map<dynamic, dynamic> usersData = usersEvent.snapshot.value as Map<dynamic, dynamic>;

      usersData.forEach((userId, userData) {
        if (userData["requests"] != null) {
          Map<dynamic, dynamic> requests = userData["requests"];

          requests.forEach((requestId, requestData) {
            if (requestData["senderEmail"] == userEmail) {
              tempRequests.add({
                "requestId": requestId,
                "requestText": requestData["requestText"],
                "isAccepted": requestData["isAccepted"],
                "senderEmail": requestData["senderEmail"],
                "receiverEmail": userData["email"],
                "receiverName": userData["name"]
              });
            }
          });
        }
      });

      setState(() {
        sentRequests = tempRequests;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.deepOrangeAccent,))
        : sentRequests.isEmpty
        ? Center(child: Text("No sent requests found."))
        : ListView.builder(
      itemCount: sentRequests.length,
      itemBuilder: (context, index) {
        var request = sentRequests[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
          color: boxColors[index % boxColors.length], // Apply color sequence
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Request Message : ",
                  style:  GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black54),
                ),
                Text(
                  "${request["requestText"]}",
                  style:  GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Request To : ${request["receiverName"]}",
                      style:  GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Status: ${request["isAccepted"] == "Accepted" ? "Accepted" : request["isAccepted"] == "Rejected" ? "Rejected" : "Pending"}",
                      style: GoogleFonts.blinker(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: request["isAccepted"] == "Accepted"
                            ? Colors.black54
                            : request["isAccepted"] == "Rejected"
                            ? Colors.red
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
                if (request["isAccepted"] == "Accepted")
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatId:
                              "${request["receiverEmail"].replaceAll('.', '_')}_${request["senderEmail"].replaceAll('.', '_')}",
                              receiverName: request["receiverName"],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: boxColors[index % boxColors.length], // Match button text color with card
                      ),
                      child: Text(
                        "Let's Chat",
                        style:  GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),

                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
