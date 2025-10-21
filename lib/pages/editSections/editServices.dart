import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditServices extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditServices({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditServicesState createState() => _EditServicesState();
}

class _EditServicesState extends State<EditServices> {
  late DatabaseReference _shopRef;
  TextEditingController serviceController = TextEditingController();
  List<String> servicesList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    servicesList = (widget.shopData['services'] as List?)?.map((e) => e.toString()).toList() ?? [];
  }

  void _addService() {
    if (serviceController.text.isNotEmpty) {
      setState(() {
        servicesList.add(serviceController.text);
        serviceController.clear();
      });
    }
  }

  void _removeService(int index) {
    setState(() {
      servicesList.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _shopRef.update({
        "services": servicesList,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Services updated successfully!")),
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
          "Edit Services",
          style: GoogleFonts.blinker(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Services",
                    style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: serviceController,
                          style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                          decoration: InputDecoration(
                            hintText: 'Enter service name',
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
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.black, size: 40),
                        onPressed: _addService,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Current Services (${servicesList.length})",
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: servicesList.isEmpty
                        ? Center(
                            child: Text(
                              "No services added yet",
                              style: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: servicesList.length,
                            itemBuilder: (context, index) {
                              return Card(
                                color: Colors.white,
                                elevation: 2,
                                margin: EdgeInsets.symmetric(vertical: 5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: Icon(Icons.check_circle, color: Colors.green),
                                  title: Text(
                                    servicesList[index],
                                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeService(index),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  SizedBox(height: 20),
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
}
