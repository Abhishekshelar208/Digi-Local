// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import 'package:share_plus/share_plus.dart';
//
// import '../designOne/designOne.dart';
// import '../designOne/designThree.dart';
// import '../designOne/designTwo.dart';
// import '../designOne/designfour.dart';
// import 'designSelectionPage.dart'; // Import share_plus
//
// class shopListPage extends StatefulWidget {
//   @override
//   _shopListPageState createState() => _shopListPageState();
// }
//
// class _shopListPageState extends State<shopListPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late DatabaseReference _portfolioRef;
//
//   @override
//   void initState() {
//     super.initState();
//     _portfolioRef = FirebaseDatabase.instance.ref("DigiLocal");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     User? user = _auth.currentUser;
//     if (user == null) {
//       return Scaffold(
//         appBar: AppBar(title: Text("My Portfolios")),
//         body: Center(child: Text("User not logged in")),
//       );
//     }
//
//     // Query portfolios where accountLinks/email equals the current user's email
//     Query portfolioQuery =
//     _portfolioRef.orderByChild("accountLinks/email").equalTo(user.email);
//
//     return Scaffold(
//       appBar: AppBar(title: Text("My Portfolios")),
//       body: StreamBuilder(
//         stream: portfolioQuery.onValue,
//         builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//           if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
//             return Center(child: Text("No portfolios found"));
//           }
//
//           // Convert snapshot value to Map<String, dynamic>
//           Map<String, dynamic> portfoliosMap =
//           Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
//
//           // Build portfolio cards
//           List<Widget> portfolioCards = [];
//           portfoliosMap.forEach((portfolioId, portfolioData) {
//             // Convert portfolioData to Map<String, dynamic>
//             final Map<String, dynamic> data =
//             Map<String, dynamic>.from(portfolioData as Map);
//
//             // Ensure that list fields are properly cast
//             if (data.containsKey("Events") && data["Events"] is List) {
//               data["Events"] = (data["Events"] as List)
//                   .map((e) => Map<String, dynamic>.from(e))
//                   .toList();
//             }
//             if (data.containsKey("Products") && data["Products"] is List) {
//               data["Products"] = (data["Products"] as List)
//                   .map((e) => Map<String, dynamic>.from(e))
//                   .toList();
//             }
//
//             portfolioCards.add(
//               GestureDetector(
//                 onTap: () {
//                   // Fetch the selectedDesign field and navigate accordingly.
//                   String selectedDesign = data["selectedDesign"] ?? "DesignOne";
//                   Widget targetPage;
//                   if (selectedDesign == "DesignOne") {
//                     targetPage = DesignOne(userData: data);
//                   } else if (selectedDesign == "DesignTwo") {
//                     targetPage = DesignTwo(userData: data);
//                   } else if (selectedDesign == "DesignThree") {
//                     targetPage = DesignThree(userData: data);
//                   } else if (selectedDesign == "DesignFour") {
//                     targetPage = DesignFour(userData: data);
//                   } else {
//                     // Fallback to DesignOne if not recognized
//                     targetPage = DesignOne(userData: data);
//                   }
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => targetPage),
//                   );
//                 },
//                 child: Card(
//                   margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Portfolio ID: $portfolioId",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.share),
//                           onPressed: () {
//                             // Generate share link for this portfolio
//                             String shareLink =
//                                 "https://digilocal-go-digital-in-minute.web.app//#/shops/$portfolioId";
//                             // Use share_plus to open the system share sheet
//                             Share.share(
//                               shareLink,
//                               subject: "Check out my portfolio",
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           });
//
//           return ListView(
//             children: portfolioCards,
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(context,
//               MaterialPageRoute(builder: (context) => PortfolioDesignSelectionPage()));
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../designOne/designOne.dart';
import '../designOne/designThree.dart';
import '../designOne/designTwo.dart';
import '../designOne/designfour.dart';
import 'designSelectionPage.dart';
import 'editShopDetails.dart';


class ShopListPage extends StatefulWidget {
  @override
  _ShopListPageState createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _portfolioRef;

  @override
  void initState() {
    super.initState();
    _portfolioRef = FirebaseDatabase.instance.ref("DigiLocal");
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("My Portfolios")),
        body: Center(child: Text("User not logged in")),
      );
    }

    Query portfolioQuery =
    _portfolioRef.orderByChild("accountLinks/email").equalTo(user.email);

    return Scaffold(
      backgroundColor: Color(0xffF2F0EF), //off white,
      appBar: AppBar(
        title: Text(
          "My Shops",
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder(
        stream: portfolioQuery.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: Text("No portfolios found"));
          }

          Map<String, dynamic> portfoliosMap =
          Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

          List<Widget> portfolioCards = [];
          portfoliosMap.forEach((portfolioId, portfolioData) {
            final Map<String, dynamic> data =
            Map<String, dynamic>.from(portfolioData as Map);

            if (data.containsKey("Events") && data["Events"] is List) {
              data["Events"] = (data["Events"] as List)
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();
            }
            if (data.containsKey("Products") && data["Products"] is List) {
              data["Products"] = (data["Products"] as List)
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();
            }

            portfolioCards.add(
              GestureDetector(
                onTap: () {
                  String selectedDesign = data["selectedDesign"] ?? "DesignOne";
                  Widget targetPage;
                  if (selectedDesign == "DesignOne") {
                    targetPage = DesignOne(userData: data);
                  } else if (selectedDesign == "DesignTwo") {
                    targetPage = DesignTwo(userData: data);
                  } else if (selectedDesign == "DesignThree") {
                    targetPage = DesignThree(userData: data);
                  } else if (selectedDesign == "DesignFour") {
                    targetPage = DesignFour(userData: data);
                  } else {
                    targetPage = DesignOne(userData: data);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => targetPage),
                  );
                },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  color: Color(0xFFbba1f1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['shopInfo']?['shopName'] ?? 'Unnamed Shop',
                                style:  GoogleFonts.blinker(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                "ID: $portfolioId",
                                style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            // Navigate to EditShopPage with the shop ID and data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditShopPage(
                                  shopId: portfolioId,
                                  shopData: data,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.share, color: Colors.white),
                          onPressed: () {
                            String shareLink =
                                "https://digilocal-go-digital-in-minute.web.app//#/shops/$portfolioId";
                            Share.share(
                              shareLink,
                              subject: "Check out my portfolio",
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });

          return ListView(
            children: portfolioCards,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PortfolioDesignSelectionPage()),
          );
        },
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}