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


  // Professional gradient color scheme for categories
  final List<List<Color>> gradientColors = [
    [Color(0xFF2E3192), Color(0xFF1BFFFF)], // Deep Blue to Cyan
    [Color(0xFF134E5E), Color(0xFF71B280)], // Teal to Green
    [Color(0xFF000428), Color(0xFF004e92)], // Dark Blue gradient
    [Color(0xFF232526), Color(0xFF414345)], // Dark Grey gradient
    [Color(0xFF0F2027), Color(0xFF2C5364)], // Dark Teal gradient
    [Color(0xFF1e3c72), Color(0xFF2a5298)], // Royal Blue gradient
    [Color(0xFF141E30), Color(0xFF243B55)], // Navy gradient
    [Color(0xFF2C3E50), Color(0xFF3498DB)], // Dark to Blue
    [Color(0xFF1C1C1C), Color(0xFF3A3A3A)], // Dark gradient
    [Color(0xFF0F2027), Color(0xFF203A43)], // Deep Teal
    [Color(0xFF2E3192), Color(0xFF1BFFFF)], // Repeat Blue Cyan
    [Color(0xFF134E5E), Color(0xFF71B280)], // Repeat Teal Green
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
      backgroundColor: Color(0xffF2F0EF), //off white
      appBar: AppBar(
        title: Text(
          "Explore Categories",
          style: GoogleFonts.blinker(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
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
                  style: GoogleFonts.blinker(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
                SizedBox(height: 4),
                Text(
                  "Browse by category",
                  style: GoogleFonts.blinker(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600]),
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
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _fetchUsers(category["name"]!),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.asset(
                                    category["image"]!,
                                    height: 28,
                                    width: 28,
                                    color: Colors.white,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category["name"]!,
                                      style: GoogleFonts.blinker(
                                        fontSize: 16,
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
                                          style: GoogleFonts.blinker(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 12,
                                          color: Colors.white70,
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