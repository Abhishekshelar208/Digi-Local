// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// class SentRequestsPage extends StatefulWidget {
//   @override
//   _SentRequestsPageState createState() => _SentRequestsPageState();
// }
//
// class _SentRequestsPageState extends State<SentRequestsPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _database = FirebaseDatabase.instance.ref().child("Users");
//   List<Map<String, dynamic>> sentRequests = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchSentRequests();
//   }
//
//   Future<void> _fetchSentRequests() async {
//     User? user = _auth.currentUser;
//     if (user == null) {
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }
//
//     String userEmail = user.email!;
//     List<Map<String, dynamic>> tempRequests = [];
//
//     DatabaseEvent usersEvent = await _database.once();
//     if (usersEvent.snapshot.exists) {
//       Map<dynamic, dynamic> usersData = usersEvent.snapshot.value as Map<dynamic, dynamic>;
//
//       usersData.forEach((userId, userData) {
//         if (userData["requests"] != null) {
//           Map<dynamic, dynamic> requests = userData["requests"];
//
//           requests.forEach((requestId, requestData) {
//             if (requestData["senderEmail"] == userEmail) {
//               tempRequests.add({
//                 "requestId": requestId,
//                 "senderName": requestData["senderName"],
//                 "requestText": requestData["requestText"],
//                 "isAccepted": requestData["isAccepted"],
//               });
//             }
//           });
//         }
//       });
//
//       setState(() {
//         sentRequests = tempRequests;
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   void _startChat(String receiverName) {
//     // TODO: Implement chat functionality
//     print("Chat with $receiverName started.");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : sentRequests.isEmpty
//           ? Center(child: Text("No sent requests found."))
//           : ListView.builder(
//         itemCount: sentRequests.length,
//         itemBuilder: (context, index) {
//           var request = sentRequests[index];
//           return Card(
//             margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Sender: ${request["senderName"]}",
//                       style: TextStyle(fontWeight: FontWeight.bold)),
//                   SizedBox(height: 8),
//                   Text("Request: ${request["requestText"]}"),
//                   SizedBox(height: 8),
//                   Text(
//                     "Status: ${request["isAccepted"] ? "Accepted" : "Pending"}",
//                     style: TextStyle(
//                         color: request["isAccepted"] ? Colors.green : Colors.orange),
//                   ),
//                   if (request["isAccepted"]) ...[
//                     SizedBox(height: 8),
//                     ElevatedButton(
//                       onPressed: () => _startChat(request["senderName"]),
//                       child: Text("Chat"),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
