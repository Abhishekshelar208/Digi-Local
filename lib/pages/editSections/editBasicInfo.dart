import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditBasicInfo extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditBasicInfo({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditBasicInfoState createState() => _EditBasicInfoState();
}

class _EditBasicInfoState extends State<EditBasicInfo> {
  final _formKey = GlobalKey<FormState>();
  late DatabaseReference _shopRef;

  TextEditingController shopNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController shopEmailController = TextEditingController();
  TextEditingController contactNoController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();

  File? _imageFile;
  String? existingImageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    _loadData();
  }

  void _loadData() {
    final shopInfo = (widget.shopData['shopInfo'] as Map?)?.cast<String, dynamic>() ?? {};
    shopNameController.text = shopInfo['shopName']?.toString() ?? '';
    addressController.text = shopInfo['address']?.toString() ?? '';
    shopEmailController.text = shopInfo['shopEmail']?.toString() ?? '';
    contactNoController.text = shopInfo['ContactNo']?.toString() ?? '';
    latitudeController.text = shopInfo['latitude']?.toString() ?? '';
    longitudeController.text = shopInfo['longitude']?.toString() ?? '';
    existingImageUrl = shopInfo['shopImage']?.toString();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return existingImageUrl;
    try {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('shop_images/${widget.shopId}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(_imageFile!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Image Upload Error: $e");
      return existingImageUrl;
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        String? imageUrl = await _uploadImage();

        Map<String, dynamic> updatedData = {
          "shopInfo/shopName": shopNameController.text.trim(),
          "shopInfo/address": addressController.text.trim(),
          "shopInfo/shopEmail": shopEmailController.text.trim(),
          "shopInfo/ContactNo": contactNoController.text.trim(),
          "shopInfo/latitude": latitudeController.text.trim(),
          "shopInfo/longitude": longitudeController.text.trim(),
          "shopInfo/shopImage": imageUrl,
        };

        await _shopRef.update(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Basic Info updated successfully!")),
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
          "Edit Basic Info",
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
                    // Shop Image
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (existingImageUrl != null ? NetworkImage(existingImageUrl!) : null) as ImageProvider?,
                        child: _imageFile == null && existingImageUrl == null
                            ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[600])
                            : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("Tap to change image", style: GoogleFonts.blinker(color: Colors.grey[600], fontSize: 14)),
                    SizedBox(height: 30),

                    // Shop Name
                    TextFormField(
                      controller: shopNameController,
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                      decoration: _inputDecoration('Shop Name'),
                      validator: (value) => value?.isEmpty ?? true ? "Required" : null,
                    ),
                    SizedBox(height: 15),

                    // Address
                    TextFormField(
                      controller: addressController,
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                      decoration: _inputDecoration('Address'),
                      maxLines: 2,
                      validator: (value) => value?.isEmpty ?? true ? "Required" : null,
                    ),
                    SizedBox(height: 15),

                    // Shop Email
                    TextFormField(
                      controller: shopEmailController,
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                      decoration: _inputDecoration('Shop Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 15),

                    // Contact Number
                    TextFormField(
                      controller: contactNoController,
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                      decoration: _inputDecoration('Contact Number'),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 15),

                    // Latitude
                    TextFormField(
                      controller: latitudeController,
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                      decoration: _inputDecoration('Latitude'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 15),

                    // Longitude
                    TextFormField(
                      controller: longitudeController,
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                      decoration: _inputDecoration('Longitude'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 40),

                    // Save Button
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
