import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditCoupons extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditCoupons({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditCouponsState createState() => _EditCouponsState();
}

class _EditCouponsState extends State<EditCoupons> {
  late DatabaseReference _shopRef;
  TextEditingController couponController = TextEditingController();
  List<String> couponList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    couponList = (widget.shopData['coupons'] as List?)?.map((e) => e.toString()).toList() ?? [];
  }

  void _addCoupon() {
    if (couponController.text.isNotEmpty) {
      setState(() {
        couponList.add(couponController.text.toUpperCase());
        couponController.clear();
      });
    }
  }

  void _removeCoupon(int index) {
    setState(() {
      couponList.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _shopRef.update({
        "coupons": couponList,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Coupons updated successfully!")),
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
          "Edit Coupons",
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
                    "Add Discount Coupons",
                    style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: couponController,
                          style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'e.g., SAVE20, FLAT50',
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
                        onPressed: _addCoupon,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Active Coupons (${couponList.length})",
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: couponList.isEmpty
                        ? Center(
                            child: Text(
                              "No coupons added yet",
                              style: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: couponList.length,
                            itemBuilder: (context, index) {
                              return Card(
                                color: Colors.white,
                                elevation: 2,
                                margin: EdgeInsets.symmetric(vertical: 5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: Icon(Icons.local_offer, color: Colors.deepOrange),
                                  title: Text(
                                    couponList[index],
                                    style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeCoupon(index),
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
