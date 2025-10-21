import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditAdditionalInfo extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditAdditionalInfo({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditAdditionalInfoState createState() => _EditAdditionalInfoState();
}

class _EditAdditionalInfoState extends State<EditAdditionalInfo> {
  final _formKey = GlobalKey<FormState>();
  late DatabaseReference _shopRef;
  
  TextEditingController googleRatingController = TextEditingController();
  TextEditingController yearsOfExperienceController = TextEditingController();
  TextEditingController noOfProductsController = TextEditingController();
  TextEditingController shopTimingsController = TextEditingController();
  
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    googleRatingController.text = widget.shopData['googleRating']?.toString() ?? '';
    yearsOfExperienceController.text = widget.shopData['yearsofExperience']?.toString() ?? '';
    noOfProductsController.text = widget.shopData['NoofProducts']?.toString() ?? '';
    shopTimingsController.text = widget.shopData['ShopTimings']?.toString() ?? '';
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        await _shopRef.update({
          "googleRating": googleRatingController.text.trim(),
          "yearsofExperience": yearsOfExperienceController.text.trim(),
          "NoofProducts": noOfProductsController.text.trim(),
          "ShopTimings": shopTimingsController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Additional Info updated successfully!")),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text(
          "Edit Additional Info",
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: googleRatingController,
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                      decoration: _inputDecoration('Google Rating'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: yearsOfExperienceController,
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                      decoration: _inputDecoration('Years of Experience'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: noOfProductsController,
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                      decoration: _inputDecoration('No of Products'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: shopTimingsController,
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                      decoration: _inputDecoration('Shop Timings (e.g., 9 AM - 9 PM)'),
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
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
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
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
    );
  }
}
