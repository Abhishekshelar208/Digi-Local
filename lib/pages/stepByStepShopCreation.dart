import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../designOne/designOne.dart';
import '../designOne/designThree.dart';
import '../designOne/designTwo.dart';
import '../designOne/designfour.dart';
import 'loadingAnimation.dart';
import 'shopCreationSteps.dart';

class StepByStepShopCreation extends StatefulWidget {
  const StepByStepShopCreation({super.key, required this.designName});

  final String designName;

  @override
  State<StepByStepShopCreation> createState() => _StepByStepShopCreationState();
}

class _StepByStepShopCreationState extends State<StepByStepShopCreation> {
  // Track completion of each step
  Map<int, bool> stepCompletion = {
    0: false, // Basic Information
    1: false, // Extra Details
    2: false, // Services & Products
    3: false, // Discounts & Offers
    4: false, // Products
    5: false, // Upcoming Events
    6: false, // Shop Links
    7: false, // Location
  };

  // Store data from each step
  Map<String, dynamic> shopData = {};

  final List<Map<String, dynamic>> steps = [
    {
      'title': 'Basic Information',
      'icon': Icons.info_outline,
      'description': 'Shop name, category, contact details',
      'color': Colors.blue,
    },
    {
      'title': 'Extra Details',
      'icon': Icons.details,
      'description': 'Shop timings, ratings, experience',
      'color': Colors.orange,
    },
    {
      'title': 'Services & Products',
      'icon': Icons.category,
      'description': 'Services, categories, coupons',
      'color': Colors.green,
    },
    {
      'title': 'Discounts & Offers',
      'icon': Icons.local_offer,
      'description': 'Create promotional offers',
      'color': Colors.purple,
    },
    {
      'title': 'Products',
      'icon': Icons.shopping_bag,
      'description': 'Add your products catalog',
      'color': Colors.red,
    },
    {
      'title': 'Upcoming Events',
      'icon': Icons.event,
      'description': 'Add events and activities',
      'color': Colors.teal,
    },
    {
      'title': 'Shop Links',
      'icon': Icons.link,
      'description': 'Social media and menu',
      'color': Colors.indigo,
    },
    {
      'title': 'Location',
      'icon': Icons.location_on,
      'description': 'Shop location coordinates',
      'color': Colors.deepOrange,
    },
  ];

  int get completedSteps => stepCompletion.values.where((completed) => completed).length;
  double get progress => (completedSteps / stepCompletion.length) * 100;

  bool _isStepEnabled(int index) {
    if (index == 0) return true; // First step always enabled
    return stepCompletion[index - 1] == true; // Enable only if previous step is completed
  }

  void _completeStep(int index, Map<String, dynamic> data) {
    setState(() {
      stepCompletion[index] = true;
      shopData.addAll(data);
    });
  }

  void _navigateToStep(int index) {
    if (!_isStepEnabled(index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete previous steps first!")),
      );
      return;
    }

    // Navigate to respective step page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          switch (index) {
            case 0:
              return BasicInformationPage(
                onComplete: (data) => _completeStep(0, data),
                existingData: shopData,
              );
            case 1:
              return ExtraDetailsPage(
                onComplete: (data) => _completeStep(1, data),
                existingData: shopData,
              );
            case 2:
              return ServicesProductsPage(
                onComplete: (data) => _completeStep(2, data),
                existingData: shopData,
              );
            case 3:
              return DiscountsOffersPage(
                onComplete: (data) => _completeStep(3, data),
                existingData: shopData,
              );
            case 4:
              return ProductsPage(
                onComplete: (data) => _completeStep(4, data),
                existingData: shopData,
              );
            case 5:
              return UpcomingEventsPage(
                onComplete: (data) => _completeStep(5, data),
                existingData: shopData,
              );
            case 6:
              return ShopLinksPage(
                onComplete: (data) => _completeStep(6, data),
                existingData: shopData,
              );
            case 7:
              return LocationPage(
                onComplete: (data) => _completeStep(7, data),
                existingData: shopData,
              );
            default:
              return Container();
          }
        },
      ),
    );
  }

  void _createShop() async {
    if (completedSteps < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all steps before creating shop!")),
      );
      return;
    }

    // Navigate to loading screen and save data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          onFinish: () => _saveShopData(),
        ),
      ),
    );
  }

  void _saveShopData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DatabaseReference counterRef = FirebaseDatabase.instance.ref("shopCounter");
      DataSnapshot snapshot = await counterRef.get();
      int currentCounter = snapshot.exists ? snapshot.value as int : 0;
      String shopID = "Shop${(currentCounter + 1).toString().padLeft(6, '0')}";

      // Upload shop image if exists
      String profilePictureUrl = "";
      if (shopData['shopImage'] != null && shopData['shopImage'] is File) {
        profilePictureUrl = await _uploadImageToFirebase(shopData['shopImage'], "profile_pictures/${user.uid}/$shopID");
      }

      // Upload menu file if exists
      String resumeFileUrl = "";
      if (shopData['menuFile'] != null && shopData['menuFile'] is File) {
        resumeFileUrl = await _uploadImageToFirebase(shopData['menuFile'], "resumes/${user.uid}");
      }

      // Upload event images
      List<Map<String, dynamic>> uploadFeatures = [];
      if (shopData['Events'] != null) {
        for (var features in shopData['Events']) {
          String imageUrl = "";
          if (features["image"] != null && features["image"] is File) {
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
      }

      // Upload product images
      List<Map<String, dynamic>> uploadProducts = [];
      if (shopData['Products'] != null) {
        for (var products in shopData['Products']) {
          String projectImageUrl = "";
          if (products["image"] != null && products["image"] is File) {
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
      }

      DatabaseReference userRef = FirebaseDatabase.instance.ref("DigiLocal/$shopID");

      Map<String, dynamic> finalData = {
        "selectedDesign": widget.designName,
        "shopInfo": {
          "shopName": shopData['shopName'],
          "address": shopData['address'],
          "shopEmail": shopData['shopEmail'],
          "ContactNo": shopData['contactNo'],
          "shopImage": profilePictureUrl,
          "latitude": shopData['latitude'],
          "longitude": shopData['longitude'],
        },
        "category": shopData['category'],
        "subCategory": shopData['subCategory'],
        "ShopTimings": shopData['ShopTimings'],
        "googleRating": shopData['googleRating'],
        "yearsofExperience": shopData['yearsofExperience'],
        "NoofProducts": shopData['NoofProducts'],
        "services": shopData['services'],
        "products": shopData['products'],
        "coupons": shopData['coupons'],
        "menuFile": resumeFileUrl,
        "Events": uploadFeatures,
        "Offers": shopData['Offers'],
        "Products": uploadProducts,
        "accountLinks": {
          "email": user.email,
          "facebook": shopData['facebook'] ?? "https://www.linkedin.com/feed/",
          "instagram": shopData['instagram'] ?? "https://instagram.com/",
          "whatsapp": shopData['whatsapp'] ?? "https://web.whatsapp.com/",
        },
      };

      await userRef.set(finalData);
      await counterRef.set(currentCounter + 1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Shop created successfully!")),
      );

      // Navigate to design page
      Widget selectedPage;
      if (widget.designName == "DesignOne") {
        selectedPage = DesignOne(userData: finalData);
      } else if (widget.designName == "DesignTwo") {
        selectedPage = DesignTwo(userData: finalData);
      } else if (widget.designName == "DesignThree") {
        selectedPage = DesignThree(userData: finalData);
      } else if (widget.designName == "DesignFour") {
        selectedPage = DesignFour(userData: finalData);
      } else {
        selectedPage = DesignOne(userData: finalData);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => selectedPage),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
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
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text(
          "Create Your Shop",
          style: GoogleFonts.blinker(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Completion: ${progress.toStringAsFixed(0)}%",
                      style: GoogleFonts.blinker(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "$completedSteps/8 Steps",
                      style: GoogleFonts.blinker(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // List of step cards
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                final isCompleted = stepCompletion[index] ?? false;
                final isEnabled = _isStepEnabled(index);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () => _navigateToStep(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green[50]
                            : isEnabled
                                ? Colors.white
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCompleted
                              ? Colors.green
                              : isEnabled
                                  ? Colors.deepOrangeAccent
                                  : Colors.grey[400]!,
                          width: 2,
                        ),
                        boxShadow: isEnabled
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Icon with step number
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? Colors.green
                                    : isEnabled
                                        ? step['color']
                                        : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: isCompleted
                                    ? Icon(Icons.check, color: Colors.white, size: 32)
                                    : Icon(step['icon'], color: Colors.white, size: 28),
                              ),
                            ),
                            SizedBox(width: 16),
                            
                            // Step details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Step ${index + 1}",
                                        style: GoogleFonts.blinker(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      if (isCompleted)
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            "Completed",
                                            style: GoogleFonts.blinker(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      if (!isEnabled && !isCompleted)
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            "Locked",
                                            style: GoogleFonts.blinker(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    step['title'],
                                    style: GoogleFonts.blinker(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isEnabled ? Colors.black87 : Colors.black45,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    step['description'],
                                    style: GoogleFonts.blinker(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isEnabled ? Colors.black54 : Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Arrow icon
                            Icon(
                              isEnabled ? Icons.arrow_forward_ios : Icons.lock,
                              color: isEnabled ? Colors.black54 : Colors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Create Shop button
          if (completedSteps == 8)
            Container(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _createShop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(double.infinity, 0),
                ),
                child: Text(
                  "🎉 Create My Shop",
                  style: GoogleFonts.blinker(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Form pages are imported from shopCreationSteps.dart
