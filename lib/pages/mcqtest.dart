import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digilocal/pages/userdatapageforall.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class FilterUsersPage extends StatefulWidget {
  @override
  _FilterUsersPageState createState() => _FilterUsersPageState();
}

class _FilterUsersPageState extends State<FilterUsersPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("DigiLocal");
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> usersList = [];
  bool isLoading = false;
  String errorMessage = '';
  Timer? _debounceTimer;

  // Debounce duration to avoid excessive API calls
  final Duration _debounceDuration = Duration(milliseconds: 500);

  Future<void> _filterUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    usersList.clear();

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: 'AIzaSyCQktw7dH6hdRn0PMF1xd2vg238yh9KgPU', // Replace securely
      );

      final prompt = """
Extract relevant filters from this query: "${_controller.text}".
Identify the necessary fields dynamically based on the request and return a JSON object.

### Instructions:
1. If the query mentions a **shop name** (e.g., "Magic Cake Shop"), include it as {"shopInfo.shopName": "Magic Cake Shop"}.
2. If a **category** is mentioned (e.g., "Restaurants & Cafes"), include {"category": "Restaurants & Cafes"}.
3. If a **sub-category** is mentioned (e.g., "Cake Shop"), include {"subCategory": "Cake Shop"}.
4. If a **location** is specified, extract it as {"shopInfo.address": "Vrindavan, Uttar Pradesh"}.
5. If a user asks for shops with **specific products** (e.g., "Custom Cakes"), return {"products": ["Custom Cakes"]}.
6. If a **service** is requested (e.g., "Cake Decoration"), include {"services": ["Cake Decoration"]}.
7. If a query contains a **minimum experience** (e.g., "Shops with 10+ years of experience"), extract {"yearsofExperience": 10}.
8. If a user asks for **offers or discounts**, return {"Offers": true}.
9. If a user searches based on **Google ratings** (e.g., "4.5+ stars"), extract {"googleRating": 4.5}.
10. If a shop is searched by **number of products** (e.g., "More than 50 products"), return {"NoofProducts": 50}.
11. If the query includes **business hours** (e.g., "Open at 10 AM"), extract {"ShopTimings": "10:00 AM - 8:00 PM"}.
12. If a user wants to find shops with specific **events** (e.g., "Cake-making event"), return {"Events": true}.
13. If a user searches for shops based on **coupons** (e.g., "Magic200"), return {"coupons": ["Magic200"]}.
14. If social media links are requested, include relevant account links from **accountLinks**.

### Rules:
- Always return a valid JSON object.
- Use the exact field names as specified (e.g., "shopInfo.shopName", "category", "yearsofExperience", "googleRating").
- If no specific filters are found, default to searching by "category".
""";



      final response = await model.generateContent([Content.text(prompt)]);

      String cleanJson(String aiOutput) {
        return aiOutput.replaceAll("```json", "").replaceAll("```", "").trim();
      }

      if (response.text != null) {
        print("AI Output: ${response.text}"); // Debugging
        final filters = parseJson(cleanJson(response.text!));
        if (filters.isEmpty) {
          filters["subCategory"] = _controller.text.trim(); // Fallback to usertitle
        }

        DataSnapshot snapshot = await _databaseRef.get();

        if (snapshot.exists) {
          Map<String, dynamic> usersMap = Map<String, dynamic>.from(snapshot.value as Map);
          List<Map<String, dynamic>> tempList = [];

          usersMap.forEach((key, value) {
            Map<String, dynamic> userData = Map<String, dynamic>.from(value);
            Map<String, dynamic> personalInfo = Map<String, dynamic>.from(userData["shopInfo"] ?? {});

            bool matches = true;

            filters.forEach((field, condition) {
              if (field == "subCategory" && personalInfo.containsKey("subCategory")) {
                String userTitle = personalInfo["subCategory"].toString().toLowerCase();
                String queryTitle = condition.toString().toLowerCase();
                if (userTitle != queryTitle) {
                  matches = false;
                }
              } else if (field == "yearsofExperience" && userData.containsKey("yearsofExperience")) {
                int userExperience = int.tryParse(userData["yearsofExperience"].toString()) ?? 0;
                int requiredExperience = condition;
                if (userExperience < requiredExperience) {
                  matches = false;
                }
              } else if (field == "NoofProducts" && userData.containsKey("NoofProducts")) {
                int userProjects = int.tryParse(userData["NoofProducts"].toString()) ?? 0;
                int requiredProjects = condition;
                if (userProjects < requiredProjects) {
                  matches = false;
                }
              } else if (field == "services" && userData.containsKey("services")) {
                List<String> userSkills = List<String>.from(userData["services"] ?? []);
                List<String> requiredSkills = List<String>.from(condition);
                if (!requiredSkills.every((skill) => userSkills.any((s) => s.toLowerCase().contains(skill.toLowerCase())))) {
                  matches = false;
                }
              } else if (field == "products" && userData.containsKey("products")) {
                List<String> userTools = List<String>.from(userData["products"] ?? []);
                List<String> requiredTools = List<String>.from(condition);
                if (!requiredTools.every((tool) => userTools.any((t) => t.toLowerCase().contains(tool.toLowerCase())))) {
                  matches = false;
                }
              } else if (field == "coupons" && userData.containsKey("coupons")) {
                List<String> userSoftSkills = List<String>.from(userData["coupons"] ?? []);
                List<String> requiredSoftSkills = List<String>.from(condition);
                if (!requiredSoftSkills.every((skill) => userSoftSkills.any((s) => s.toLowerCase().contains(skill.toLowerCase())))) {
                  matches = false;
                }
              }
            });

            if (matches) {
              tempList.add({
                "userId": key,
                "fullName": personalInfo["shopName"] ?? "No Name",
                "userTitle": personalInfo["subCategory"] ?? "No Title",
                "profilePicture": personalInfo["shopImage"] ?? "https://www.infopedia.ai/no-image.png",
                "userData": userData,
              });
            }
          });

          setState(() => usersList = tempList);
        }
      }
    } catch (e) {
      print("Error filtering users: $e");
      setState(() => errorMessage = "Failed to filter users. Please try again.");
    } finally {
      setState(() => isLoading = false);
    }
  }


  void _onSearchTextChanged(String text) {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(_debounceDuration, _filterUsers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF), //off white,
      appBar: AppBar(
        title: Text(
          "Connect with Users",
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
              maxLines: 4,
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Search Query',
                labelStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                hintStyle: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black,), // Always orange
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black, width: 2), // Thicker when focused
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black,), // Always orange
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black, width: 2), // Thicker when focused
                ),
              ),
              onChanged: _onSearchTextChanged,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _filterUsers,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent, // Background color changed to red
                foregroundColor: Colors.white, // Text color white for contrast
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10), // Increased size
                minimumSize: Size(200, 0), // Explicitly setting width and height
              ),
              child: Text(
                "Search",
                style: GoogleFonts.blinker(
                  color: Colors.white, // Set color to white to ensure the gradient is visible
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "Search Results",
                  style: GoogleFonts.blinker(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: TextStyle(color: Colors.red)),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.deepOrangeAccent,))
                  : usersList.isEmpty
                  ? Center(child: Text("No matching users found",style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),))
                  : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 2.5, // Increased to decrease height
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: usersList.length,
                itemBuilder: (context, index) {
                  return _buildUserCard(usersList[index], context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<Color> boxColors = [
    Color(0xFF6cd5c6),
    Color(0xFFfda88b),
    Color(0xFF9bbef5),
    Color(0xFFf59fd6),
    Color(0xFFbba1f1),
    Color(0xFF8ec7d3),
    Color(0xFFa0d69a),
  ];

  Widget _buildUserCard(Map<String, dynamic> user, BuildContext context, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      user["fullName"],
                      style: GoogleFonts.blinker(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
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
                foregroundColor: boxColors[index % boxColors.length], // Button text color
              ),
              child: Text("Open",style: GoogleFonts.blinker(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),),
            ),
          ],
        ),
      ),
    );
  }

}

Map<String, dynamic> parseJson(String jsonString) {
  try {
    jsonString = jsonString.trim();
    if (!jsonString.startsWith("{") || !jsonString.endsWith("}")) {
      print("Invalid JSON format from AI: $jsonString");
      return {};
    }
    return jsonDecode(jsonString) as Map<String, dynamic>;
  } catch (e) {
    print("Error parsing JSON: $e");
    return {};
  }
}