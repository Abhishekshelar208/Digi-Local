import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReceivedMessagesScreen extends StatefulWidget {
  @override
  _ReceivedMessagesScreenState createState() => _ReceivedMessagesScreenState();
}

class _ReceivedMessagesScreenState extends State<ReceivedMessagesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> receivedMessages = [];

  @override
  void initState() {
    super.initState();
    _fetchReceivedMessages();
  }

  Future<void> _fetchReceivedMessages() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String userEmail = user.email ?? "";
      DatabaseReference usersRef = _database.child("Users");

      usersRef.once().then((DatabaseEvent event) {
        if (event.snapshot.exists) {
          Map<dynamic, dynamic> usersData = event.snapshot.value as Map<dynamic, dynamic>;

          usersData.forEach((userId, userInfo) {
            String? email = userInfo["accountLinks"]?["email"];

            if (email == userEmail) {
              DatabaseReference chatRef = _database.child("Users/$userId/chats");
              chatRef.onValue.listen((event) {
                if (event.snapshot.exists) {
                  Map<dynamic, dynamic> messagesData = event.snapshot.value as Map<dynamic, dynamic>;
                  setState(() {
                    receivedMessages = messagesData.entries.map((entry) {
                      return {
                        "message": entry.value["message"],
                        "senderEmail": entry.value["senderEmail"],
                        "timestamp": entry.value["timestamp"],
                      };
                    }).toList();
                  });
                }
              });
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Received Messages"),
      ),
      body: receivedMessages.isEmpty
          ? Center(child: Text("No messages received yet."))
          : ListView.builder(
        itemCount: receivedMessages.length,
        itemBuilder: (context, index) {
          var message = receivedMessages[index];
          return ListTile(
            title: Text(message["message"]),
            subtitle: Text("From: ${message["senderEmail"]}"),
            trailing: Text(_formatTimestamp(message["timestamp"])),
          );
        },
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${dateTime.hour}:${dateTime.minute}, ${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}
