import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProductTypes extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditProductTypes({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditProductTypesState createState() => _EditProductTypesState();
}

class _EditProductTypesState extends State<EditProductTypes> {
  late DatabaseReference _shopRef;
  TextEditingController productTypeController = TextEditingController();
  List<String> productTypesList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    productTypesList = (widget.shopData['products'] as List?)?.map((e) => e.toString()).toList() ?? [];
  }

  void _addProductType() {
    if (productTypeController.text.isNotEmpty) {
      setState(() {
        productTypesList.add(productTypeController.text);
        productTypeController.clear();
      });
    }
  }

  void _removeProductType(int index) {
    setState(() {
      productTypesList.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _shopRef.update({
        "products": productTypesList,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Product Types updated successfully!")),
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
          "Edit Product Types",
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
                    "Add Product Categories",
                    style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: productTypeController,
                          style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                          decoration: InputDecoration(
                            hintText: 'e.g., Electronics, Clothing',
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
                        onPressed: _addProductType,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Current Product Types (${productTypesList.length})",
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: productTypesList.isEmpty
                        ? Center(
                            child: Text(
                              "No product types added yet",
                              style: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: productTypesList.asMap().entries.map((entry) {
                              return Chip(
                                backgroundColor: Colors.white,
                                label: Text(
                                  entry.value,
                                  style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                                ),
                                deleteIcon: Icon(Icons.close, size: 20),
                                onDeleted: () => _removeProductType(entry.key),
                              );
                            }).toList(),
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
