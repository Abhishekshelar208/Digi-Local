import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../designOne/designOne.dart';
import '../designOne/designThree.dart';
import '../designOne/designTwo.dart';
import '../designOne/designfour.dart';
import 'loadingAnimation.dart';

final List<Color> predefinedColors = [
  Colors.teal,
  Colors.teal,
];

class ImprovedShopCreationPage extends StatefulWidget {
  const ImprovedShopCreationPage({super.key, required this.designName});

  final String designName;

  @override
  State<ImprovedShopCreationPage> createState() => _ImprovedShopCreationPageState();
}

class _ImprovedShopCreationPageState extends State<ImprovedShopCreationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Files
  File? _imageFile;
  File? _eventImageFile;
  File? _productImageFile;
  File? _resumeFile;

  // Controllers
  TextEditingController shopnameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController shopEmailController = TextEditingController();
  TextEditingController contactNoController = TextEditingController();
  TextEditingController typesofServicesController = TextEditingController();
  TextEditingController facebookControoler = TextEditingController();
  TextEditingController couponsController = TextEditingController();
  TextEditingController eventTitleController = TextEditingController();
  TextEditingController eventDescriptionController = TextEditingController();
  TextEditingController typesofProductsController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
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

  // Lists
  List<String> servicesList = [];
  List<Map<String, dynamic>> EventsList = [];
  List<Map<String, dynamic>> productsList = [];
  List<Map<String, dynamic>> offersList = [];
  List<String> productTypesList = [];
  List<String> couponList = [];

  bool isLoading = false;
  String? selectedCategory;
  String? selectedSubCategory;
  double? shopLatitude;
  double? shopLongitude;
  String _locationMessage = "Click 'Get Location' to fetch coordinates";
  bool _isLoading = false;

  // Progress tracking
  Map<String, bool> sectionCompletion = {
    'Basic Information': false,
    'Extra Details': false,
    'Services & Products': false,
    'Discounts & Offers': false,
    'Products': false,
    'Upcoming Events': false,
    'Shop Links': false,
    'Location': false,
  };

  final Map<String, List<String>> categories = {
    "Grocery Stores": ["Grocery", "Supermarket", "Fresh Produce", "Vegetables", "Fruits", "Daily Needs", "Food Store"],
    "Restaurants & Cafes": ["Restaurant", "Cafe", "Food", "Eatery", "Fine Dining", "Bakery", "Fast Food", "Coffee Shop"],
    "Fashion & Clothing": ["Clothing", "Fashion", "Apparel", "Boutique", "Footwear", "Accessories", "Designer Wear"],
    "Electronics": ["Electronics", "Gadgets", "Mobile", "Laptop", "TV", "Home Appliances", "Computers", "Tech Store"],
    "Home & Furniture": ["Furniture", "Home Decor", "Interior", "Sofa", "Bed", "Lighting", "Curtains", "Woodwork"],
    "Beauty & Wellness": ["Beauty", "Salon", "Spa", "Skincare", "Cosmetics", "Makeup", "Haircare", "Wellness"],
    "Automobile Services": ["Automobile", "Car Service", "Bike Repair", "Mechanic", "Spare Parts", "Vehicle Maintenance"],
    "Pharmacies": ["Pharmacy", "Medical Store", "Medicines", "Healthcare", "Chemist", "Drugstore"],
    "Sports & Fitness": ["Sports", "Gym", "Fitness", "Workout", "Exercise", "Athletic", "Training", "Sports Gear"],
    "Handicrafts & Art": ["Handicrafts", "Art", "Handmade", "Local Art", "Pottery", "Traditional Crafts", "Artwork"],
    "Pet Shops": ["Pet", "Animal Store", "Pet Food", "Veterinary", "Pets Accessories", "Pet Grooming"],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _tabController.addListener(_updateSectionCompletion);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateSectionCompletion() {
    setState(() {
      // Update completion based on current tab
      switch (_tabController.index) {
        case 0: // Basic Information
          sectionCompletion['Basic Information'] = _imageFile != null &&
              shopnameController.text.isNotEmpty &&
              selectedCategory != null &&
              selectedSubCategory != null &&
              addressController.text.isNotEmpty &&
              shopEmailController.text.isNotEmpty &&
              contactNoController.text.isNotEmpty &&
              yearsofExperienceController.text.isNotEmpty;
          break;
        case 1: // Extra Details
          sectionCompletion['Extra Details'] = shopTimingsController.text.isNotEmpty && googleRatingController.text.isNotEmpty;
          break;
        case 2: // Services & Products
          sectionCompletion['Services & Products'] = servicesList.isNotEmpty && productTypesList.isNotEmpty && couponList.isNotEmpty;
          break;
        case 3: // Discounts & Offers
          sectionCompletion['Discounts & Offers'] = offersList.isNotEmpty;
          break;
        case 4: // Products
          sectionCompletion['Products'] = productsList.isNotEmpty && NoofProductsController.text.isNotEmpty;
          break;
        case 5: // Upcoming Events
          sectionCompletion['Upcoming Events'] = EventsList.isNotEmpty;
          break;
        case 6: // Shop Links
          sectionCompletion['Shop Links'] = _resumeFile != null;
          break;
        case 7: // Location
          sectionCompletion['Location'] = shopLatitude != null && shopLongitude != null;
          break;
      }
    });
  }

  double _calculateProgress() {
    int completedSections = sectionCompletion.values.where((completed) => completed).length;
    return (completedSections / sectionCompletion.length) * 100;
  }

  // Image picker methods
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

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

  void _pickResumeFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _resumeFile = File(result.files.single.path!);
      });
    }
  }

  // Add methods
  void _addSkill() {
    if (typesofServicesController.text.isNotEmpty) {
      setState(() {
        servicesList.add(typesofServicesController.text);
        typesofServicesController.clear();
      });
    }
  }

  void _addSoftSkill() {
    if (typesofProductsController.text.isNotEmpty) {
      setState(() {
        productTypesList.add(typesofProductsController.text);
        typesofProductsController.clear();
      });
    }
  }

  void _addTools() {
    if (couponsController.text.isNotEmpty) {
      setState(() {
        couponList.add(couponsController.text);
        couponsController.clear();
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
          "image": _productImageFile,
          "description": productDescriptionController.text,
          "productprice": productPriceController.text,
          "itemLeft": itemLeftController.text,
          "purchaseLink": purchaseLinkController.text,
        });
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
        offerTitleController.clear();
        offerDescriptionController.clear();
      });
    }
  }

  // Location methods
  Future<void> _getCurrentLocationnn() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        shopLatitude = position.latitude;
        shopLongitude = position.longitude;
      });
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _locationMessage = "Fetching location...";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationMessage = "❌ Location services are disabled. Please enable them.";
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationMessage = "❌ Location permission denied.";
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage = "❌ Location permission permanently denied. Enable it from settings.";
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        shopLatitude = position.latitude;
        shopLongitude = position.longitude;
        _locationMessage = "📍 Latitude: ${position.latitude},\n📍 Longitude: ${position.longitude}";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationMessage = "⚠️ Error fetching location: $e";
        _isLoading = false;
      });
    }
  }

  // Save user data
  void saveUserData() async {
    setState(() {
      isLoading = true;
    });

    await _getCurrentLocationnn();

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

      if (shopLatitude == null || shopLongitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location not fetched. Please try again.")),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

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

      if (_imageFile != null) {
        profilePictureUrl = await _uploadImageToFirebase(_imageFile!, "profile_pictures/${user.uid}/$shopID");
      }

      if (_resumeFile != null) {
        resumeFileUrl = await _uploadImageToFirebase(_resumeFile!, "resumes/${user.uid}");
      }

      List<Map<String, dynamic>> uploadFeatures = [];
      for (var features in EventsList) {
        String imageUrl = "";
        if (features["image"] != null) {
          imageUrl = await _uploadImageToFirebase(
            features["image"],
            "features/${user.uid}/${features["title"]}",
          );
        } else {
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
          "latitude": shopLatitude,
          "longitude": shopLongitude,
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
        },
        "operationalStatus": "Open",
        "closureReason": "",
        "deliverySettings": {
          "available": false,
          "radius": "",
          "minimumOrder": "",
          "deliveryFee": "",
          "timings": "",
        },
        "paymentMethods": ["Cash"],
        "faqs": [],
        "videos": [],
        "shopGallery": [],
        "reviews": [],
        "totalVisits": 0,
        "averageRating": 0.0,
        "totalReviews": 0,
        "verificationStatus": "Unverified",
      };

      await userRef.set(userData);
      await counterRef.set(currentCounter + 1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Shop created successfully!")),
      );

      Widget selectedPage;
      if (widget.designName == "DesignOne") {
        selectedPage = DesignOne(userData: userData);
      } else if (widget.designName == "DesignTwo") {
        selectedPage = DesignTwo(userData: userData);
      } else if (widget.designName == "DesignThree") {
        selectedPage = DesignThree(userData: userData);
      } else if (widget.designName == "DesignFour") {
        selectedPage = DesignFour(userData: userData);
      } else {
        selectedPage = DesignOne(userData: userData);
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

  Future<String> _uploadImageToFirebase(File imageFile, String path) async {
    Reference storageRef = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _calculateProgress();

    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text(
          "Create Shop",
          style: GoogleFonts.blinker(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Progress: ${progress.toStringAsFixed(0)}%",
                      style: GoogleFonts.blinker(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "${sectionCompletion.values.where((v) => v).length}/${sectionCompletion.length} Completed",
                      style: GoogleFonts.blinker(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 8,
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.deepOrangeAccent,
                unselectedLabelColor: Colors.black54,
                indicatorColor: Colors.deepOrangeAccent,
                labelStyle: GoogleFonts.blinker(fontSize: 14, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: "Basic Info"),
                  Tab(text: "Extra Details"),
                  Tab(text: "Services"),
                  Tab(text: "Offers"),
                  Tab(text: "Products"),
                  Tab(text: "Events"),
                  Tab(text: "Links"),
                  Tab(text: "Location"),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicInfoTab(),
          _buildExtraDetailsTab(),
          _buildServicesTab(),
          _buildOffersTab(),
          _buildProductsTab(),
          _buildEventsTab(),
          _buildLinksTab(),
          _buildLocationTab(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Color(0xffF2F0EF),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_tabController.index > 0)
              ElevatedButton(
                onPressed: () {
                  _tabController.animateTo(_tabController.index - 1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text("Previous", style: GoogleFonts.blinker(color: Colors.white, fontSize: 16)),
              ),
            Spacer(),
            if (_tabController.index < 7)
              ElevatedButton(
                onPressed: () {
                  _updateSectionCompletion();
                  _tabController.animateTo(_tabController.index + 1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text("Next", style: GoogleFonts.blinker(color: Colors.white, fontSize: 16)),
              ),
            if (_tabController.index == 7)
              ElevatedButton(
                onPressed: () {
                  if (progress < 100) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please complete all sections before creating shop!")),
                    );
                    return;
                  }
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
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text("Create Shop", style: GoogleFonts.blinker(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  // Tab 1: Basic Information
  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Basic Information", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.black,
                backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? Icon(Icons.add_a_photo, size: 40, color: Colors.white)
                    : null,
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Text("Tap to upload shop image", style: GoogleFonts.blinker(fontSize: 14, color: Colors.black54)),
          ),
          SizedBox(height: 20),
          _buildTextField(shopnameController, "Shop Name", Icons.store),
          _buildDropdown("Main Category", categories.keys.toList(), selectedCategory, (value) {
            setState(() {
              selectedCategory = value;
              selectedSubCategory = null;
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
          _buildTextField(addressController, "Address", Icons.location_on),
          _buildTextField(shopEmailController, "Shop Email", Icons.email),
          _buildTextField(contactNoController, "Contact Number", Icons.phone, keyboardType: TextInputType.number),
          _buildTextField(yearsofExperienceController, "Years of Experience", Icons.business_center, keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  // Tab 2: Extra Details
  Widget _buildExtraDetailsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Extra Details", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 20),
          _buildTextField(shopTimingsController, "Shop Timings (e.g., 9AM - 5PM)", Icons.access_time),
          _buildTextField(googleRatingController, "Google Rating", Icons.star, keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  // Tab 3: Services & Products
  Widget _buildServicesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Services & Products", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 20),
          
          Text("Services Offered", style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTextField(typesofServicesController, "Add Service", Icons.room_service)),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.deepOrangeAccent, size: 35),
                onPressed: _addSkill,
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: List.generate(servicesList.length, (index) {
              return Chip(
                label: Text(servicesList[index], style: GoogleFonts.blinker(color: Colors.white)),
                backgroundColor: Colors.black,
                deleteIcon: Icon(Icons.close, color: Colors.white),
                onDeleted: () {
                  setState(() {
                    servicesList.removeAt(index);
                  });
                },
              );
            }),
          ),
          SizedBox(height: 20),
          
          Text("Product Categories", style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTextField(typesofProductsController, "Add Category", Icons.category)),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.deepOrangeAccent, size: 35),
                onPressed: _addSoftSkill,
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: List.generate(productTypesList.length, (index) {
              return Chip(
                label: Text(productTypesList[index], style: GoogleFonts.blinker(color: Colors.white)),
                backgroundColor: Colors.black,
                deleteIcon: Icon(Icons.close, color: Colors.white),
                onDeleted: () {
                  setState(() {
                    productTypesList.removeAt(index);
                  });
                },
              );
            }),
          ),
          SizedBox(height: 20),
          
          Text("Coupons", style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTextField(couponsController, "Add Coupon", Icons.local_offer)),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.deepOrangeAccent, size: 35),
                onPressed: _addTools,
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: List.generate(couponList.length, (index) {
              return Chip(
                label: Text(couponList[index], style: GoogleFonts.blinker(color: Colors.white)),
                backgroundColor: Colors.black,
                deleteIcon: Icon(Icons.close, color: Colors.white),
                onDeleted: () {
                  setState(() {
                    couponList.removeAt(index);
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Tab 4: Discounts & Offers
  Widget _buildOffersTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Discounts & Offers", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 20),
          _buildTextField(offerTitleController, "Offer Name", Icons.local_offer),
          _buildTextField(offerDescriptionController, "Offer Description", Icons.description),
          Center(
            child: ElevatedButton.icon(
              onPressed: _addExperiences,
              icon: Icon(Icons.add),
              label: Text("Add Offer", style: GoogleFonts.blinker(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: List.generate(offersList.length, (index) {
              return Chip(
                label: Text(offersList[index]["title"], style: GoogleFonts.blinker(color: Colors.white)),
                backgroundColor: Colors.black,
                deleteIcon: Icon(Icons.close, color: Colors.white),
                onDeleted: () {
                  setState(() {
                    offersList.removeAt(index);
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Tab 5: Products
  Widget _buildProductsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Products", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 20),
          _buildTextField(NoofProductsController, "Number of Products", Icons.inventory, keyboardType: TextInputType.number),
          SizedBox(height: 20),
          _buildTextField(productTitleController, "Product Title", Icons.shopping_bag),
          _buildTextField(productDescriptionController, "Product Description", Icons.description),
          _buildTextField(productPriceController, "Price", Icons.attach_money, keyboardType: TextInputType.number),
          _buildTextField(itemLeftController, "Items Left", Icons.inventory_2, keyboardType: TextInputType.number),
          _buildTextField(purchaseLinkController, "Purchase Link", Icons.link),
          SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              label: Text("Upload Product Image", style: GoogleFonts.blinker(fontSize: 16, color: Colors.black87)),
              icon: Icon(Icons.image, color: Colors.deepOrangeAccent, size: 30),
              onPressed: _pickProjectImage,
            ),
          ),
          if (_productImageFile != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_productImageFile!, height: 150, width: 150, fit: BoxFit.cover),
              ),
            ),
          SizedBox(height: 10),
          Center(
            child: ElevatedButton.icon(
              onPressed: _addProjects,
              icon: Icon(Icons.add),
              label: Text("Add Product", style: GoogleFonts.blinker(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: List.generate(productsList.length, (index) {
              return Chip(
                label: Text(productsList[index]["title"], style: GoogleFonts.blinker(color: Colors.white)),
                backgroundColor: Colors.black,
                deleteIcon: Icon(Icons.close, color: Colors.white),
                onDeleted: () {
                  setState(() {
                    productsList.removeAt(index);
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Tab 6: Upcoming Events
  Widget _buildEventsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Upcoming Events", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 20),
          _buildTextField(eventTitleController, "Event Name", Icons.event),
          _buildTextField(eventDescriptionController, "Event Description", Icons.description),
          SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              label: Text("Upload Event Image", style: GoogleFonts.blinker(fontSize: 16, color: Colors.black87)),
              icon: Icon(Icons.image, color: Colors.deepOrangeAccent, size: 30),
              onPressed: _pickAchievementImage,
            ),
          ),
          if (_eventImageFile != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_eventImageFile!, height: 150, width: 150, fit: BoxFit.cover),
              ),
            ),
          SizedBox(height: 10),
          Center(
            child: ElevatedButton.icon(
              onPressed: _addAchievement,
              icon: Icon(Icons.add),
              label: Text("Add Event", style: GoogleFonts.blinker(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: List.generate(EventsList.length, (index) {
              return Chip(
                label: Text(EventsList[index]["title"], style: GoogleFonts.blinker(color: Colors.white)),
                backgroundColor: Colors.black,
                deleteIcon: Icon(Icons.close, color: Colors.white),
                onDeleted: () {
                  setState(() {
                    EventsList.removeAt(index);
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Tab 7: Shop Links
  Widget _buildLinksTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Shop Links", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 20),
          _buildTextField(instagramController, "Instagram", Icons.camera_alt),
          _buildTextField(whatsappController, "WhatsApp Number", Icons.phone),
          _buildTextField(facebookControoler, "Facebook", Icons.facebook),
          SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                TextButton.icon(
                  label: Text("Upload Menu (PDF)", style: GoogleFonts.blinker(fontSize: 18, color: Colors.black87)),
                  icon: Icon(Icons.picture_as_pdf, color: Colors.deepOrangeAccent, size: 35),
                  onPressed: _pickResumeFile,
                ),
                if (_resumeFile != null)
                  Text(
                    path.basename(_resumeFile!.path),
                    style: GoogleFonts.blinker(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 8: Location
  Widget _buildLocationTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Shop Location", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 40),
          Icon(Icons.location_on, size: 100, color: Colors.deepOrangeAccent),
          SizedBox(height: 20),
          Text(
            _locationMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _getCurrentLocation,
            icon: _isLoading ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : Icon(Icons.gps_fixed),
            label: Text(_isLoading ? "Fetching..." : "Get Current Location", style: GoogleFonts.blinker(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          labelText: hint,
          labelStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.black54),
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
            borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.black54),
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
            borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 2),
          ),
        ),
        dropdownColor: Colors.white,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: TextStyle(color: Colors.black87)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
