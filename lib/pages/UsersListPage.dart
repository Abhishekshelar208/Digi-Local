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





import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digilocal/pages/userdatapageforall.dart';
import 'package:geolocator/geolocator.dart';

class UsersListPage extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> usersList;

  UsersListPage({required this.category, required this.usersList});

  @override
  _UsersListPageState createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  Position? userPosition;
  // Map to store calculated distances for each shop (keyed by shop name)
  Map<String, double> distances = {};

  final List<Color> boxColors = [
    Color(0xFF6cd5c6),
    Color(0xFFfda88b),
    Color(0xFF9bbef5),
    Color(0xFFf59fd6),
    Color(0xFFbba1f1),
    Color(0xFF8ec7d3),
    Color(0xFFa0d69a),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
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
      });
      _calculateDistances();
    } catch (e) {
      print("Error fetching user location: $e");
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

  @override
  Widget build(BuildContext context) {
    // Create a sorted copy of usersList based on distance
    List<Map<String, dynamic>> sortedUsers = List.from(widget.usersList);
    sortedUsers.sort((a, b) {
      // Extract shop names from userData
      String shopNameA = "";
      String shopNameB = "";
      if (a.containsKey("userData") && a["userData"].containsKey("shopInfo")) {
        shopNameA = a["userData"]["shopInfo"]["shopName"] ?? "";
      }
      if (b.containsKey("userData") && b["userData"].containsKey("shopInfo")) {
        shopNameB = b["userData"]["shopInfo"]["shopName"] ?? "";
      }
      // Retrieve distances; if missing, set to infinity
      double distanceA = distances[shopNameA] ?? double.infinity;
      double distanceB = distances[shopNameB] ?? double.infinity;
      return distanceA.compareTo(distanceB);
    });

    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text(
          widget.category,
          style: GoogleFonts.blinker(
              fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: sortedUsers.isEmpty
          ? Center(
          child: Text("No users found in this category",
              style: TextStyle(fontSize: 16, color: Colors.black)))
          : ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: sortedUsers.length,
        itemBuilder: (context, index) {
          var user = sortedUsers[index];
          return _buildUserCard(user, context, index);
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _fetchUserLocation,
      //   backgroundColor: Colors.black,
      //   child: Icon(Icons.location_on, color: Colors.white),
      // ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, BuildContext context, int index) {
    // Extract shop name from userData
    String shopName = "";
    if (user.containsKey("userData") &&
        user["userData"].containsKey("shopInfo")) {
      shopName = user["userData"]["shopInfo"]["shopName"] ?? "";
    }
    // Retrieve the distance using shopName as key
    double? distance = distances[shopName];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: boxColors[index % boxColors.length],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: CircleAvatar(
                backgroundColor: Color(0xffF2F0EF),
                radius: 40,
                backgroundImage: NetworkImage(user["profilePicture"]),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user["fullName"],
                    style: GoogleFonts.blinker(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 6),
                  FittedBox(
                    child: Text(
                      user["userTitle"],
                      style: GoogleFonts.blinker(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    distance != null
                        ? "Near You: ${distance.toStringAsFixed(2)} KM"
                        : "Calculating distance...",
                    style: GoogleFonts.blinker(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserDataPageForAll(userData: user["userData"]),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: boxColors[index % boxColors.length],
              ),
              child: Text(
                "Open",
                style: GoogleFonts.blinker(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
