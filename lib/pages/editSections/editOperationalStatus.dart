import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditOperationalStatus extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditOperationalStatus({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditOperationalStatusState createState() => _EditOperationalStatusState();
}

class _EditOperationalStatusState extends State<EditOperationalStatus> {
  late DatabaseReference _shopRef;
  String selectedStatus = "Open";
  TextEditingController reasonController = TextEditingController();
  bool isLoading = false;

  final List<Map<String, dynamic>> statusOptions = [
    {
      'value': 'Open',
      'label': 'Open',
      'icon': Icons.check_circle,
      'color': Colors.green,
      'description': 'Shop is currently open for business'
    },
    {
      'value': 'Closed',
      'label': 'Closed',
      'icon': Icons.cancel,
      'color': Colors.red,
      'description': 'Shop is closed for today'
    },
    {
      'value': 'Temporarily Closed',
      'label': 'Temporarily Closed',
      'icon': Icons.warning,
      'color': Colors.orange,
      'description': 'Shop is temporarily closed (maintenance, holidays, etc.)'
    },
  ];

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    _loadOperationalStatus();
  }

  void _loadOperationalStatus() {
    selectedStatus = widget.shopData['operationalStatus']?.toString() ?? 'Open';
    reasonController.text = widget.shopData['closureReason']?.toString() ?? '';
  }

  Future<void> _saveChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> updates = {
        "operationalStatus": selectedStatus,
      };

      // Only save closure reason if status is not "Open"
      if (selectedStatus != "Open") {
        updates["closureReason"] = reasonController.text.trim();
      } else {
        updates["closureReason"] = ""; // Clear reason when open
      }

      await _shopRef.update(updates);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Operational status updated successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text(
          "Operational Status",
          style: GoogleFonts.blinker(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Card(
                    color: Colors.blue.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Set your shop's current operational status. This helps customers know if you're available.",
                              style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Status Selection
                  Text(
                    "Select Status",
                    style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 12),

                  // Status Options
                  ...statusOptions.map((option) {
                    final isSelected = selectedStatus == option['value'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedStatus = option['value'];
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? option['color'].withOpacity(0.1) : Colors.white,
                          border: Border.all(
                            color: isSelected ? option['color'] : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              option['icon'],
                              color: option['color'],
                              size: 32,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['label'],
                                    style: GoogleFonts.blinker(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    option['description'],
                                    style: GoogleFonts.blinker(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: option['color'],
                                size: 28,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  // Closure Reason (only shown when not Open)
                  if (selectedStatus != "Open") ...[
                    SizedBox(height: 24),
                    Text(
                      "Reason for Closure (Optional)",
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'e.g., Closed for maintenance, Festival holiday, etc.',
                        hintStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 32),

                  // Current Status Display
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.storefront, color: Colors.black54, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Current Status",
                                style: GoogleFonts.blinker(fontSize: 14, color: Colors.black54),
                              ),
                              SizedBox(height: 4),
                              Text(
                                selectedStatus,
                                style: GoogleFonts.blinker(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: selectedStatus == "Open"
                                      ? Colors.green
                                      : selectedStatus == "Closed"
                                          ? Colors.red
                                          : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Save Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        minimumSize: Size(200, 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "Save Changes",
                        style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }
}
