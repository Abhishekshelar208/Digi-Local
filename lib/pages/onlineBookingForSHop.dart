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

class _OnlineBookingsForShopState extends State<OnlineBookingsForShop> with SingleTickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child("online Bookings");
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  List<Map<String, dynamic>> bookings = [];
  String userEmail = "";
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _fetchUserEmail();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchUserEmail() {
    if (_currentUser != null) {
      setState(() {
        userEmail = _currentUser!.email ?? "";
      });
      _fetchBookings();
    } else {
      setState(() {
        _isLoading = false;
      });
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
          _isLoading = false;
        });
      } else {
        setState(() {
          bookings = [];
          _isLoading = false;
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
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text("Status updated to $status"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 16),
                  Text(
                    "Scan QR Code",
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFFE2E8F0), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: MobileScanner(
                    onDetect: (capture) async {
                      if (_isProcessing) return;
                      _isProcessing = true;

                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          String uniqueId = barcode.rawValue!;
                          Navigator.pop(context);
                          await _checkAndFetchEntry(uniqueId);
                          break;
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double paddingValue = screenWidth > 800 ? 80.0 : 24.0;
    bool isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Online Bookings",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.qr_code_scanner, color: Colors.white),
              onPressed: _scanQRCode,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 64,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            "No Bookings Available",
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Your bookings will appear here",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: paddingValue, vertical: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Page Header
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF6366F1).withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(Icons.event_available, color: Colors.white, size: 28),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Your Bookings",
                                        style: GoogleFonts.inter(
                                          fontSize: isDesktop ? 32 : 24,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "${bookings.length} total booking${bookings.length != 1 ? 's' : ''}",
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            
                            // Bookings List
                            ...bookings.asMap().entries.map((entry) {
                              int index = entry.key;
                              var booking = entry.value;
                              
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 600 + (index * 100)),
                                builder: (context, animValue, child) {
                                  return Opacity(
                                    opacity: animValue,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - animValue)),
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Color(0xFFE2E8F0), width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFF64748B).withOpacity(0.08),
                                              blurRadius: 20,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Product Image
                                              Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(color: Color(0xFFE2E8F0), width: 2),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(14),
                                                  child: booking["productImage"].isNotEmpty
                                                      ? Image.network(
                                                          booking["productImage"],
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Container(
                                                          color: Color(0xFFF1F5F9),
                                                          child: Icon(
                                                            Icons.image_outlined,
                                                            size: 40,
                                                            color: Color(0xFF94A3B8),
                                                          ),
                                                        ),
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              
                                              // Product Details
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      booking["productName"],
                                                      style: GoogleFonts.inter(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFF0F172A),
                                                      ),
                                                    ),
                                                    SizedBox(height: 12),
                                                    
                                                    // Price & Items
                                                    Container(
                                                      padding: EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFF8FAFC),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Icon(Icons.attach_money, size: 18, color: Color(0xFF10B981)),
                                                              SizedBox(width: 8),
                                                              Text(
                                                                booking["productPrice"],
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: Color(0xFF0F172A),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8),
                                                          Row(
                                                            children: [
                                                              Icon(Icons.inventory_2_outlined, size: 18, color: Color(0xFF6366F1)),
                                                              SizedBox(width: 8),
                                                              Text(
                                                                "Items: ${booking["itemLeft"]}",
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: Color(0xFF0F172A),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 12),
                                                    
                                                    // Status & Actions
                                                    booking["status"] == "Pending"
                                                        ? Row(
                                                            children: [
                                                              Expanded(
                                                                child: Container(
                                                                  height: 44,
                                                                  decoration: BoxDecoration(
                                                                    color: Color(0xFF10B981),
                                                                    borderRadius: BorderRadius.circular(12),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Color(0xFF10B981).withOpacity(0.3),
                                                                        blurRadius: 8,
                                                                        offset: Offset(0, 2),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: Colors.transparent,
                                                                      shadowColor: Colors.transparent,
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(12),
                                                                      ),
                                                                    ),
                                                                    onPressed: () => _updateBookingStatus(booking["id"], "Available"),
                                                                    child: Text(
                                                                      "Available",
                                                                      style: GoogleFonts.inter(
                                                                        fontSize: 15,
                                                                        fontWeight: FontWeight.w600,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(width: 12),
                                                              Expanded(
                                                                child: Container(
                                                                  height: 44,
                                                                  decoration: BoxDecoration(
                                                                    color: Color(0xFFEF4444),
                                                                    borderRadius: BorderRadius.circular(12),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Color(0xFFEF4444).withOpacity(0.3),
                                                                        blurRadius: 8,
                                                                        offset: Offset(0, 2),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: Colors.transparent,
                                                                      shadowColor: Colors.transparent,
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(12),
                                                                      ),
                                                                    ),
                                                                    onPressed: () => _updateBookingStatus(booking["id"], "Sold"),
                                                                    child: Text(
                                                                      "Sold",
                                                                      style: GoogleFonts.inter(
                                                                        fontSize: 15,
                                                                        fontWeight: FontWeight.w600,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : Container(
                                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                            decoration: BoxDecoration(
                                                              color: booking["status"] == "Available" 
                                                                  ? Color(0xFF10B981).withOpacity(0.1)
                                                                  : Color(0xFFEF4444).withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(12),
                                                              border: Border.all(
                                                                color: booking["status"] == "Available"
                                                                    ? Color(0xFF10B981)
                                                                    : Color(0xFFEF4444),
                                                                width: 2,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  booking["status"] == "Available" 
                                                                      ? Icons.check_circle
                                                                      : Icons.sell,
                                                                  size: 20,
                                                                  color: booking["status"] == "Available"
                                                                      ? Color(0xFF10B981)
                                                                      : Color(0xFFEF4444),
                                                                ),
                                                                SizedBox(width: 8),
                                                                Text(
                                                                  "Status: ${booking["status"]}",
                                                                  style: GoogleFonts.inter(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: booking["status"] == "Available"
                                                                        ? Color(0xFF10B981)
                                                                        : Color(0xFFEF4444),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
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
    double screenWidth = MediaQuery.of(context).size.width;
    double paddingValue = screenWidth > 800 ? 80.0 : 24.0;

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Booking Details",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingValue, vertical: 40.0),
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  // Header Icon
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF6366F1).withOpacity(0.4),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.qr_code_2,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Booking Card
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Color(0xFFE2E8F0), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF64748B).withOpacity(0.08),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Product Image
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Color(0xFFE2E8F0), width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: bookingData["productImage"].isNotEmpty
                                ? Image.network(
                                    bookingData["productImage"],
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Color(0xFFF1F5F9),
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 60,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Product Name
                        Text(
                          bookingData["productName"],
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),

                        // Details Section
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(Icons.attach_money, "Price", bookingData["productPrice"], Color(0xFF10B981)),
                              SizedBox(height: 16),
                              _buildDetailRow(Icons.inventory_2_outlined, "Items Left", bookingData["itemLeft"], Color(0xFF6366F1)),
                              SizedBox(height: 16),
                              _buildDetailRow(
                                bookingData["status"] == "Available" ? Icons.check_circle : Icons.sell,
                                "Status",
                                bookingData["status"],
                                bookingData["status"] == "Available" ? Color(0xFF10B981) : Color(0xFFEF4444),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),

                        // Booking ID
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.confirmation_number, color: Color(0xFF6366F1), size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Booking ID: $bookingId",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Color(0xFF6366F1),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
