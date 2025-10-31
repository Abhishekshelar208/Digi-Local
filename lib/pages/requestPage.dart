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

class _RequestPageState extends State<RequestPage> with SingleTickerProviderStateMixin {
  final TextEditingController _requestController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isSubmitting = false;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _requestController.dispose();
    super.dispose();
  }

  void _submitRequest() async {
    String requestText = _requestController.text.trim();

    if (requestText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a message!"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User not logged in!"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String senderEmail = user.email?.toLowerCase() ?? "Unknown";
    DatabaseReference studentsRef = FirebaseDatabase.instance.ref("users");

    // Fetch all students
    DatabaseEvent event = await studentsRef.once();
    if (!event.snapshot.exists) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No users found in the database!"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
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
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Your profile details not found!"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
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
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Shop not found!"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
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

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text("Inquiry sent successfully!"),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    Navigator.pop(context);
  }


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
          "Send Inquiry",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingValue, vertical: 40.0),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Icon
                    Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 1000),
                        curve: Curves.elasticOut,
                        builder: (context, animValue, child) {
                          return Transform.scale(
                            scale: animValue,
                            child: Container(
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
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 32),

                    // Title & Description
                    Text(
                      "Contact the Shop",
                      style: GoogleFonts.inter(
                        fontSize: screenWidth > 800 ? 36 : 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Send your inquiry and the shop will get back to you soon.",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),

                    // Message Card
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Message",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _requestController,
                            maxLines: 8,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type your inquiry here...\n\nFor example: "I am interested in your products. Could you please provide more information about pricing and availability?"',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 15,
                                color: Color(0xFF94A3B8),
                              ),
                              filled: true,
                              fillColor: Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
                              ),
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF6366F1).withOpacity(0.4),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, color: Colors.white, size: 20),
                                  SizedBox(width: 12),
                                  Text(
                                    "Send Inquiry",
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Info Text
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF6366F1),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Your contact information will be shared with the shop owner.",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.w500,
                              ),
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
      ),
    );
  }
}
