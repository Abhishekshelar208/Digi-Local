import 'package:digilocal/pages/requestPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'create_offers.dart';

String formatDeadline(String dateString) {
  try {
    DateTime date = DateTime.parse(dateString); // Parse the date
    return DateFormat('d MMM y').format(date); // Format to "23 Dec"
  } catch (e) {
    return dateString; // Return original if parsing fails
  }
}





class JobsListPage extends StatefulWidget {
  @override
  _JobsListPageState createState() => _JobsListPageState();
}

class _JobsListPageState extends State<JobsListPage> with SingleTickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child("jobs");
  List<Map<String, dynamic>> jobs = [];
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
    _fetchJobs();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchJobs() async {
    _database.onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> jobData = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          jobs = jobData.entries.map((entry) {
            return {
              "id": entry.key,
              "name": entry.value["name"],
              "description": entry.value["description"],
              "requirement": entry.value["requirement"],
              "shopName": entry.value["shopName"],
              "deadline": entry.value["deadline"],
              "creator": entry.value["creator"],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
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
          "Jobs & Vacancies",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: jobs.isEmpty
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
                              Icons.work_outline,
                              size: 64,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            "No Jobs Available",
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Check back later for new opportunities",
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
                                  child: Icon(Icons.work, color: Colors.white, size: 28),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Available Jobs",
                                        style: GoogleFonts.inter(
                                          fontSize: isDesktop ? 32 : 24,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "${jobs.length} job${jobs.length != 1 ? 's' : ''} available",
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

                            // Jobs List
                            ...jobs.asMap().entries.map((entry) {
                              int index = entry.key;
                              var job = entry.value;

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
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                                    child: Icon(Icons.business_center, color: Colors.white, size: 24),
                                                  ),
                                                  SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          job["name"],
                                                          style: GoogleFonts.inter(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.w700,
                                                            color: Color(0xFF0F172A),
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            Icon(Icons.store, size: 16, color: Color(0xFF64748B)),
                                                            SizedBox(width: 6),
                                                            Expanded(
                                                              child: Text(
                                                                job["shopName"],
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 15,
                                                                  color: Color(0xFF64748B),
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 16),
                                              Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF8FAFC),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.calendar_today, size: 18, color: Color(0xFFEF4444)),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      "Apply by: ",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        color: Color(0xFF64748B),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      formatDeadline(job["deadline"]),
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        color: Color(0xFFEF4444),
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                              Container(
                                                width: double.infinity,
                                                height: 44,
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
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    shadowColor: Colors.transparent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => JobsDetailsPage(
                                                          challengeId: job["id"],
                                                          challenge: job,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    "View Details",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateJobsPage()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: Row(
            children: [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Create Job",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





class CreateJobsPage extends StatefulWidget {
  @override
  _CreateJobsPageState createState() => _CreateJobsPageState();
}

class _CreateJobsPageState extends State<CreateJobsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
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
            creatorName = student["email"];
          }
        });

        if (creatorName != null) {
          DatabaseReference newChallengeRef = _database.child("jobs").push();
          await newChallengeRef.set({
            "name": _nameController.text,
            "description": _descriptionController.text,
            "requirement": _requirementsController.text ?? "No Coupons",
            "shopName": _shopNameController.text,
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
          "Create Jobs",
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
              labelText: 'Job Title',
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
                labelText: 'Requirement',
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
            TextField(
              style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
              controller: _shopNameController, decoration: InputDecoration(
              labelText: 'Shop Name',
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
            SizedBox(height: 10),
            Row(
              children: [
                Text(_selectedDeadline == null ? "Select Date" : "Last Date for Apply : ${_selectedDeadline!.toLocal().toString().split(' ')[0]}",style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),),
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








class JobsDetailsPage extends StatefulWidget {
  final String challengeId;
  final Map<String, dynamic> challenge;

  JobsDetailsPage({required this.challengeId, required this.challenge});

  @override
  _JobsDetailsPageState createState() => _JobsDetailsPageState();
}

class _JobsDetailsPageState extends State<JobsDetailsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _studentsRef =
  FirebaseDatabase.instance.ref().child("users");
  final DatabaseReference _challengesRef =
  FirebaseDatabase.instance.ref().child("jobs");
  List<Map<String, String>> joinedUsers = [];
  bool _isUserJoined = false; // Track if the user has joined

  @override
  void initState() {
    super.initState();
    _fetchJoinedUsers();
  }

  Future<void> _fetchJoinedUsers() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DatabaseReference joinedUsersRef =
    _challengesRef.child(widget.challengeId).child("joinedUsers");

    joinedUsersRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        List<Map<String, String>> users = [];
        Map<dynamic, dynamic> usersData =
        event.snapshot.value as Map<dynamic, dynamic>;

        bool isUserJoined = false; // Track if logged-in user is in the list

        usersData.forEach((key, value) {
          users.add({"name": value["name"], "email": value["email"]});

          if (value["email"] == user.email) {
            isUserJoined = true;
          }
        });

        setState(() {
          joinedUsers = users;
          _isUserJoined = isUserJoined; // Update the state
        });
      }
    });
  }

  Future<void> _joinChallenge() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DataSnapshot studentsSnapshot = await _studentsRef.get();
    String? userName;

    if (studentsSnapshot.exists) {
      Map<dynamic, dynamic> studentsData =
      studentsSnapshot.value as Map<dynamic, dynamic>;
      studentsData.forEach((key, student) {
        if (student["email"] == user.email) {
          userName = student["name"];
        }
      });
    }

    if (userName == null) return;

    DatabaseReference challengeRef =
    _challengesRef.child(widget.challengeId).child("joinedUsers");

    DataSnapshot joinedUsersSnapshot = await challengeRef.get();
    if (joinedUsersSnapshot.exists) {
      Map<dynamic, dynamic> joinedUsersData =
      joinedUsersSnapshot.value as Map<dynamic, dynamic>;
      if (joinedUsersData.values.any((userData) => userData["email"] == user.email)) {
        return;
      }
    }

    await challengeRef.push().set({
      "name": userName,
      "email": user.email,
    });

    _fetchJoinedUsers(); // Refresh list after joining
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
          "Job Details",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingValue, vertical: 24.0),
          child: Container(
            constraints: BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Icon
                Center(
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
                      Icons.work,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // Job Title
                Center(
                  child: Text(
                    widget.challenge["name"],
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8),

                // Shop Name
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store, size: 18, color: Color(0xFF64748B)),
                      SizedBox(width: 8),
                      Text(
                        widget.challenge["shopName"],
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),

                // Main Content Card
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
                      // About Job Section
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.description, color: Color(0xFF6366F1), size: 20),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "About Job",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        widget.challenge["description"],
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 24),

                      // Divider
                      Container(
                        height: 1,
                        color: Color(0xFFE2E8F0),
                      ),
                      SizedBox(height: 24),

                      // Requirements Section
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 20),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Who Can Apply",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        widget.challenge["requirement"],
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 24),

                      // Deadline Badge
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFEF4444).withOpacity(0.3), width: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Color(0xFFEF4444), size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Application Deadline",
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Color(0xFFEF4444),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    formatDeadline(widget.challenge["deadline"]),
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFEF4444),
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
                SizedBox(height: 32),

                // Apply Button
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
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestPage(userId: widget.challenge["creator"]),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text(
                          "Apply for this Job",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}






class ChatScreenForCommunity extends StatefulWidget {
  final String challengeId;
  ChatScreenForCommunity({required this.challengeId});

  @override
  _ChatScreenForCommunityState createState() => _ChatScreenForCommunityState();
}

class _ChatScreenForCommunityState extends State<ChatScreenForCommunity> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref();
  final TextEditingController _messageController = TextEditingController();
  String? userName;
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _listenForMessages();
  }

  void _fetchUserName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference studentsRef =
      FirebaseDatabase.instance.ref().child("users");
      DataSnapshot snapshot = await studentsRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> studentsData =
        snapshot.value as Map<dynamic, dynamic>;
        studentsData.forEach((key, student) {
          if (student["email"] == user.email) {
            setState(() {
              userName = student["name"];
            });
          }
        });
      }
    }
  }

  void _listenForMessages() {
    DatabaseReference chatRef =
    _chatRef.child("challenges").child(widget.challengeId).child("chat");
    chatRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        List<Map<String, String>> chatMessages = [];
        Map<dynamic, dynamic> messagesData =
        event.snapshot.value as Map<dynamic, dynamic>;
        messagesData.forEach((key, value) {
          chatMessages.add({
            "sender": value["sender"],
            "message": value["message"],
            "time": value["time"]
          });
        });

        chatMessages.sort((a, b) => a["time"]!.compareTo(b["time"]!));

        setState(() {
          messages = chatMessages;
        });
      }
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || userName == null) return;
    User? user = _auth.currentUser;
    if (user == null) return;

    DatabaseReference chatRef =
    _chatRef.child("challenges").child(widget.challengeId).child("chat");

    await chatRef.push().set({
      "sender": userName,
      "message": _messageController.text.trim(),
      "time": DateTime.now().toIso8601String(),
    });


    _messageController.clear();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF), //off white,
      appBar: AppBar(
        title: Text(
          "Community Chat",
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                bool isMe = message["sender"] == userName;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue.shade400 : Color(0xFF4dc590),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message["sender"]!,
                          style: GoogleFonts.blinker(
                              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          message["message"]!,
                          style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[100]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style:  GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(14),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
