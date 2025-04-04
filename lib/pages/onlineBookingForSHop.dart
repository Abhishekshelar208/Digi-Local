import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OnlineBookingsForShop extends StatefulWidget {
  @override
  _OnlineBookingsForShopState createState() => _OnlineBookingsForShopState();
}

class _OnlineBookingsForShopState extends State<OnlineBookingsForShop> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child("online Bookings");
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  List<Map<String, dynamic>> bookings = [];
  String userEmail = "";
  bool _isProcessing = false;

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
              .where((entry) => entry.value["shopEmail"] == userEmail)
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

  void _updateBookingStatus(String bookingId, String status) {
    _database.child(bookingId).update({"status": status}).then((_) {
      setState(() {
        bookings.firstWhere((booking) => booking["id"] == bookingId)["status"] = status;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status updated to $status")),
      );
    });
  }

  Future<void> _checkAndFetchEntry(String bookingId) async {
    DatabaseReference bookingRef = _database.child(bookingId);
    DatabaseEvent event = await bookingRef.once();

    if (event.snapshot.exists) {
      Map<String, dynamic> bookingData = Map<String, dynamic>.from(event.snapshot.value as Map);
      // Navigate to a new screen to display the booking details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingDetailScreen(
            bookingId: bookingId,
            bookingData: bookingData,
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Booking ID not found.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _scanQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Scan QR Code", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.w600)),
        content: Container(
          height: 300,
          width: 300,
          child: MobileScanner(
            onDetect: (capture) async {
              if (_isProcessing) return;
              _isProcessing = true;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  String uniqueId = barcode.rawValue!;
                  Navigator.pop(context); // Close the scanner dialog
                  await _checkAndFetchEntry(uniqueId);
                  break; // Process first valid barcode
                } else {
                  Fluttertoast.showToast(
                    msg: "Invalid QR code data.",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              }

              _isProcessing = false;
            },
          ),
        ),
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
                          booking["status"] == "Pending"
                              ? Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => _updateBookingStatus(booking["id"], "Available"),
                                child: Text("Available"),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => _updateBookingStatus(booking["id"], "Sold"),
                                child: Text("Sold"),
                              ),
                            ],
                          )
                              : Text(
                            "Status: ${booking["status"]}",
                            style: GoogleFonts.blinker(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanQRCode,
        backgroundColor: Colors.blue,
        child: Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
    );
  }
}

// New screen to display booking details after scanning the QR code
class BookingDetailScreen extends StatelessWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;

  const BookingDetailScreen({Key? key, required this.bookingId, required this.bookingData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Details", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black)),
        backgroundColor: Color(0xffF2F0EF),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Color(0xffF2F0EF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  bookingData["productImage"].isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      bookingData["productImage"],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Icon(Icons.image, size: 100),
                  SizedBox(height: 16),
                  Text(
                    bookingData["productName"],
                    style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Price: ${bookingData["productPrice"]}",
                    style: GoogleFonts.blinker(fontSize: 20),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Items Left: ${bookingData["itemLeft"]}",
                    style: GoogleFonts.blinker(fontSize: 20),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Status: ${bookingData["status"]}",
                    style: GoogleFonts.blinker(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
