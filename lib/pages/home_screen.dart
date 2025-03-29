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


  final List<Color> boxColors = [
    // Color(0xFF8f98ff),
    // Color(0xFFfda88b),
    // Color(0xFF4dc590),
    // Color(0xFF66a3da),
    // Color(0xFFff8181),
    // Color(0xFFDCB0F2),
    // Color(0xFFF6CF71),


    Color(0xFF6cd5c6),
    Color(0xFFfda88b),
    Color(0xFF9bbef5),
    Color(0xFFf59fd6),
    Color(0xFFbba1f1),
    Color(0xFF8ec7d3),
    Color(0xFFa0d69a),

    Color(0xFFfda88b),
    Color(0xFF9bbef5),
    Color(0xFFf59fd6),
    Color(0xFFbba1f1),
    Color(0xFF8ec7d3),
    Color(0xFFa0d69a),

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
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.35,
            crossAxisSpacing: 25,
            mainAxisSpacing: 25,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            var category = categories[index];
            return GestureDetector(
              onTap: () => _fetchUsers(category["name"]!),
              child: Container(
                decoration: BoxDecoration(
                  color: boxColors[index], // Applying different colors
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 2),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(category["image"]!, height: 35, width: 60), // Using local image
                    SizedBox(height: 5),
                    FittedBox(
                      child: Text(
                        category["name"]!,
                        style: GoogleFonts.blinker(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: index == 5 ? Colors.white : Colors.white, // Making text visible on white box
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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