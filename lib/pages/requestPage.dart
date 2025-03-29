import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestPage extends StatefulWidget {
  final String userId;

  RequestPage({required this.userId});

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final TextEditingController _requestController = TextEditingController();

  void _submitRequest() async {
    String requestText = _requestController.text.trim();

    if (requestText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a request!")),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in!")),
      );
      return;
    }

    String senderEmail = user.email?.toLowerCase() ?? "Unknown";
    DatabaseReference studentsRef = FirebaseDatabase.instance.ref("users");

    // Fetch all students
    DatabaseEvent event = await studentsRef.once();
    if (!event.snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No students found in the database!")),
      );
      return;
    }

    Map<dynamic, dynamic> students = event.snapshot.value as Map<dynamic, dynamic>;
    String? senderName;
    String? senderId;
    String? recipientUserId;
    String? recipientEmail;

    // Find sender details
    for (var entry in students.entries) {
      Map<dynamic, dynamic> studentData = entry.value;

      if (studentData.containsKey("email") &&
          studentData["email"].toString().toLowerCase() == senderEmail) {
        senderName = studentData["name"];
        senderId = entry.key;
        break;
      }
    }

    if (senderName == null || senderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Your profile details not found!")),
      );
      return;
    }

    // Find recipient details
    for (var entry in students.entries) {
      Map<dynamic, dynamic> studentData = entry.value;

      if (studentData.containsKey("email") &&
          studentData["email"].toString().toLowerCase() == widget.userId.toLowerCase()) {
        recipientUserId = entry.key;
        recipientEmail = studentData["email"].toString().toLowerCase();
        break;
      }
    }

    if (recipientUserId == null || recipientEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not found!")),
      );
      return;
    }

    // Generate a unique Chat ID (receiverEmail_senderEmail)
    String chatId = "${recipientEmail.replaceAll('.', '_')}+${senderEmail.replaceAll('.', '_')}";

    // Store the request in Firebase
    DatabaseReference requestRef = FirebaseDatabase.instance.ref("users/$recipientUserId/requests");
    String requestId = requestRef.push().key!;

    await requestRef.child(requestId).set({
      "senderEmail": senderEmail,
      "senderName": senderName, // Store sender name
      "requestText": requestText,
      "isAccepted": "Pending",
      "timestamp": DateTime.now().toIso8601String(),
      "chatId": chatId,
      "studentID": senderId,
      "uid": user.uid,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request submitted successfully!")),
    );

    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF), //off white,
      appBar: AppBar(
        title: Text(
          "Submit Request",
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Request Field
            TextField(
              style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
              controller: _requestController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Type Your Message',
                labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black,),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black,), // Always orange
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black, width: 2), // Thicker when focused
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black,), // Always orange
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black, width: 2), // Thicker when focused
                ),
              ),
            ),
            SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent, // Background color changed to red
                foregroundColor: Colors.white, // Text color white for contrast
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10), // Increased size
                minimumSize: Size(200, 0), // Explicitly setting width and height
              ),
              child: Text(
                "Send Inquiry",
                style: GoogleFonts.blinker(
                  color: Colors.white, // Set color to white to ensure the gradient is visible
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
