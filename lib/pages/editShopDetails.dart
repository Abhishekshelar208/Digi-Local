import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class EditShopPage extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditShopPage({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditShopPageState createState() => _EditShopPageState();
}

class _EditShopPageState extends State<EditShopPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _shopRef;

  // Controllers
  TextEditingController shopNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController shopEmailController = TextEditingController();
  TextEditingController contactNoController = TextEditingController();
  TextEditingController typesofServicesController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  TextEditingController digiLocalController = TextEditingController();
  TextEditingController couponsController = TextEditingController();
  TextEditingController eventTitleController = TextEditingController();
  TextEditingController eventDescriptionController = TextEditingController();
  TextEditingController typesofProductsController = TextEditingController();
  TextEditingController productTitleController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController purchaseLinkController = TextEditingController();
  TextEditingController offerTitleController = TextEditingController();
  TextEditingController offerDescriptionController = TextEditingController();
  TextEditingController googleRatingController = TextEditingController();
  TextEditingController yearsOfExperienceController = TextEditingController();
  TextEditingController noOfProductsController = TextEditingController();
  TextEditingController shopTimingsController = TextEditingController();

  // Files
  File? _imageFile;
  File? _eventImageFile;
  File? _productImageFile;
  File? _resumeFile;

  // Lists
  List<String> servicesList = [];
  List<String> productTypesList = [];
  List<String> couponList = [];
  List<Map<String, dynamic>> eventsList = [];
  List<Map<String, dynamic>> productsList = [];
  List<Map<String, dynamic>> offersList = [];

  // Category
  String? selectedCategory;
  String? selectedSubCategory;
  final Map<String, List<String>> categories = {
    "Grocery Stores": [
      "Grocery", "Supermarket", "Fresh Produce", "Vegetables", "Fruits", "Daily Needs", "Food Store"
    ],
    "Restaurants & Cafes": [
      "Restaurant", "Cafe", "Food", "Eatery", "Cake Shop", "Fine Dining", "Bakery", "Fast Food", "Coffee Shop"
    ],
    "Fashion & Clothing": [
      "Clothing", "Fashion", "Apparel", "Boutique", "Footwear", "Accessories", "Designer Wear"
    ],
    "Electronics": [
      "Electronics", "Gadgets", "Mobile", "Laptop", "TV", "Home Appliances", "Computers", "Tech Store"
    ],
    "Home & Furniture": [
      "Furniture", "Home Decor", "Interior", "Sofa", "Bed", "Lighting", "Curtains", "Woodwork"
    ],
    "Beauty & Wellness": [
      "Beauty", "Salon", "Spa", "Skincare", "Cosmetics", "Makeup", "Haircare", "Wellness"
    ],
    "Automobile Services": [
      "Automobile", "Car Service", "Bike Repair", "Mechanic", "Spare Parts", "Vehicle Maintenance"
    ],
    "Pharmacies": [
      "Pharmacy", "Medical Store", "Medicines", "Healthcare", "Chemist", "Drugstore"
    ],
    "Sports & Fitness": [
      "Sports", "Gym", "Fitness", "Workout", "Exercise", "Athletic", "Training", "Sports Gear"
    ],
    "Handicrafts & Art": [
      "Handicrafts", "Art", "Handmade", "Gift Shop", "Local Art", "Pottery", "Traditional Crafts", "Artwork"
    ],
    "Pet Shops": [
      "Pet", "Animal Store", "Pet Food", "Veterinary", "Pets Accessories", "Pet Grooming"
    ],

    // ... (other categories same as in your create page)
  };

  bool isLoading = false;
  bool isImageChanged = false;
  bool isMenuFileChanged = false;

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    _loadShopData();
  }

  void _loadShopData() {
    // Safely cast the shopInfo and accountLinks maps
    final shopInfo = (widget.shopData['shopInfo'] as Map?)?.cast<String, dynamic>() ?? {};
    final accountLinks = (widget.shopData['accountLinks'] as Map?)?.cast<String, dynamic>() ?? {};

    // Basic info
    shopNameController.text = shopInfo['shopName']?.toString() ?? '';
    addressController.text = shopInfo['address']?.toString() ?? '';
    shopEmailController.text = shopInfo['shopEmail']?.toString() ?? '';
    contactNoController.text = shopInfo['ContactNo']?.toString() ?? '';

    // Social links
    facebookController.text = accountLinks['facebook']?.toString() ?? '';
    instagramController.text = accountLinks['instagram']?.toString() ?? '';
    whatsappController.text = accountLinks['whatsapp']?.toString() ?? '';
    digiLocalController.text = accountLinks['digiLocal']?.toString() ?? '';

    // Other fields
    googleRatingController.text = widget.shopData['googleRating']?.toString() ?? '';
    yearsOfExperienceController.text = widget.shopData['yearsofExperience']?.toString() ?? '';
    noOfProductsController.text = widget.shopData['NoofProducts']?.toString() ?? '';
    shopTimingsController.text = widget.shopData['ShopTimings']?.toString() ?? '';

    // Safely cast lists with proper parentheses
    servicesList = (widget.shopData['services'] as List?)?.map((e) => e.toString()).toList() ?? [];
    productTypesList = (widget.shopData['products'] as List?)?.map((e) => e.toString()).toList() ?? [];
    couponList = (widget.shopData['coupons'] as List?)?.map((e) => e.toString()).toList() ?? [];

    // Safely cast event, product, and offer lists
    eventsList = (widget.shopData['Events'] as List?)?.map((e) => (e as Map).cast<String, dynamic>()).toList() ?? [];
    productsList = (widget.shopData['Products'] as List?)?.map((e) => (e as Map).cast<String, dynamic>()).toList() ?? [];
    offersList = (widget.shopData['Offers'] as List?)?.map((e) => (e as Map).cast<String, dynamic>()).toList() ?? [];

    // Categories
    selectedCategory = widget.shopData['category']?.toString();
    selectedSubCategory = widget.shopData['subCategory']?.toString();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        isImageChanged = true;
      });
    }
  }

  Future<void> _pickEventImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _eventImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickProductImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _productImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickResumeFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _resumeFile = File(result.files.single.path!);
        isMenuFileChanged = true;
      });
    }
  }

  void _addService() {
    if (typesofServicesController.text.isNotEmpty) {
      setState(() {
        servicesList.add(typesofServicesController.text);
        typesofServicesController.clear();
      });
    }
  }

  void _removeService(int index) {
    setState(() {
      servicesList.removeAt(index);
    });
  }

  void _addProductType() {
    if (typesofProductsController.text.isNotEmpty) {
      setState(() {
        productTypesList.add(typesofProductsController.text);
        typesofProductsController.clear();
      });
    }
  }

  void _removeProductType(int index) {
    setState(() {
      productTypesList.removeAt(index);
    });
  }

  void _addCoupon() {
    if (couponsController.text.isNotEmpty) {
      setState(() {
        couponList.add(couponsController.text);
        couponsController.clear();
      });
    }
  }

  void _removeCoupon(int index) {
    setState(() {
      couponList.removeAt(index);
    });
  }

  void _addEvent() {
    if (eventTitleController.text.isNotEmpty) {
      setState(() {
        eventsList.add({
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

  void _removeEvent(int index) {
    setState(() {
      eventsList.removeAt(index);
    });
  }

  void _addProduct() {
    if (productTitleController.text.isNotEmpty) {
      setState(() {
        productsList.add({
          "title": productTitleController.text,
          "image": _productImageFile,
          "description": productDescriptionController.text,
          "productprice": productPriceController.text,
          "purchaseLink": purchaseLinkController.text,
        });
        productTitleController.clear();
        productDescriptionController.clear();
        productPriceController.clear();
        purchaseLinkController.clear();
        _productImageFile = null;
      });
    }
  }

  void _removeProduct(int index) {
    setState(() {
      productsList.removeAt(index);
    });
  }

  void _addOffer() {
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

  void _removeOffer(int index) {
    setState(() {
      offersList.removeAt(index);
    });
  }

  Future<String> _uploadImageToFirebase(File file, String path) async {
    // Implement your Firebase Storage upload logic here
    // Return the download URL
    return "https://example.com/image.jpg";
  }

  Future<void> _updateShopData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        User? user = _auth.currentUser;
        if (user == null) throw Exception("User not logged in");

        String? profilePictureUrl;
        if (isImageChanged && _imageFile != null) {
          profilePictureUrl = await _uploadImageToFirebase(
            _imageFile!,
            "profile_pictures/${user.uid}/${widget.shopId}",
          );
        }

        String? resumeFileUrl;
        if (isMenuFileChanged && _resumeFile != null) {
          resumeFileUrl = await _uploadImageToFirebase(
            _resumeFile!,
            "resumes/${user.uid}/${widget.shopId}",
          );
        }

        // Upload new event images
        List<Map<String, dynamic>> updatedEvents = [];
        for (var event in eventsList) {
          String imageUrl = event['image'] is String ? event['image'] : "";
          if (event['image'] is File) {
            imageUrl = await _uploadImageToFirebase(
              event['image'],
              "events/${user.uid}/${widget.shopId}/${event['title']}",
            );
          }
          updatedEvents.add({
            "title": event['title'],
            "description": event['description'],
            "image": imageUrl,
          });
        }

        // Upload new product images
        List<Map<String, dynamic>> updatedProducts = [];
        for (var product in productsList) {
          String imageUrl = product['image'] is String ? product['image'] : "";
          if (product['image'] is File) {
            imageUrl = await _uploadImageToFirebase(
              product['image'],
              "products/${user.uid}/${widget.shopId}/${product['title']}",
            );
          }
          updatedProducts.add({
            "title": product['title'],
            "description": product['description'],
            "productprice": product['productprice'],
            "purchaseLink": product['purchaseLink'],
            "image": imageUrl,
          });
        }

        Map<String, dynamic> updatedData = {
          "shopInfo": {
            "shopName": shopNameController.text.trim(),
            "address": addressController.text.trim(),
            "shopEmail": shopEmailController.text.trim(),
            "ContactNo": contactNoController.text.trim(),
            "shopImage": profilePictureUrl ?? widget.shopData['shopInfo']['shopImage'],
          },
          "category": selectedCategory,
          "subCategory": selectedSubCategory,
          "ShopTimings": shopTimingsController.text.trim(),
          "googleRating": googleRatingController.text.trim(),
          "yearsofExperience": yearsOfExperienceController.text.trim(),
          "NoofProducts": noOfProductsController.text.trim(),
          "services": servicesList,
          "products": productTypesList,
          "coupons": couponList,
          "menuFile": resumeFileUrl ?? widget.shopData['menuFile'],
          "Events": updatedEvents,
          "Offers": offersList,
          "Products": updatedProducts,
          "accountLinks": {
            "email": user.email,
            "facebook": facebookController.text.trim(),
            "instagram": instagramController.text.trim(),
            "whatsapp": whatsappController.text.trim(),
            "digiLocal": digiLocalController.text.trim(),
          },
        };

        await _shopRef.update(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Shop updated successfully!")),
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
      backgroundColor: Color(0xffF2F0EF), //off white,
      appBar: AppBar(
        title: Text(
          "Edit Shop Details",
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (widget.shopData['shopInfo']['shopImage'] != null
                          ? NetworkImage(widget.shopData['shopInfo']['shopImage'])
                          : const AssetImage('assets/default_shop.png')) as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Basic Information Section
              Text("Basic Information", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: shopNameController,
                decoration: InputDecoration(
                  labelText: 'Shop Name',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? "Required" : null,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? "Required" : null,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: shopEmailController,
                decoration: InputDecoration(
                  labelText: 'Shop Email',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: contactNoController,
                decoration: InputDecoration(
                  labelText: 'Contact No',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),

              // Category Selection
              const SizedBox(height: 20),
               Text("Category", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.keys.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                    selectedSubCategory = null;
                  });
                },
                decoration: const InputDecoration(labelText: "Select Category"),
              ),
              if (selectedCategory != null) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedSubCategory,
                  items: categories[selectedCategory]!.map((String subCategory) {
                    return DropdownMenuItem<String>(
                      value: subCategory,
                      child: Text(subCategory),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSubCategory = newValue;
                    });
                  },
                  decoration: const InputDecoration(labelText: "Select Sub-Category"),
                ),
              ],

              // Additional Information
              const SizedBox(height: 20),
               Text("Additional Information", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: googleRatingController,
                decoration: InputDecoration(
                  labelText: 'Google Rating',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: yearsOfExperienceController,
                decoration: InputDecoration(
                  labelText: 'Years of Experience',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: noOfProductsController,
                decoration: InputDecoration(
                  labelText: 'No of Products',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: shopTimingsController,
                decoration: InputDecoration(
                  labelText: 'Shop Timings',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
              ),

              // Menu File
              const SizedBox(height: 20),
               Text("Menu File", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
              ElevatedButton(
                onPressed: _pickResumeFile,
                child: Text(_resumeFile != null ? "Change Menu File" : "Upload Menu File"),
              ),

              // Services Section
              const SizedBox(height: 20),
               Text("Services", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                        controller: typesofServicesController,
                        decoration: InputDecoration(
                          labelText: 'Add Services',
                          labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                          hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black,),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black,), // Always orange
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black,), // Always orange
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                          ),
                        ),),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add,color: Colors.black,),
                    onPressed: _addService,
                  ),
                ],
              ),
              Wrap(
                spacing: 8.0,
                children: servicesList.asMap().entries.map((entry) {
                  return Chip(
                    label: Text(entry.value),
                    onDeleted: () => _removeService(entry.key),
                  );
                }).toList(),
              ),

              // Product Types Section
              const SizedBox(height: 20),
              Text("Product Types", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                        controller: typesofProductsController,
                        decoration: InputDecoration(
                          labelText: 'Add Product Type',
                          labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                          hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black,),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black,), // Always orange
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black,), // Always orange
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                          ),
                        ),),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add,color: Colors.black,),
                    onPressed: _addProductType,
                  ),
                ],
              ),
              Wrap(
                spacing: 8.0,
                children: productTypesList.asMap().entries.map((entry) {
                  return Chip(
                    label: Text(entry.value),
                    onDeleted: () => _removeProductType(entry.key),
                  );
                }).toList(),
              ),

              // Coupons Section
              const SizedBox(height: 20),
              Text("Coupons", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                        controller: couponsController,
                        decoration: InputDecoration(
                          labelText: 'Add Coupons',
                          labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                          hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black,),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black,), // Always orange
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black,), // Always orange
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                          ),
                        ),),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add,color: Colors.black,),
                    onPressed: _addCoupon,
                  ),
                ],
              ),
              Wrap(
                spacing: 8.0,
                children: couponList.asMap().entries.map((entry) {
                  return Chip(
                    label: Text(entry.value),
                    onDeleted: () => _removeCoupon(entry.key),
                  );
                }).toList(),
              ),

              // Events Section
              const SizedBox(height: 20),
              Text("Events", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: eventTitleController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: eventDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Event Description',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                maxLines: 2,
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: _pickEventImage,
                child: const Text("Select Event Image"),
              ),
              ElevatedButton(
                onPressed: _addEvent,
                child: const Text("Add Event"),
              ),
              Column(
                children: eventsList.asMap().entries.map((entry) {
                  return ListTile(
                    title: Text(entry.value['title'],style: GoogleFonts.blinker(
                      color: Colors.black, // Set color to white to ensure the gradient is visible
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),),
                    subtitle: Text(entry.value['description'],style: GoogleFonts.blinker(
                      color: Colors.black54, // Set color to white to ensure the gradient is visible
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete,color: Colors.black,),
                      onPressed: () => _removeEvent(entry.key),
                    ),
                  );
                }).toList(),
              ),

              // Products Section
              const SizedBox(height: 20),
              Text("Products", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: productTitleController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: productDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Product Description',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                maxLines: 2,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: productPriceController,
                decoration: InputDecoration(
                  labelText: 'Product Price',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: purchaseLinkController,
                decoration: InputDecoration(
                  labelText: 'Purchase Link',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: _pickProductImage,
                child: const Text("Select Product Image"),
              ),
              ElevatedButton(
                onPressed: _addProduct,
                child: const Text("Add Product"),
              ),
              Column(
                children: productsList.asMap().entries.map((entry) {
                  return ListTile(
                    title: Text(entry.value['title'],style: GoogleFonts.blinker(
                      color: Colors.black, // Set color to white to ensure the gradient is visible
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),),
                    subtitle: Text("${entry.value['description']}\nPrice: ${entry.value['productprice']}",style: GoogleFonts.blinker(
                      color: Colors.black54, // Set color to white to ensure the gradient is visible
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete,color: Colors.black,),
                      onPressed: () => _removeProduct(entry.key),
                    ),
                  );
                }).toList(),
              ),

              // Offers Section
              const SizedBox(height: 20),
              Text("Offers", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: offerTitleController,
                decoration: InputDecoration(
                  labelText: 'Offer Name',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: offerDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Offer Description',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                maxLines: 2,
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: _addOffer,
                child: const Text("Add Offer"),
              ),
              Column(
                children: offersList.asMap().entries.map((entry) {
                  return ListTile(
                    title: Text(entry.value['title'],style: GoogleFonts.blinker(
                      color: Colors.black, // Set color to white to ensure the gradient is visible
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),),
                    subtitle: Text(entry.value['description'],style: GoogleFonts.blinker(
                      color: Colors.black54, // Set color to white to ensure the gradient is visible
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete,color: Colors.black,),
                      onPressed: () => _removeOffer(entry.key),
                    ),
                  );
                }).toList(),
              ),

              // Social Links Section
              const SizedBox(height: 20),
              Text("Social Links", style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: facebookController,
                decoration: InputDecoration(
                  labelText: 'Facebook Link',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: instagramController,
                decoration: InputDecoration(
                  labelText: 'Instagram Link',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: whatsappController,
                decoration: InputDecoration(
                  labelText: 'WhatsApp No',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                controller: digiLocalController,
                decoration: InputDecoration(
                  labelText: 'DigiLocal Link',
                  labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color:  Colors.black54),
                  hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black,), // Always orange
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2), // Thicker when focused
                  ),
                ),
                keyboardType: TextInputType.url,
              ),

              // Save Button
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _updateShopData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Background color changed to red
                    foregroundColor: Colors.white, // Text color white for contrast
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10), // Increased size
                    minimumSize: Size(200, 0), // Explicitly setting width and height
                  ),
                  child: Text(
                    "Save Changes",
                    style: GoogleFonts.blinker(
                      color: Colors.white, // Set color to white to ensure the gradient is visible
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}