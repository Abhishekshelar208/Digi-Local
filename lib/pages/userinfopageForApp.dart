import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import '../designOne/designOne.dart';
import '../designOne/designThree.dart';
import '../designOne/designTwo.dart';
import '../designOne/designfour.dart';
import 'loadingAnimation.dart';

final List<Color> predefinedColors = [
  Colors.teal,
  Colors.teal,

];



class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key,required this.designName});

  final String designName;

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  File? _eventImageFile;
  File? _productImageFile;
  File? _resumeFile;




  TextEditingController shopnameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController shopEmailController = TextEditingController();
  TextEditingController contactNoController = TextEditingController();
  TextEditingController typesofServicesController = TextEditingController();
  TextEditingController achievementsController = TextEditingController();
  TextEditingController facebookControoler = TextEditingController();
  TextEditingController githubController = TextEditingController();
  TextEditingController digiLocalController = TextEditingController();
  TextEditingController couponsController = TextEditingController();
  TextEditingController eventTitleController = TextEditingController();
  TextEditingController eventDescriptionController = TextEditingController();
  TextEditingController typesofProductsController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  TextEditingController facebookController = TextEditingController();

  TextEditingController productTitleController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController itemLeftController = TextEditingController();
  TextEditingController purchaseLinkController = TextEditingController();


  TextEditingController offerTitleController = TextEditingController();
  TextEditingController offerDescriptionController = TextEditingController();


  TextEditingController googleRatingController = TextEditingController();
  TextEditingController yearsofExperienceController = TextEditingController();
  TextEditingController NoofProductsController = TextEditingController();
  TextEditingController shopTimingsController = TextEditingController();



  List<String> servicesList = [];
  List<Color> skillColors = [];
  List<Map<String, dynamic>> EventsList = [];
  List<Map<String, dynamic>> productsList = [];
  List<Map<String, dynamic>> offersList = [];

  List<String> productTypesList = [];
  List<Color> softSkillsColors = [];
  int softSkillColorIndex = 0;

  bool isLoading = false;

  String? selectedCategory;
  String? selectedSubCategory;


  List<String> couponList = [];
  List<Color> languageColors = [];
  int languageColorIndex = 0; // To keep track of which color to use for languages


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

  Future<void> _pickAchievementImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _eventImageFile = File(pickedFile.path);
      });
    }
  }




  Future<void> _pickProjectImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _productImageFile = File(pickedFile.path);
      });
    }
  }


  void _addSoftSkill() {
    if (typesofProductsController.text.isNotEmpty) {
      setState(() {
        // Add the soft skill to the list
        productTypesList.add(typesofProductsController.text);

        // Add the color from the predefinedColors list in sequence
        softSkillsColors.add(predefinedColors[softSkillColorIndex]);

        // Move to the next color, reset to 0 if the end of the list is reached
        softSkillColorIndex = (softSkillColorIndex + 1) % predefinedColors.length;

        // Clear the soft skill input field
        typesofProductsController.clear();
      });
    }
  }


  void _addAchievement() {
    if (eventTitleController.text.isNotEmpty) {
      setState(() {
        EventsList.add({
          "title": eventTitleController.text,
          "image": _eventImageFile,
          "description": eventDescriptionController.text,
        });

        // Clear the input fields after adding the achievement
        eventTitleController.clear();
        eventDescriptionController.clear();
        _eventImageFile = null;
      });
    }
  }


  void _addProjects() {
    if (productTitleController.text.isNotEmpty) {
      setState(() {
        productsList.add({
          "title": productTitleController.text,
          // Store the file if provided; if not, leave it as null
          "image": _productImageFile,
          "description": productDescriptionController.text,
          "productprice": productPriceController.text,
          "itemLeft": itemLeftController.text,
          "purchaseLink": purchaseLinkController.text,
        });

        // Clear the input fields after adding the project
        productTitleController.clear();
        productDescriptionController.clear();
        productPriceController.clear();
        itemLeftController.clear();
        purchaseLinkController.clear();
        _productImageFile = null;
      });
    }
  }

  void _addExperiences() {
    if (offerTitleController.text.isNotEmpty) {
      setState(() {
        offersList.add({
          "title": offerTitleController.text,
          "description": offerDescriptionController.text,
        });

        // Clear the input fields after adding the project
        offerTitleController.clear();
        offerDescriptionController.clear();
      });
    }
  }




  void _addTools() {
    if (couponsController.text.isNotEmpty) {
      setState(() {
        // Add the language text to the list
        couponList.add(couponsController.text);

        // Add the color from the predefinedColors list in sequence
        languageColors.add(predefinedColors[languageColorIndex]);

        // Move to the next color, reset to 0 if the end of the list is reached
        languageColorIndex = (languageColorIndex + 1) % predefinedColors.length;

        // Clear the language input field
        couponsController.clear();
      });
    }
  }


  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _pickResumeFile() async {
    // Allow only PDF files
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _resumeFile = File(result.files.single.path!);
      });
    } else {
      // User canceled the picker or no file was selected
      print("No file selected");
    }
  }




  int colorIndex = 0; // Declare a variable to track the color index

  void _addSkill() {
    if (typesofServicesController.text.isNotEmpty) {
      setState(() {
        // Add the skill text to the list
        servicesList.add(typesofServicesController.text);

        // Add the color from the predefinedColors list in sequence
        skillColors.add(predefinedColors[colorIndex]);

        // Move to the next color, reset to 0 if the end of the list is reached
        colorIndex = (colorIndex + 1) % predefinedColors.length;

        // Clear the skill input field
        typesofServicesController.clear();
      });
    }
  }

  void _saveUserInfo() {
    if (_formKey.currentState!.validate()) {
      print("User Info Saved!");
      // Here you can add logic to save user info to a database or backend
    }
  }

  void saveUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in!")),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Validate email format
      String ShopEmail = shopEmailController.text.trim();
      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(ShopEmail)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid email format! Please enter a valid email.")),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Validate contact number format (must be 10 digits)
      String contactNo = contactNoController.text.trim();
      if (!RegExp(r"^\d{10}$").hasMatch(contactNo)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid contact number! It should be exactly 10 digits.")),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Validate required fields
      List<String> missingFields = [];
      if (shopnameController.text.trim().isEmpty) missingFields.add("Shop Name");
      if (addressController.text.trim().isEmpty) missingFields.add("about shop");
      if (shopEmailController.text.trim().isEmpty) missingFields.add("shop email");
      if (contactNoController.text.trim().isEmpty) missingFields.add("contact No");
      if (_imageFile == null) missingFields.add("shop image");
      if (_resumeFile == null) missingFields.add("Menu File");
      if (servicesList.isEmpty) missingFields.add("Services");
      if (productTypesList.isEmpty) missingFields.add("Types of Products");
      if (couponList.isEmpty) missingFields.add("Coupons");
      if (EventsList.isEmpty) missingFields.add("Events");
      if (offersList.isEmpty) missingFields.add("Offers");
      if (productsList.isEmpty) missingFields.add("Products");
      if (user.email!.trim().isEmpty) missingFields.add("Email");

      if (missingFields.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Missing required fields: ${missingFields.join(", ")}")),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      String email = user.email!;
      String profilePictureUrl = "";
      String resumeFileUrl = "";

      DatabaseReference counterRef = FirebaseDatabase.instance.ref("shopCounter");
      DataSnapshot snapshot = await counterRef.get();
      int currentCounter = snapshot.exists ? snapshot.value as int : 0;
      String shopID = "Shop${(currentCounter + 1).toString().padLeft(6, '0')}";

      // Upload profile picture if available
      if (_imageFile != null) {
        //profilePictureUrl = await _uploadImageToFirebase(_imageFile!, "profile_pictures/${user.uid}");
        profilePictureUrl = await _uploadImageToFirebase(_imageFile!, "profile_pictures/${user.uid}/$shopID");
      }

      // Upload resume file if available; ensure it's a PDF
      if (_resumeFile != null) {
        resumeFileUrl = await _uploadImageToFirebase(_resumeFile!, "resumes/${user.uid}");
        // Alternatively, if you have a separate function for file uploads:
        // resumeFileUrl = await _uploadFileToFirebase(_resumeFile!, "resumes/${user.uid}");
      }

      List<Map<String, dynamic>> uploadFeatures = [];
      for (var features in EventsList) {
        String imageUrl = "";
        if (features["image"] != null) {
          imageUrl = await _uploadImageToFirebase(
            features["image"],
            "features/${user.uid}/${features["title"]}",
          );
        }else {
          imageUrl = "https://www.infopedia.ai/no-image.png";
        }
        uploadFeatures.add({
          "title": features["title"],
          "description": features["description"],
          "image": imageUrl,
        });
      }

      List<Map<String, dynamic>> uploadProducts = [];
      for (var products in productsList) {
        String projectImageUrl = "";
        // If a file is provided, upload it; otherwise, use the default image asset path.
        if (products["image"] != null) {
          projectImageUrl = await _uploadImageToFirebase(
            products["image"],
            "products/${user.uid}/${products["title"]}",
          );
        } else {
          projectImageUrl = "https://www.infopedia.ai/no-image.png";
        }
        uploadProducts.add({
          "title": products["title"],
          "description": products["description"],
          "productprice": products["productprice"],
          "purchaseLink": products["purchaseLink"],
          "itemLeft": products["itemLeft"],
          "image": projectImageUrl,
          "likes": 0,
          "dislikes": 0,
        });
      }

      List<Map<String, dynamic>> uploadOffers = [];
      for (var offers in offersList) {
        uploadOffers.add({
          "title": offers["title"],
          "description": offers["description"],
        });
      }




      DatabaseReference userRef = FirebaseDatabase.instance.ref("DigiLocal/$shopID");

      Map<String, dynamic> userData = {
        "selectedDesign": widget.designName.toString(),
        "shopInfo": {
          "shopName": shopnameController.text.trim(),
          "address": addressController.text.trim(),
          "shopEmail": shopEmailController.text.trim(),
          "ContactNo": contactNoController.text.trim(),
          "shopImage": profilePictureUrl,
        },
        "category": selectedCategory,
        "subCategory": selectedSubCategory,
        "ShopTimings": shopTimingsController.text.trim(),
        "googleRating": googleRatingController.text.trim(),
        "yearsofExperience": yearsofExperienceController.text.trim(),
        "NoofProducts": NoofProductsController.text.trim(),
        "services": servicesList,
        "products": productTypesList,
        "coupons": couponList,
        "menuFile": resumeFileUrl,
        "Events": uploadFeatures,
        "Offers": uploadOffers,
        "Products": uploadProducts,
        "accountLinks": {
          "email": email.trim(),
          "facebook": facebookControoler.text.trim().isEmpty ? "https://www.linkedin.com/feed/" : facebookControoler.text.trim(),
          "instagram": instagramController.text.trim().isEmpty ? "https://instagram.com/" : instagramController.text.trim(),
          "whatsapp": whatsappController.text.trim().isEmpty ? "https://web.whatsapp.com/" : whatsappController.text.trim(),
          "digiLocal": digiLocalController.text.trim(),
        },
      };

      await userRef.set(userData);
      await counterRef.set(currentCounter + 1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User data saved successfully!")),
      );

      Widget selectedPage;
      if (widget.designName == "DesignOne") {
        selectedPage = DesignOne(userData: userData, );
      } else if (widget.designName == "DesignTwo") {
        selectedPage = DesignTwo(userData: userData, );
      } else if (widget.designName == "DesignThree") {
        selectedPage = DesignThree(userData: userData);
      } else if (widget.designName == "DesignFour") {
        selectedPage = DesignFour(userData: userData);
      } else {
        // Fallback to a default design page if none match
        selectedPage = DesignOne(userData: userData,);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => selectedPage,
        ),
      );
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



// Function to upload image to Firebase Storage and return download URL
  Future<String> _uploadImageToFirebase(File imageFile, String path) async {
    Reference storageRef = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF), //off white
      appBar: AppBar(
        title: Text(
          "Shop Profile",
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.black,
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? Icon(Icons.home, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              _buildTextField(shopnameController, "Shop Name", Icons.person),
              SizedBox(height: 10),
              _buildDropdown("Main Category", categories.keys.toList(), selectedCategory,
                      (value) {
                    setState(() {
                      selectedCategory = value;
                      selectedSubCategory = null; // Reset sub-category when main category changes
                    });
                  }),
              SizedBox(height: 10),
              _buildDropdown(
                "Sub-Category",
                selectedCategory != null ? categories[selectedCategory]! : [],
                selectedSubCategory,
                    (value) {
                  setState(() {
                    selectedSubCategory = value;
                  });
                },
              ),
              _buildTextField(addressController, "Address", Icons.book),
              _buildTextField(shopEmailController, "Email", Icons.account_balance),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: yearsofExperienceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: Colors.black54),
                  labelText: 'Years of Experience',
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
                ),
              ),
              SizedBox(
                height: 10,
              ),
              _buildTextField(contactNoController, "Contact No", Icons.date_range, keyboardType: TextInputType.number),



              SizedBox(
                height: 20,
              ),
              Text("Extra Details", style: GoogleFonts.blinker(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),

              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: shopTimingsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: Colors.black54),
                  labelText: 'Shop Timings (Ex: 9AM - 5PM)',
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
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(typesofServicesController, "Services Offered", Icons.star),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.black, size: 35),
                    onPressed: _addSkill,
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: List.generate(servicesList.length, (index) {
                  return Chip(
                    label: Text(servicesList[index], style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color:  Colors.white),),
                    backgroundColor: Colors.black,
                    deleteIcon: Icon(Icons.close, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100), // Apply the border radius here
                    ),
                    onDeleted: () {
                      setState(() {
                        servicesList.removeAt(index);
                        skillColors.removeAt(index);
                      });
                    },
                  );
                }),
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(typesofProductsController, "Products Category", Icons.accessibility),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.black, size: 35),
                    onPressed: _addSoftSkill,
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: List.generate(productTypesList.length, (index) {
                  return Chip(
                    label: Text(productTypesList[index], style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color:  Colors.white),),
                    // backgroundColor: softSkillsColors[index],  if you want multiple colors
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100), // Apply the border radius here
                    ),
                    deleteIcon: Icon(Icons.close, color: Colors.white),
                    onDeleted: () {
                      setState(() {
                        productTypesList.removeAt(index);
                        softSkillsColors.removeAt(index);
                      });
                    },
                  );
                }),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(couponsController, "Coupons", Icons.language),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.black, size: 35),
                    onPressed: _addTools,
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: List.generate(couponList.length, (index) {
                  return Chip(
                    label: Text(couponList[index], style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color:  Colors.white),),
                    // backgroundColor: languageColors[index],
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100), // Border radius of 100
                    ),
                    deleteIcon: Icon(Icons.close, color: Colors.white),
                    onDeleted: () {
                      setState(() {
                        couponList.removeAt(index);
                        languageColors.removeAt(index);
                      });
                    },
                  );
                }),
              ),
              SizedBox(
                height: 20,
              ),
              Text("Discounts & Offers", style: GoogleFonts.blinker(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: googleRatingController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: Colors.black54),
                  labelText: 'Google Rating',
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
                ),
              ),
              SizedBox(
                height: 10,
              ),
              _buildTextField(offerTitleController, "Offer Name", Icons.emoji_events),
              _buildTextField(offerDescriptionController, "Offer Description", Icons.description),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.black, size: 35),
                onPressed: _addExperiences,
              ),

              // Displaying added achievements as chips
              Wrap(
                spacing: 8,
                children: List.generate(offersList.length, (index) {
                  return Chip(
                    label: Text(offersList[index]["title"], style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color:  Colors.white),),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    deleteIcon: Icon(Icons.close, color: Colors.white),
                    onDeleted: () {
                      setState(() {
                        offersList.removeAt(index);
                      });
                    },
                  );
                }),
              ),
              SizedBox(
                height: 20,
              ),
              Text("Products", style: GoogleFonts.blinker(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: NoofProductsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: Colors.black54),
                  labelText: 'No of Products',
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
                ),
              ),
              SizedBox(
                height: 10,
              ),
              _buildTextField(productTitleController, "Product Title", Icons.emoji_events),
              _buildTextField(productDescriptionController, "Product Description", Icons.description),
              _buildTextField(productPriceController, "Price", Icons.description),
              _buildTextField(itemLeftController, "Item Left", Icons.description, keyboardType: TextInputType.number),
              _buildTextField(purchaseLinkController, "Purchase Link", Icons.link),
              FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      label: Text("Upload Product Image",style: GoogleFonts.blinker(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54)),
                      icon: Icon(Icons.image, color: Colors.black54, size: 35),
                      onPressed: _pickProjectImage,
                    ),
                    _productImageFile != null
                        ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_productImageFile!, height: 100, width: 100, fit: BoxFit.cover))
                        : Container(),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.black, size: 35),
                onPressed: _addProjects,
              ),

              // Displaying added achievements as chips
              Wrap(
                spacing: 8,
                children: List.generate(productsList.length, (index) {
                  return Chip(
                    label: Text(productsList[index]["title"], style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color:  Colors.white),),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    deleteIcon: Icon(Icons.close, color: Colors.white),
                    onDeleted: () {
                      setState(() {
                        productsList.removeAt(index);
                      });
                    },
                  );
                }),
              ),


              SizedBox(
                height: 20,
              ),
              Text("Upcoming Events", style: GoogleFonts.blinker(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
              _buildTextField(eventTitleController, "Event Name", Icons.emoji_events),
              _buildTextField(eventDescriptionController, "Event Description", Icons.description),
              FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      label: Text("Upload Event Image",style: GoogleFonts.blinker(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54)),
                      icon: Icon(Icons.image, color: Colors.black54, size: 35),
                      onPressed: _pickAchievementImage,
                    ),
                    _eventImageFile != null
                        ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_eventImageFile!, height: 100, width: 100, fit: BoxFit.cover))
                        : Container(),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.black, size: 35),
                onPressed: _addAchievement,
              ),




              // Displaying added achievements as chips
              Wrap(
                spacing: 8,
                children: List.generate(EventsList.length, (index) {
                  return Chip(
                    label: Text(EventsList[index]["title"], style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color:  Colors.white),),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    deleteIcon: Icon(Icons.close, color: Colors.white),
                    onDeleted: () {
                      setState(() {
                        EventsList.removeAt(index);
                      });
                    },
                  );
                }),
              ),

              SizedBox(
                height: 20,
              ),

              Text("Shops Links", style: GoogleFonts.blinker(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),


              // _buildTextField(githubController, "GitHub", Icons.code),
              _buildTextField(instagramController, "Instagram", Icons.code),
              _buildTextField(whatsappController, "WhatsApp No", Icons.numbers),
              _buildTextField(facebookControoler, "Facebook", Icons.linked_camera),

              FittedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      label: Text("Upload Menu",style: GoogleFonts.blinker(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54)),
                      icon: Icon(Icons.picture_as_pdf, color: Colors.black54, size: 35),
                      onPressed: _pickResumeFile, // Your function to pick a PDF file
                    ),
                    _resumeFile != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:  Center(
                        child: Text(
                          path.basename(_resumeFile!.path),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.blinker(
                            fontSize: 16,
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                        : Container(),
                  ],
                ),
              ),


              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoadingScreen(
                        onFinish: () {
                          saveUserData();
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Create"),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "This field cannot be empty";
          }
          if (isEmail && !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}\$").hasMatch(value)) {
            return "Enter a valid email address";
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          labelText: hint,
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





