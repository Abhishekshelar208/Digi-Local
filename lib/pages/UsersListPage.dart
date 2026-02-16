// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:digilocal/pages/userdatapageforall.dart';
//
// class UsersListPage extends StatelessWidget {
//   final String category;
//   final List<Map<String, dynamic>> usersList;
//
//   UsersListPage({required this.category, required this.usersList});
//
//   final List<Color> boxColors = [
//     // Color(0xFF8f98ff),
//     // Color(0xFFfda88b),
//     // Color(0xFF4dc590),
//     // Color(0xFF66a3da),
//     // Color(0xFFff8181),
//     // Color(0xFFDCB0F2),
//     // Color(0xFFF6CF71),
//
//
//     Color(0xFF6cd5c6),
//     Color(0xFFfda88b),
//     Color(0xFF9bbef5),
//     Color(0xFFf59fd6),
//     Color(0xFFbba1f1),
//     Color(0xFF8ec7d3),
//     Color(0xFFa0d69a),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xffF2F0EF),
//       appBar: AppBar(
//         title: Text(
//           category,
//           style: GoogleFonts.blinker(
//               fontSize: 34,
//               fontWeight: FontWeight.w600,
//               color: Colors.black),
//         ),
//         centerTitle: true,
//         backgroundColor: Color(0xffF2F0EF),
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.black),
//       ),
//       body: usersList.isEmpty
//           ? Center(
//           child: Text("No users found in this category",
//               style: TextStyle(fontSize: 16, color: Colors.black)))
//           : ListView.builder(
//         padding: const EdgeInsets.all(12.0),
//         itemCount: usersList.length,
//         itemBuilder: (context, index) {
//           var user = usersList[index];
//           return _buildUserCard(user, context, index);
//         },
//       ),
//     );
//   }
//
//   Widget _buildUserCard(Map<String, dynamic> user, BuildContext context, int index) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       elevation: 4,
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       color: boxColors[index % boxColors.length],
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white, width: 3),
//               ),
//               child: CircleAvatar(
//                 backgroundColor: Color(0xffF2F0EF),
//                 radius: 40,
//                 backgroundImage: NetworkImage(user["profilePicture"]),
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     user["fullName"],
//                     style: GoogleFonts.blinker(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white),
//                   ),
//                   SizedBox(height: 6),
//                   FittedBox(
//                     child: Text(
//                       user["userTitle"],
//                       style: GoogleFonts.blinker(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.white70),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(width: 16),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         UserDataPageForAll(userData: user["userData"]),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.grey[100],
//                 foregroundColor: boxColors[index % boxColors.length], // Button text color
//               ),
//               child: Text("Open",style: GoogleFonts.blinker(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black),),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:digilocal/pages/userdatapageforall.dart';
// import 'package:geolocator/geolocator.dart';
//
// class UsersListPage extends StatefulWidget {
//   final String category;
//   final List<Map<String, dynamic>> usersList;
//
//   UsersListPage({required this.category, required this.usersList});
//
//   @override
//   _UsersListPageState createState() => _UsersListPageState();
// }
//
// class _UsersListPageState extends State<UsersListPage> {
//   Position? userPosition;
//   // Map to store calculated distances for each shop (keyed by shop id)
//   Map<String, double> distances = {};
//
//   final List<Color> boxColors = [
//     Color(0xFF6cd5c6),
//     Color(0xFFfda88b),
//     Color(0xFF9bbef5),
//     Color(0xFFf59fd6),
//     Color(0xFFbba1f1),
//     Color(0xFF8ec7d3),
//     Color(0xFFa0d69a),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     // Optionally, fetch location on start:
//     _fetchUserLocation();
//   }
//
//   Future<void> _fetchUserLocation() async {
//     // Check location permissions first
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Location permission denied.")),
//         );
//         return;
//       }
//     }
//
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         userPosition = position;
//       });
//       _calculateDistances();
//     } catch (e) {
//       print("Error fetching user location: $e");
//     }
//   }
//
//
//   void _calculateDistances() {
//     if (userPosition == null) return;
//
//     Map<String, double> newDistances = {};
//
//     // Iterate through each shop in usersList
//     for (var user in widget.usersList) {
//       // Expect shop data to be inside user["userData"]["shopInfo"]
//       if (user.containsKey("userData") &&
//           user["userData"].containsKey("shopInfo")) {
//         var shopInfo = user["userData"]["shopInfo"];
//         if (shopInfo.containsKey("latitude") &&
//             shopInfo.containsKey("longitude")) {
//           double shopLat = shopInfo["latitude"] is double
//               ? shopInfo["latitude"]
//               : double.tryParse(shopInfo["latitude"].toString()) ?? 0.0;
//           double shopLng = shopInfo["longitude"] is double
//               ? shopInfo["longitude"]
//               : double.tryParse(shopInfo["longitude"].toString()) ?? 0.0;
//
//           double distanceInKm = Geolocator.distanceBetween(
//             userPosition!.latitude,
//             userPosition!.longitude,
//             shopLat,
//             shopLng,
//           ) /
//               1000;
//           // Use shop id (or shop name) as the key. Here, we'll use the shop name.
//           String shopId = shopInfo["shopName"] ?? user["fullName"];
//           newDistances[shopId] = distanceInKm;
//         }
//       }
//     }
//
//     setState(() {
//       distances = newDistances;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xffF2F0EF),
//       appBar: AppBar(
//         title: Text(
//           widget.category,
//           style: GoogleFonts.blinker(
//               fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
//         ),
//         centerTitle: true,
//         backgroundColor: Color(0xffF2F0EF),
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.black),
//       ),
//       body: widget.usersList.isEmpty
//           ? Center(
//           child: Text("No users found in this category",
//               style: TextStyle(fontSize: 16, color: Colors.black)))
//           : ListView.builder(
//         padding: const EdgeInsets.all(12.0),
//         itemCount: widget.usersList.length,
//         itemBuilder: (context, index) {
//           var user = widget.usersList[index];
//           return _buildUserCard(user, context, index);
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _fetchUserLocation,
//         backgroundColor: Colors.black,
//         child: Icon(Icons.location_on, color: Colors.white),
//       ),
//     );
//   }
//
//   Widget _buildUserCard(Map<String, dynamic> user, BuildContext context, int index) {
//     // Get shop name from userData
//     String shopName = "";
//     if (user.containsKey("userData") &&
//         user["userData"].containsKey("shopInfo")) {
//       shopName = user["userData"]["shopInfo"]["shopName"] ?? "";
//     }
//     // Retrieve distance using shopName as key
//     double? distance = distances[shopName];
//
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       elevation: 4,
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       color: boxColors[index % boxColors.length],
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white, width: 3),
//               ),
//               child: CircleAvatar(
//                 backgroundColor: Color(0xffF2F0EF),
//                 radius: 40,
//                 backgroundImage: NetworkImage(user["profilePicture"]),
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     user["fullName"],
//                     style: GoogleFonts.blinker(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white),
//                   ),
//                   SizedBox(height: 6),
//                   FittedBox(
//                     child: Text(
//                       user["userTitle"],
//                       style: GoogleFonts.blinker(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.white70),
//                     ),
//                   ),
//                   SizedBox(height: 6),
//                   Text(
//                     distance != null
//                         ? "Near You: ${distance.toStringAsFixed(2)} KM"
//                         : "Calculating distance...",
//                     style: GoogleFonts.blinker(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(width: 16),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         UserDataPageForAll(userData: user["userData"]),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.grey[100],
//                 foregroundColor: boxColors[index % boxColors.length],
//               ),
//               child: Text(
//                 "Open",
//                 style: GoogleFonts.blinker(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


//latest last code

//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:digilocal/pages/userdatapageforall.dart';
// import 'package:geolocator/geolocator.dart';
//
// class UsersListPage extends StatefulWidget {
//   final String category;
//   final List<Map<String, dynamic>> usersList;
//
//   UsersListPage({required this.category, required this.usersList});
//
//   @override
//   _UsersListPageState createState() => _UsersListPageState();
// }
//
// class _UsersListPageState extends State<UsersListPage> {
//   Position? userPosition;
//   // Map to store calculated distances for each shop (keyed by shop name)
//   Map<String, double> distances = {};
//
//   final List<Color> boxColors = [
//     Color(0xFF6cd5c6),
//     Color(0xFFfda88b),
//     Color(0xFF9bbef5),
//     Color(0xFFf59fd6),
//     Color(0xFFbba1f1),
//     Color(0xFF8ec7d3),
//     Color(0xFFa0d69a),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserLocation();
//   }
//
//   Future<void> _fetchUserLocation() async {
//     // Check location permissions first
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Location permission denied.")),
//         );
//         return;
//       }
//     }
//
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         userPosition = position;
//       });
//       _calculateDistances();
//     } catch (e) {
//       print("Error fetching user location: $e");
//     }
//   }
//
//   void _calculateDistances() {
//     if (userPosition == null) return;
//
//     Map<String, double> newDistances = {};
//
//     // Iterate through each shop in usersList
//     for (var user in widget.usersList) {
//       // Expect shop data to be inside user["userData"]["shopInfo"]
//       if (user.containsKey("userData") &&
//           user["userData"].containsKey("shopInfo")) {
//         var shopInfo = user["userData"]["shopInfo"];
//         if (shopInfo.containsKey("latitude") &&
//             shopInfo.containsKey("longitude")) {
//           double shopLat = shopInfo["latitude"] is double
//               ? shopInfo["latitude"]
//               : double.tryParse(shopInfo["latitude"].toString()) ?? 0.0;
//           double shopLng = shopInfo["longitude"] is double
//               ? shopInfo["longitude"]
//               : double.tryParse(shopInfo["longitude"].toString()) ?? 0.0;
//
//           double distanceInKm = Geolocator.distanceBetween(
//               userPosition!.latitude,
//               userPosition!.longitude,
//               shopLat,
//               shopLng) /
//               1000; // Convert meters to KM
//
//           // Use shop name as the key
//           String shopName = shopInfo["shopName"] ?? user["fullName"];
//           newDistances[shopName] = distanceInKm;
//         }
//       }
//     }
//
//     setState(() {
//       distances = newDistances;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Create a sorted copy of usersList based on distance
//     List<Map<String, dynamic>> sortedUsers = List.from(widget.usersList);
//     sortedUsers.sort((a, b) {
//       // Extract shop names from userData
//       String shopNameA = "";
//       String shopNameB = "";
//       if (a.containsKey("userData") && a["userData"].containsKey("shopInfo")) {
//         shopNameA = a["userData"]["shopInfo"]["shopName"] ?? "";
//       }
//       if (b.containsKey("userData") && b["userData"].containsKey("shopInfo")) {
//         shopNameB = b["userData"]["shopInfo"]["shopName"] ?? "";
//       }
//       // Retrieve distances; if missing, set to infinity
//       double distanceA = distances[shopNameA] ?? double.infinity;
//       double distanceB = distances[shopNameB] ?? double.infinity;
//       return distanceA.compareTo(distanceB);
//     });
//
//     return Scaffold(
//       backgroundColor: Color(0xffF2F0EF),
//       appBar: AppBar(
//         title: Text(
//           widget.category,
//           style: GoogleFonts.blinker(
//               fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
//         ),
//         centerTitle: true,
//         backgroundColor: Color(0xffF2F0EF),
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.black),
//       ),
//       body: sortedUsers.isEmpty
//           ? Center(
//           child: Text("No users found in this category",
//               style: TextStyle(fontSize: 16, color: Colors.black)))
//           : ListView.builder(
//         padding: const EdgeInsets.all(12.0),
//         itemCount: sortedUsers.length,
//         itemBuilder: (context, index) {
//           var user = sortedUsers[index];
//           return _buildUserCard(user, context, index);
//         },
//       ),
//       // floatingActionButton: FloatingActionButton(
//       //   onPressed: _fetchUserLocation,
//       //   backgroundColor: Colors.black,
//       //   child: Icon(Icons.location_on, color: Colors.white),
//       // ),
//     );
//   }
//
//   Widget _buildUserCard(Map<String, dynamic> user, BuildContext context, int index) {
//     // Extract shop name from userData
//     String shopName = "";
//     if (user.containsKey("userData") &&
//         user["userData"].containsKey("shopInfo")) {
//       shopName = user["userData"]["shopInfo"]["shopName"] ?? "";
//     }
//     // Retrieve the distance using shopName as key
//     double? distance = distances[shopName];
//
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       elevation: 4,
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       color: boxColors[index % boxColors.length],
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white, width: 3),
//               ),
//               child: CircleAvatar(
//                 backgroundColor: Color(0xffF2F0EF),
//                 radius: 40,
//                 backgroundImage: NetworkImage(user["profilePicture"]),
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     user["fullName"],
//                     style: GoogleFonts.blinker(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white),
//                   ),
//                   SizedBox(height: 6),
//                   FittedBox(
//                     child: Text(
//                       user["userTitle"],
//                       style: GoogleFonts.blinker(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.white70),
//                     ),
//                   ),
//                   SizedBox(height: 6),
//                   Text(
//                     distance != null
//                         ? "Near You: ${distance.toStringAsFixed(2)} KM"
//                         : "Calculating distance...",
//                     style: GoogleFonts.blinker(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(width: 16),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         UserDataPageForAll(userData: user["userData"]),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.grey[100],
//                 foregroundColor: boxColors[index % boxColors.length],
//               ),
//               child: Text(
//                 "Open",
//                 style: GoogleFonts.blinker(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digilocal/pages/userdatapageforall.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UsersListPage extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> usersList;
  final VoidCallback? onShopsLoaded;

  UsersListPage({
    required this.category, 
    required this.usersList,
    this.onShopsLoaded,
  });

  @override
  _UsersListPageState createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  Position? userPosition;
  Map<String, double> distances = {};
  bool isLoadingLocation = true;

  // Single professional color scheme - no gradients needed
  final Color primaryBlue = Color(0xFF4C6EF5);
  final Color lightBackground = Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchUserLocation() async {
    // Check location permissions first
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permission denied.")),
        );
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userPosition = position;
        isLoadingLocation = false;
      });
      _calculateDistances();
      
      // Notify that shops are loaded and ready
      widget.onShopsLoaded?.call();
    } catch (e) {
      print("Error fetching user location: $e");
      setState(() {
        isLoadingLocation = false;
      });
      
      // Still notify even if location failed - shops can be browsed
      widget.onShopsLoaded?.call();
    }
  }

  void _calculateDistances() {
    if (userPosition == null) return;

    Map<String, double> newDistances = {};

    // Iterate through each shop in usersList
    for (var user in widget.usersList) {
      // Expect shop data to be inside user["userData"]["shopInfo"]
      if (user.containsKey("userData") &&
          user["userData"].containsKey("shopInfo")) {
        var shopInfo = user["userData"]["shopInfo"];
        if (shopInfo.containsKey("latitude") &&
            shopInfo.containsKey("longitude")) {
          double shopLat = shopInfo["latitude"] is double
              ? shopInfo["latitude"]
              : double.tryParse(shopInfo["latitude"].toString()) ?? 0.0;
          double shopLng = shopInfo["longitude"] is double
              ? shopInfo["longitude"]
              : double.tryParse(shopInfo["longitude"].toString()) ?? 0.0;

          double distanceInKm = Geolocator.distanceBetween(
              userPosition!.latitude,
              userPosition!.longitude,
              shopLat,
              shopLng) /
              1000; // Convert meters to KM

          // Use shop name as the key
          String shopName = shopInfo["shopName"] ?? user["fullName"];
          newDistances[shopName] = distanceInKm;
        }
      }
    }

    setState(() {
      distances = newDistances;
    });
  }

  // New method to store visited user email in the database
  Future<void> _storeVisitedUserEmail(String shopName) async {
    // Fetch the current user's email
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) {
      print("Current user not logged in or email not available.");
      return;
    }
    String userEmail = currentUser.email!;

    // Reference to the DigiLocal node
    DatabaseReference dbRef =
    FirebaseDatabase.instance.ref().child("DigiLocal");

    // Query for the shop whose shopInfo/shopName matches shopName
    DatabaseEvent event = await dbRef
        .orderByChild("shopInfo/shopName")
        .equalTo(shopName)
        .once();

    DataSnapshot snapshot = event.snapshot;


    if (snapshot.value != null) {
      // snapshot.value is a Map of matching shop entries
      Map<dynamic, dynamic> shops = snapshot.value as Map<dynamic, dynamic>;
      shops.forEach((shopID, shopData) async {
        // Create or push a new child under "StoreVisitedUsersEmails" with the current user's email
        DatabaseReference visitedRef =
        dbRef.child(shopID).child("StoreVisitedUsersEmails");
        await visitedRef.push().set(userEmail);
        print("Stored visited email for shop $shopName");
      });
    } else {
      print("No shop found with shopName: $shopName");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sortedUsers = List.from(widget.usersList);
    sortedUsers.sort((a, b) {
      String shopNameA = "";
      String shopNameB = "";
      if (a.containsKey("userData") && a["userData"].containsKey("shopInfo")) {
        shopNameA = a["userData"]["shopInfo"]["shopName"] ?? "";
      }
      if (b.containsKey("userData") && b["userData"].containsKey("shopInfo")) {
        shopNameB = b["userData"]["shopInfo"]["shopName"] ?? "";
      }
      double distanceA = distances[shopNameA] ?? double.infinity;
      double distanceB = distances[shopNameB] ?? double.infinity;
      return distanceA.compareTo(distanceB);
    });

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // Pure White
      appBar: AppBar(
        title: Text(
          widget.category,
          style: GoogleFonts.poppins(
              fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF4C6EF5)),
        actions: [
          if (isLoadingLocation)
            Padding(
              padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C6EF5)),
                  ),
                ),
            ),
        ],
      ),
      body: sortedUsers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined, size: 80, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 16),
                  Text(
                    "No shops found in this category",
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Shop count header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.store, size: 20, color: Color(0xFF6B7280)),
                      SizedBox(width: 8),
                      Text(
                        "${sortedUsers.length} ${sortedUsers.length == 1 ? 'Shop' : 'Shops'} Found",
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937)),
                      ),
                      Spacer(),
                      if (userPosition != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF4C6EF5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: Color(0xFF4C6EF5)),
                              SizedBox(width: 4),
                              Text(
                                "Sorted by distance",
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF4C6EF5)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Shop list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: sortedUsers.length,
                    itemBuilder: (context, index) {
                      var user = sortedUsers[index];
                      return _buildUserCard(user, context, index);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildUserCard(
      Map<String, dynamic> user, BuildContext context, int index) {
    String shopName = "";
    if (user.containsKey("userData") &&
        user["userData"].containsKey("shopInfo")) {
      shopName = user["userData"]["shopInfo"]["shopName"] ?? "";
    }
    double? distance = distances[shopName];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await _storeVisitedUserEmail(user["fullName"]);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    UserDataPageForAll(userData: user["userData"]),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: lightBackground, // Soft light background
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Color(0xFFE5E7EB), // Light border
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Shop Image
                      Hero(
                        tag: 'shop_${user["userId"]}',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryBlue.withOpacity(0.2), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            backgroundImage: NetworkImage(user["profilePicture"]),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Shop Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user["fullName"],
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.category_outlined,
                                    size: 14, color: Color(0xFF6B7280)),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    user["userTitle"],
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF6B7280)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            // Distance badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on,
                                      size: 14, color: primaryBlue),
                                  SizedBox(width: 4),
                                  Text(
                                    distance != null
                                        ? "${distance.toStringAsFixed(1)} KM away"
                                        : "Locating...",
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: primaryBlue),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      // Open button
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF6366F1),
                              Color(0xFF3B82F6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await _storeVisitedUserEmail(user["fullName"]);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDataPageForAll(
                                      userData: user["userData"]),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Column(
                                children: [
                                  Icon(Icons.arrow_forward,
                                      color: Colors.white, size: 20),
                                  SizedBox(height: 2),
                                  Text(
                                    "View",
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
