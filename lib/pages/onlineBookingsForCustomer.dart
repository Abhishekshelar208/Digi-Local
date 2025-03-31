import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OnlineBookingsForCustomer extends StatefulWidget {
  @override
  _OnlineBookingsForCustomerState createState() => _OnlineBookingsForCustomerState();
}

class _OnlineBookingsForCustomerState extends State<OnlineBookingsForCustomer> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child("online Bookings");
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  List<Map<String, dynamic>> bookings = [];
  String userEmail = "";

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
    _fetchUserEmail();
  }

  void _fetchUserEmail() {
    if (_currentUser != null) {
      setState(() {
        userEmail = _currentUser!.email ?? "";
      });
      _fetchBookings();
    }
  }

  Future<void> _fetchBookings() async {
    _database.onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> bookingData = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          bookings = bookingData.entries
              .where((entry) => entry.value["customerEmail"] == userEmail)
              .map((entry) {
            return {
              "id": entry.key,
              "productName": entry.value["productName"] ?? "No Title",
              "productPrice": entry.value["productPrice"] ?? "No Price",
              "itemLeft": entry.value["itemLeft"] ?? "No itemLeft",
              "productImage": entry.value["productImage"] ?? "",
              "shopEmail": entry.value["shopEmail"] ?? "",
              "status": entry.value["status"] ?? "Pending",
            };
          }).toList();
        });
      } else {
        setState(() {
          bookings = [];
        });
      }
    });
  }

  void _showQRCode(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Booking QR Code",style: GoogleFonts.blinker(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),),
        content: SizedBox(
          width: 250, // Ensure a defined width
          height: 250, // Ensure a defined height
          child: Center(
            child: QrImageView(
              backgroundColor: Colors.white,
              data: bookingId,
              version: QrVersions.auto,
              size: 200.0, // This ensures the QR code has a proper size
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close",style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),),
          ),
        ],
      ),

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text(
          "Online Bookings",
          style: GoogleFonts.blinker(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: bookings.isEmpty
          ? Center(
        child: Text(
          "No Bookings Available",
          style: GoogleFonts.blinker(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
      )
          : ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          var booking = bookings[index];
          return Container(
            height: 200,
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              color: boxColors[index % boxColors.length],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    booking["productImage"].isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        booking["productImage"],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Icon(Icons.image, size: 80, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            booking["productName"],
                            style: GoogleFonts.blinker(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Price: ${booking["productPrice"]}",
                            style: GoogleFonts.blinker(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Items Left: ${booking["itemLeft"]}",
                            style: GoogleFonts.blinker(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Status: ${booking["status"]}",
                            style: GoogleFonts.blinker(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.qr_code, color: Colors.white, size: 30),
                      onPressed: () => _showQRCode(booking["id"]),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
