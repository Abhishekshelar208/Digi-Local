

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateOffersPage extends StatefulWidget {
  @override
  _CreateOffersPageState createState() => _CreateOffersPageState();
}

class _CreateOffersPageState extends State<CreateOffersPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  DateTime? _selectedDeadline;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _createChallenge() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference studentsRef = _database.child("users");
      DataSnapshot snapshot = await studentsRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> studentsData = snapshot.value as Map<dynamic, dynamic>;
        String? creatorName;

        studentsData.forEach((key, student) {
          if (student["email"] == user.email) {
            creatorName = student["name"];
          }
        });

        if (creatorName != null) {
          DatabaseReference newChallengeRef = _database.child("jobs").push();
          await newChallengeRef.set({
            "name": _nameController.text,
            "description": _descriptionController.text,
            "coupon": _requirementsController.text ?? "No Coupons",
            "deadline": _selectedDeadline?.toIso8601String() ?? "No Ending Date",
            "creator": creatorName,
          });

          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF), //off white,
      appBar: AppBar(
        title: Text(
          "Create Offers",
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
              controller: _nameController, decoration: InputDecoration(
              labelText: 'Offer Name',
              labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
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
            ),),
            SizedBox(
              height: 10,
            ),
            TextField(
              style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
              maxLines: 4,
              controller: _descriptionController, decoration: InputDecoration(
              labelText: 'Description',
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
            ),),
            SizedBox(
              height: 10,
            ),
            TextField(
              style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
              maxLines: 2,

                controller: _requirementsController,

              decoration: InputDecoration(
                labelText: 'Promo Code / Coupons',
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

            SizedBox(height: 10),
            Row(
              children: [
                Text(_selectedDeadline == null ? "Select Date" : "Ends at: ${_selectedDeadline!.toLocal().toString().split(' ')[0]}",style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 10,top: 8),
                  child: GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _selectedDeadline = pickedDate;
                          });
                        }
                      },
                      child: Image.asset("lib/assets/icons/calendar.png",height: 40,)),
                ),
              ],
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: _createChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade400, // Background color changed to red
                foregroundColor: Colors.white, // Text color white for contrast
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10), // Increased size
                minimumSize: Size(200, 0), // Explicitly setting width and height
              ),
              child: Text(
                "Create",
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
