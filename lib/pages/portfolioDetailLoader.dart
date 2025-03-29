// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:profolio/portfolioDesings/designone.dart';
// import 'package:profolio/portfolioDesings/designtwo.dart';
// import 'package:profolio/portfolioDesings/designfour.dart';
//
// import '../portfolioDesings/designthreee.dart';
//
// class PortfolioDetailLoader extends StatelessWidget {
//   final String portfolioId;
//
//   const PortfolioDetailLoader({Key? key, required this.portfolioId}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     DatabaseReference portfolioRef =
//     FirebaseDatabase.instance.ref("Portfolio/$portfolioId");
//
//     return FutureBuilder<DatabaseEvent>(
//       future: portfolioRef.once(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (snapshot.hasError || snapshot.data?.snapshot.value == null) {
//           return Scaffold(
//             body: Center(child: Text("Portfolio not found")),
//           );
//         }
//         // Convert snapshot to a Map<String, dynamic>
//         Map<String, dynamic> data =
//         Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
//         String selectedDesign = data["selectedDesign"] ?? "DesignOne";
//         Widget targetPage;
//
//         if (selectedDesign == "DesignOne") {
//           targetPage = DesignOne(userData: data, portfolioid: portfolioId,);
//         } else if (selectedDesign == "DesignTwo") {
//           targetPage = DesignTwo(userData: data);
//         } else if (selectedDesign == "DesignThree") {
//           targetPage = DesignThree(userData: data);
//         } else if (selectedDesign == "DesignFour") {
//           targetPage = DesignFour(userData: data);
//         } else {
//           targetPage = DesignOne(userData: data, portfolioid: portfolioId,);
//         }
//
//         return targetPage;
//       },
//     );
//   }
// }

//
// //
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:profolio/portfolioDesings/designone.dart';
// import 'package:profolio/portfolioDesings/designtwo.dart';
//
// import 'package:profolio/portfolioDesings/designfour.dart';
//
// import '../portfolioDesings/designthreee.dart';
//
// class PortfolioDetailLoader extends StatelessWidget {
//   final String portfolioId;
//
//   const PortfolioDetailLoader({Key? key, required this.portfolioId}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     DatabaseReference portfolioRef = FirebaseDatabase.instance.ref("Portfolio/$portfolioId");
//
//     return FutureBuilder<DatabaseEvent>(
//       future: portfolioRef.once(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (snapshot.hasError || snapshot.data?.snapshot.value == null) {
//           return Scaffold(
//             body: Center(child: Text("Portfolio not found")),
//           );
//         }
//
//         // Convert the snapshot data to Map<String, dynamic>
//         Map<String, dynamic> data =
//         Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
//         String selectedDesign = data["selectedDesign"] ?? "DesignOne";
//         Widget targetPage;
//
//         // Map the selected design value to the corresponding design page.
//         if (selectedDesign == "DesignOne") {
//           targetPage = DesignOne(userData: data, portfolioid: portfolioId,);
//         } else if (selectedDesign == "DesignTwo") {
//           targetPage = DesignTwo(userData: data);
//         } else if (selectedDesign == "DesignThree") {
//           targetPage = DesignThree(userData: data);
//         } else if (selectedDesign == "DesignFour") {
//           targetPage = DesignFour(userData: data);
//         } else {
//           targetPage = DesignOne(userData: data, portfolioid: portfolioId,);
//         }
//
//         return targetPage;
//       },
//     );
//   }
// }
//


import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../designOne/designOne.dart';
import '../designOne/designThree.dart';
import '../designOne/designTwo.dart';
import '../designOne/designfour.dart';


class PortfolioDetailLoader extends StatelessWidget {
  final String portfolioId;

  const PortfolioDetailLoader({Key? key, required this.portfolioId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DatabaseReference portfolioRef = FirebaseDatabase.instance.ref("DigiLocal/$portfolioId");

    return FutureBuilder<DatabaseEvent>(
      future: portfolioRef.once(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data?.snapshot.value == null) {
          return Scaffold(
            body: Center(child: Text("Shop not found")),
          );
        }
        // Convert the snapshot data to Map<String, dynamic>
        Map<String, dynamic> data =
        Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
        String selectedDesign = data["selectedDesign"] ?? "DesignOne";
        Widget targetPage;

        if (selectedDesign == "DesignOne") {
          targetPage = DesignOne(userData: data,);
        } else if (selectedDesign == "DesignTwo") {
          targetPage = DesignTwo(userData: data,);
        } else if (selectedDesign == "DesignThree") {
          targetPage = DesignThree(userData: data);
        } else if (selectedDesign == "DesignFour") {
          targetPage = DesignFour(userData: data);
        } else {
          targetPage = DesignOne(userData: data);
        }
        return targetPage;
      },
    );
  }
}
