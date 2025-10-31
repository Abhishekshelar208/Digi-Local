import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'UsersListPage.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("DigiLocal");

  final List<Map<String, String>> categories = [
    {"name": "All Categories", "image": "lib/assets/icons/allcate.png"},
    {"name": "Grocery Stores", "image": "lib/assets/icons/app-development.png"},
    {"name": "Restaurants & Cafes", "image": "lib/assets/icons/app-settings.png"},
    {"name": "Fashion & Clothing", "image": "lib/assets/icons/exploratory-analysis.png"},
    {"name": "Electronics", "image": "lib/assets/icons/cyber-criminal.png"},
    {"name": "Home & Furniture", "image": "lib/assets/icons/ai.png"},
    {"name": "Beauty & Wellness", "image": "lib/assets/icons/blockchain.png"},
    {"name": "Automobile Services", "image": "lib/assets/icons/exploratory-analysis.png"},
    {"name": "Pharmacies", "image": "lib/assets/icons/exploratory-analysis.png"},
    {"name": "Sports & Fitness", "image": "lib/assets/icons/app-settings.png"},
    {"name": "Handicrafts & Art", "image": "lib/assets/icons/app-development.png"},
    {"name": "Pet Shops", "image": "lib/assets/icons/blockchain.png"}
  ];


  // DigiLocal gradient color scheme for categories
  final List<List<Color>> gradientColors = [
    [Color(0xFF3B82F6), Color(0xFF3B82F6)], // Primary: Soft Indigo to Vibrant Blue
    [Color(0xFF16A34A), Color(0xFF16A34A)], // Success: Emerald Green gradient


    [Color(0xFFF97316), Color(0xFFF97316)], // Pink to Orange
    [Color(0xFF6366F1), Color(0xFF6366F1)], // Purple to Indigo
    [Color(0xFF0D9488), Color(0xFF0D9488)], // Teal gradient
    [Color(0xFFEF4444), Color(0xFFEF4444)], // Orange to Red

    [Color(0xFF4C6EF5), Color(0xFF4C6EF5)], // Indigo variations
    [Color(0xFF0EA5E9), Color(0xFF0EA5E9)], // Sky Blue gradient


    [Color(0xFFEC4899), Color(0xFFEC4899)], // Purple to Pink
    [Color(0xFF16A34A), Color(0xFF16A34A)], // Success: Emerald Green gradient


    [Color(0xFFF97316), Color(0xFFF97316)], // Pink to Orange
  ];

  void _fetchUsers(String category) async {
    try {
      DataSnapshot snapshot = await _databaseRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> usersMap = Map<String, dynamic>.from(snapshot.value as Map);
        List<Map<String, dynamic>> tempList = [];

        usersMap.forEach((key, value) {
          Map<String, dynamic> userData = Map<String, dynamic>.from(value);
          String userTitle = userData["category"] ?? "No Category";

          if (category == "All Categories" || _isRelatedToCategory(userTitle, category)) {
            tempList.add({
              "userId": key,
              "fullName": userData["shopInfo"]["shopName"] ?? "No Name",
              "userTitle": userTitle,
              "profilePicture": userData["shopInfo"]["shopImage"] ??
                  "https://www.infopedia.ai/no-image.png",
              "userData": userData,
            });
          }
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UsersListPage(category: category, usersList: tempList),
          ),
        );
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  bool _isRelatedToCategory(String shopTitle, String category) {
    final Map<String, List<String>> categoryKeywords = {
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
    };

    return categoryKeywords[category]
        ?.any((keyword) => shopTitle.toLowerCase().contains(keyword.toLowerCase())) ??
        false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // Pure White
      appBar: AppBar(
        title: Text(
          "Explore Categories",
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF4C6EF5)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Discover Local Shops",
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937)),
                ),
                SizedBox(height: 4),
                Text(
                  "Browse by category",
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  var category = categories[index];
                  List<Color> gradient = gradientColors[index % gradientColors.length];
                  return GestureDetector(
                    onTap: () => _fetchUsers(category["name"]!),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _fetchUsers(category["name"]!),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.asset(
                                    category["image"]!,
                                    height: 26,
                                    width: 26,
                                    color: Colors.white,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category["name"]!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          "Explore",
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withOpacity(0.85),
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 12,
                                          color: Colors.white.withOpacity(0.85),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}



//
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:skillhub/pages/userdatapageforall.dart';
//
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("Users");
//   List<Map<String, dynamic>> usersList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUsers();
//   }
//
//   void _fetchUsers() async {
//     try {
//       DataSnapshot snapshot = await _databaseRef.get();
//       if (snapshot.exists) {
//         // Cast the snapshot value to Map<String, dynamic>
//         Map<String, dynamic> usersMap = Map<String, dynamic>.from(snapshot.value as Map);
//
//         List<Map<String, dynamic>> tempList = [];
//
//         usersMap.forEach((key, value) {
//           // Cast the value to Map<String, dynamic>
//           Map<String, dynamic> userData = Map<String, dynamic>.from(value);
//
//           tempList.add({
//             "userId": key,
//             "fullName": userData["personalInfo"]["fullName"] ?? "No Name",
//             "userTitle": userData["personalInfo"]["usertitle"] ?? "No Title",
//             "profilePicture": userData["personalInfo"]["profilePicture"] ??
//                 "https://www.infopedia.ai/no-image.png",
//             "userData": userData, // Pass full user data
//           });
//         });
//
//         setState(() {
//           usersList = tempList;
//         });
//       }
//     } catch (e) {
//       print("Error fetching users: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Users List")),
//       body: usersList.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: GridView.builder(
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2, // 2 boxes per row
//             childAspectRatio: 0.8, // Adjust height of each box
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10,
//           ),
//           itemCount: usersList.length,
//           itemBuilder: (context, index) {
//             var user = usersList[index];
//             return _buildUserCard(user, context);
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUserCard(Map<String, dynamic> user, BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 4,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             radius: 40,
//             backgroundImage: NetworkImage(user["profilePicture"]),
//           ),
//           SizedBox(height: 8),
//           Text(user["fullName"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           SizedBox(height: 4),
//           Text(user["userTitle"], style: TextStyle(fontSize: 14, color: Colors.grey)),
//           SizedBox(height: 8),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => UserDataPageForAll(userData: user["userData"]),
//                 ),
//               );
//             },
//             child: Text("View"),
//           ),
//         ],
//       ),
//     );
//   }
// }