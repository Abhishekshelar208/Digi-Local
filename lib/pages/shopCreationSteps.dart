import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

// ============================================
// STEP 1: BASIC INFORMATION
// ============================================
class BasicInformationPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final Map<String, dynamic> existingData;

  const BasicInformationPage({
    super.key,
    required this.onComplete,
    required this.existingData,
  });

  @override
  State<BasicInformationPage> createState() => _BasicInformationPageState();
}

class _BasicInformationPageState extends State<BasicInformationPage> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  
  TextEditingController shopnameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController shopEmailController = TextEditingController();
  TextEditingController contactNoController = TextEditingController();
  TextEditingController yearsofExperienceController = TextEditingController();
  
  String? selectedCategory;
  String? selectedSubCategory;

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
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData.isNotEmpty) {
      shopnameController.text = widget.existingData['shopName'] ?? '';
      addressController.text = widget.existingData['address'] ?? '';
      shopEmailController.text = widget.existingData['shopEmail'] ?? '';
      contactNoController.text = widget.existingData['contactNo'] ?? '';
      yearsofExperienceController.text = widget.existingData['yearsofExperience'] ?? '';
      selectedCategory = widget.existingData['category'];
      selectedSubCategory = widget.existingData['subCategory'];
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null && widget.existingData['shopImage'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please upload shop image")),
        );
        return;
      }

      if (selectedCategory == null || selectedSubCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select category and sub-category")),
        );
        return;
      }

      Map<String, dynamic> data = {
        'shopName': shopnameController.text.trim(),
        'address': addressController.text.trim(),
        'shopEmail': shopEmailController.text.trim(),
        'contactNo': contactNoController.text.trim(),
        'yearsofExperience': yearsofExperienceController.text.trim(),
        'category': selectedCategory,
        'subCategory': selectedSubCategory,
        'shopImage': _imageFile,
      };

      widget.onComplete(data);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text("Basic Information", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
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
              Text("Tap to upload shop image", style: GoogleFonts.blinker(fontSize: 14, color: Colors.black54)),
              SizedBox(height: 20),
              _buildTextField(shopnameController, "Shop Name", Icons.store, required: true),
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
              _buildTextField(addressController, "Address", Icons.location_on, required: true),
              _buildTextField(shopEmailController, "Shop Email", Icons.email, required: true),
              _buildTextField(contactNoController, "Contact Number", Icons.phone, keyboardType: TextInputType.number, required: true),
              _buildTextField(yearsofExperienceController, "Years of Experience", Icons.business_center, keyboardType: TextInputType.number, required: true),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Submit & Continue", style: GoogleFonts.blinker(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
        controller: controller,
        keyboardType: keyboardType,
        validator: required ? (value) {
          if (value == null || value.isEmpty) {
            return "This field is required";
          }
          return null;
        } : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          labelText: hint,
          labelStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 2)),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 2)),
        ),
        dropdownColor: Colors.white,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: TextStyle(color: Colors.black87)))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ============================================
// STEP 2: EXTRA DETAILS
// ============================================
class ExtraDetailsPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final Map<String, dynamic> existingData;

  const ExtraDetailsPage({
    super.key,
    required this.onComplete,
    required this.existingData,
  });

  @override
  State<ExtraDetailsPage> createState() => _ExtraDetailsPageState();
}

class _ExtraDetailsPageState extends State<ExtraDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  
  TextEditingController shopTimingsController = TextEditingController();
  TextEditingController googleRatingController = TextEditingController();
  TextEditingController NoofProductsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData.isNotEmpty) {
      shopTimingsController.text = widget.existingData['ShopTimings'] ?? '';
      googleRatingController.text = widget.existingData['googleRating'] ?? '';
      NoofProductsController.text = widget.existingData['NoofProducts'] ?? '';
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> data = {
        'ShopTimings': shopTimingsController.text.trim(),
        'googleRating': googleRatingController.text.trim(),
        'NoofProducts': NoofProductsController.text.trim(),
      };

      widget.onComplete(data);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text("Extra Details", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTextField(shopTimingsController, "Shop Timings (e.g., 9AM - 5PM)", Icons.access_time, required: true),
              _buildTextField(googleRatingController, "Google Rating", Icons.star, keyboardType: TextInputType.number, required: true),
              _buildTextField(NoofProductsController, "Number of Products", Icons.inventory, keyboardType: TextInputType.number, required: true),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Submit & Continue", style: GoogleFonts.blinker(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
        controller: controller,
        keyboardType: keyboardType,
        validator: required ? (value) {
          if (value == null || value.isEmpty) {
            return "This field is required";
          }
          return null;
        } : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          labelText: hint,
          labelStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 2)),
        ),
      ),
    );
  }
}

// ============================================
// STEP 3: SERVICES & PRODUCTS
// ============================================
class ServicesProductsPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final Map<String, dynamic> existingData;

  const ServicesProductsPage({
    super.key,
    required this.onComplete,
    required this.existingData,
  });

  @override
  State<ServicesProductsPage> createState() => _ServicesProductsPageState();
}

class _ServicesProductsPageState extends State<ServicesProductsPage> {
  TextEditingController typesofServicesController = TextEditingController();
  TextEditingController typesofProductsController = TextEditingController();
  TextEditingController couponsController = TextEditingController();

  List<String> servicesList = [];
  List<String> productTypesList = [];
  List<String> couponList = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData.isNotEmpty) {
      servicesList = List<String>.from(widget.existingData['services'] ?? []);
      productTypesList = List<String>.from(widget.existingData['products'] ?? []);
      couponList = List<String>.from(widget.existingData['coupons'] ?? []);
    }
  }

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

  void _submit() {
    if (servicesList.isEmpty || productTypesList.isEmpty || couponList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add at least one item in each category")),
      );
      return;
    }

    Map<String, dynamic> data = {
      'services': servicesList,
      'products': productTypesList,
      'coupons': couponList,
    };

    widget.onComplete(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text("Services & Products", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Services Offered", style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildTextField(typesofServicesController, "Add Service", Icons.room_service)),
                IconButton(icon: Icon(Icons.add_circle, color: Colors.deepOrangeAccent, size: 35), onPressed: _addSkill),
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
                IconButton(icon: Icon(Icons.add_circle, color: Colors.deepOrangeAccent, size: 35), onPressed: _addSoftSkill),
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
                IconButton(icon: Icon(Icons.add_circle, color: Colors.deepOrangeAccent, size: 35), onPressed: _addTools),
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
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Submit & Continue", style: GoogleFonts.blinker(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          labelText: hint,
          labelStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 2)),
        ),
      ),
    );
  }
}

// ============================================
// STEP 4: DISCOUNTS & OFFERS
// ============================================
class DiscountsOffersPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final Map<String, dynamic> existingData;

  const DiscountsOffersPage({
    super.key,
    required this.onComplete,
    required this.existingData,
  });

  @override
  State<DiscountsOffersPage> createState() => _DiscountsOffersPageState();
}

class _DiscountsOffersPageState extends State<DiscountsOffersPage> {
  TextEditingController offerTitleController = TextEditingController();
  TextEditingController offerDescriptionController = TextEditingController();

  List<Map<String, dynamic>> offersList = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData.isNotEmpty && widget.existingData['Offers'] != null) {
      offersList = List<Map<String, dynamic>>.from(widget.existingData['Offers']);
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

  void _submit() {
    if (offersList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add at least one offer")),
      );
      return;
    }

    Map<String, dynamic> data = {
      'Offers': offersList,
    };

    widget.onComplete(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text("Discounts & Offers", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Submit & Continue", style: GoogleFonts.blinker(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          labelText: hint,
          labelStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 2)),
        ),
      ),
    );
  }
}

// ============================================
// STEP 5: PRODUCTS
// ============================================
class ProductsPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final Map<String, dynamic> existingData;

  const ProductsPage({
    super.key,
    required this.onComplete,
    required this.existingData,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  File? _productImageFile;
  
  TextEditingController productTitleController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController itemLeftController = TextEditingController();
  TextEditingController purchaseLinkController = TextEditingController();

  List<Map<String, dynamic>> productsList = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData.isNotEmpty && widget.existingData['Products'] != null) {
      productsList = List<Map<String, dynamic>>.from(widget.existingData['Products']);
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

  void _submit() {
    if (productsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add at least one product")),
      );
      return;
    }

    Map<String, dynamic> data = {
      'Products': productsList,
    };

    widget.onComplete(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text("Products", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Submit & Continue", style: GoogleFonts.blinker(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 2)),
        ),
      ),
    );
  }
}

// ============================================
// STEP 6: UPCOMING EVENTS
// ============================================
class UpcomingEventsPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final Map<String, dynamic> existingData;

  const UpcomingEventsPage({
    super.key,
    required this.onComplete,
    required this.existingData,
  });

  @override
  State<UpcomingEventsPage> createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> {
  File? _eventImageFile;
  
  TextEditingController eventTitleController = TextEditingController();
  TextEditingController eventDescriptionController = TextEditingController();

  List<Map<String, dynamic>> EventsList = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData.isNotEmpty && widget.existingData['Events'] != null) {
      EventsList = List<Map<String, dynamic>>.from(widget.existingData['Events']);
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

  void _submit() {
    if (EventsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add at least one event")),
      );
      return;
    }

    Map<String, dynamic> data = {
      'Events': EventsList,
    };

    widget.onComplete(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text("Upcoming Events", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Submit & Continue", style: GoogleFonts.blinker(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          labelText: hint,
          labelStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 2)),
        ),
      ),
    );
  }
}

// ============================================
// STEP 7: SHOP LINKS
// ============================================
class ShopLinksPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final Map<String, dynamic> existingData;

  const ShopLinksPage({
    super.key,
    required this.onComplete,
    required this.existingData,
  });

  @override
  State<ShopLinksPage> createState() => _ShopLinksPageState();
}

class _ShopLinksPageState extends State<ShopLinksPage> {
  File? _resumeFile;
  
  TextEditingController instagramController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  TextEditingController facebookController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData.isNotEmpty) {
      instagramController.text = widget.existingData['instagram'] ?? '';
      whatsappController.text = widget.existingData['whatsapp'] ?? '';
      facebookController.text = widget.existingData['facebook'] ?? '';
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

  void _submit() {
    if (_resumeFile == null && widget.existingData['menuFile'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload menu PDF")),
      );
      return;
    }

    Map<String, dynamic> data = {
      'instagram': instagramController.text.trim(),
      'whatsapp': whatsappController.text.trim(),
      'facebook': facebookController.text.trim(),
      'menuFile': _resumeFile,
    };

    widget.onComplete(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text("Shop Links", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(instagramController, "Instagram Link", Icons.camera_alt),
            _buildTextField(whatsappController, "WhatsApp Number", Icons.phone),
            _buildTextField(facebookController, "Facebook Link", Icons.facebook),
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
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Submit & Continue", style: GoogleFonts.blinker(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          labelText: hint,
          labelStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 2)),
        ),
      ),
    );
  }
}

// ============================================
// STEP 8: LOCATION
// ============================================
class LocationPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final Map<String, dynamic> existingData;

  const LocationPage({
    super.key,
    required this.onComplete,
    required this.existingData,
  });

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  double? shopLatitude;
  double? shopLongitude;
  String _locationMessage = "Click 'Get Location' to fetch coordinates";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData.isNotEmpty) {
      shopLatitude = widget.existingData['latitude'];
      shopLongitude = widget.existingData['longitude'];
      if (shopLatitude != null && shopLongitude != null) {
        _locationMessage = "📍 Latitude: $shopLatitude,\n📍 Longitude: $shopLongitude";
      }
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

  void _submit() {
    if (shopLatitude == null || shopLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fetch your location first")),
      );
      return;
    }

    Map<String, dynamic> data = {
      'latitude': shopLatitude,
      'longitude': shopLongitude,
    };

    widget.onComplete(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text("Location", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              SizedBox(height: 40),
              if (shopLatitude != null && shopLongitude != null)
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Submit & Complete", style: GoogleFonts.blinker(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
