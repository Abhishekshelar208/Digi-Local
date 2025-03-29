import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRequestsPage extends StatefulWidget {
  @override
  _UserRequestsPageState createState() => _UserRequestsPageState();
}

class _UserRequestsPageState extends State<UserRequestsPage> {
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
    if (user != null) {
      String userEmail = user.email!;
      DatabaseReference userRef = _database.child("Users");

      DatabaseEvent event = await userRef.orderByChild("personalInfo/useremail").equalTo(userEmail).once();
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> userData = event.snapshot.value as Map<dynamic, dynamic>;
        String uniqueUserId = userData.keys.first;

        DatabaseReference requestsRef = _database.child("Users/$uniqueUserId/requests");
        DatabaseEvent requestsEvent = await requestsRef.once();
        if (requestsEvent.snapshot.exists) {
          Map<dynamic, dynamic> requestsData = requestsEvent.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            requests = requestsData.entries.map((entry) {
              return {
                "requestId": entry.key,
                "senderName": entry.value["senderName"],
                "requestText": entry.value["requestText"],
                "isAccepted": entry.value["isAccepted"],
                "timestamp": entry.value["timestamp"],
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
  }

  Future<void> _updateRequestStatus(String requestId, bool isAccepted) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String userEmail = user.email!;
      DatabaseReference userRef = _database.child("Users");

      DatabaseEvent event = await userRef.orderByChild("personalInfo/useremail").equalTo(userEmail).once();
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> userData = event.snapshot.value as Map<dynamic, dynamic>;
        String uniqueUserId = userData.keys.first;

        DatabaseReference requestRef = _database.child("Users/$uniqueUserId/requests/$requestId");
        await requestRef.update({"isAccepted": isAccepted});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isAccepted ? "Request Accepted!" : "Request Rejected!")),
        );

        // Refresh the list of requests
        _fetchRequests();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Requests"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? Center(child: Text("No requests found."))
          : ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          var request = requests[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "From: ${request["senderName"]}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Request: ${request["requestText"]}",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Status: ${request["isAccepted"] ? "Accepted" : "Pending"}",
                    style: TextStyle(
                      fontSize: 14,
                      color: request["isAccepted"] ? Colors.green : Colors.orange,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!request["isAccepted"])
                        ElevatedButton(
                          onPressed: () => _updateRequestStatus(request["requestId"], true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: Text("Accept"),
                        ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _updateRequestStatus(request["requestId"], false),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: Text("Reject"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}