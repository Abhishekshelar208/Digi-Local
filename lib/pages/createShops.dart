import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:digilocal/pages/home_pageforStudent.dart';

class CreateUserID extends StatefulWidget {
  @override
  _CreateUserIDState createState() => _CreateUserIDState();
}

class _CreateUserIDState extends State<CreateUserID> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  String? selectedCategory;
  String? selectedSubCategory;
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;

  // Define main categories and their sub-categories
  final Map<String, List<String>> categories = {
    "Grocery Stores": [
      "Grocery",
      "Supermarket",
      "Fresh Produce",
      "Vegetables",
      "Fruits",
      "Daily Needs",
      "Food Store"
    ],
    "Restaurants & Cafes": [
      "Restaurant",
      "Cafe",
      "Food",
      "Eatery",
      "Fine Dining",
      "Bakery",
      "Fast Food",
      "Coffee Shop"
    ],
    "Fashion & Clothing": [
      "Clothing",
      "Fashion",
      "Apparel",
      "Boutique",
      "Footwear",
      "Accessories",
      "Designer Wear"
    ],
    "Electronics": [
      "Electronics",
      "Gadgets",
      "Mobile",
      "Laptop",
      "TV",
      "Home Appliances",
      "Computers",
      "Tech Store"
    ],
    "Home & Furniture": [
      "Furniture",
      "Home Decor",
      "Interior",
      "Sofa",
      "Bed",
      "Lighting",
      "Curtains",
      "Woodwork"
    ],
    "Beauty & Wellness": [
      "Beauty",
      "Salon",
      "Spa",
      "Skincare",
      "Cosmetics",
      "Makeup",
      "Haircare",
      "Wellness"
    ],
    "Automobile Services": [
      "Automobile",
      "Car Service",
      "Bike Repair",
      "Mechanic",
      "Spare Parts",
      "Vehicle Maintenance"
    ],
    "Pharmacies": [
      "Pharmacy",
      "Medical Store",
      "Medicines",
      "Healthcare",
      "Chemist",
      "Drugstore"
    ],
    "Sports & Fitness": [
      "Sports",
      "Gym",
      "Fitness",
      "Workout",
      "Exercise",
      "Athletic",
      "Training",
      "Sports Gear"
    ],
    "Handicrafts & Art": [
      "Handicrafts",
      "Art",
      "Handmade",
      "Local Art",
      "Pottery",
      "Traditional Crafts",
      "Artwork"
    ],
    "Pet Shops": [
      "Pet",
      "Animal Store",
      "Pet Food",
      "Veterinary",
      "Pets Accessories",
      "Pet Grooming"
    ],
  };

  @override
  void initState() {
    super.initState();
    _checkIfUserExists();
  }

  Future<void> _checkIfUserExists() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    String userEmail = user.email ?? "";

    DatabaseEvent event = await _database.child("users").once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      Map<dynamic, dynamic> students = snapshot.value as Map<dynamic, dynamic>;

      for (var key in students.keys) {
        var student = students[key];
        if (student["email"] == userEmail) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreenForStdudent()),
          );
          return;
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;
    try {
      String uid = _auth.currentUser!.uid;
      Reference storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$uid.jpg');
      await storageRef.putFile(_imageFile!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Image Upload Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: $e")),
      );
      return null;
    }
  }

  Future<void> _createAccount() async {
    if (nameController.text.isEmpty ||
        contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = await _uploadImage();
      String studentId = contactController.text;
      String uid = _auth.currentUser!.uid;

      await _database.child("users").child(studentId).set({
        "name": nameController.text,
        "contactNo": studentId,
        // "category": selectedCategory,
        // "subCategory": selectedSubCategory,
        "shopPic": imageUrl ?? "",
        "email": _auth.currentUser!.email,
        "uid": uid,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreenForStdudent()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create account: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xffF2F0EF), //off white
              Color(0xffF2F0EF), //off white
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Text(
                  "Create Account",
                  style: GoogleFonts.blinker(
                    color: Colors.black,
                    fontSize: 44,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 60),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : AssetImage("lib/assets/images/finaluser.jpg") as ImageProvider,
                    child: _imageFile == null
                        ? Icon(Icons.camera_alt, size: 30, color: Colors.transparent)
                        : null,
                  ),
                ),
                SizedBox(height: 40),
                _buildTextField(nameController, "Full Name"),
                SizedBox(height: 10),
                _buildTextField(contactController, "Contact No"),
                SizedBox(height: 10),
                // _buildDropdown("Main Category", categories.keys.toList(), selectedCategory,
                //         (value) {
                //       setState(() {
                //         selectedCategory = value;
                //         selectedSubCategory = null; // Reset sub-category when main category changes
                //       });
                //     }),
                // SizedBox(height: 10),
                // _buildDropdown(
                //   "Sub-Category",
                //   selectedCategory != null ? categories[selectedCategory]! : [],
                //   selectedSubCategory,
                //       (value) {
                //     setState(() {
                //       selectedSubCategory = value;
                //     });
                //   },
                // ),
                SizedBox(height: 60),
                _isLoading
                    ? Center(
                  child: Lottie.asset(
                    'lib/assets/lottieAnimations/newTimer.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                )
                    : Center(
                  child: ElevatedButton(
                    onPressed: _createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      minimumSize: Size(200, 0),
                    ),
                    child: Text(
                      "Get Started",
                      style: GoogleFonts.blinker(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
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
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      cursorColor: Colors.black,
      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
        hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
        labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      dropdownColor: Colors.white,
      iconEnabledColor: Colors.black54,
      items: items
          .map((item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(color: Colors.black54),
        ),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }
}