

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:digilocal/pages/userdatapageforall.dart';


class AllUsers extends StatefulWidget {
  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("Users");
  List<Map<String, dynamic>> usersList = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    try {
      DataSnapshot snapshot = await _databaseRef.get();
      if (snapshot.exists) {
        // Cast the snapshot value to Map<String, dynamic>
        Map<String, dynamic> usersMap = Map<String, dynamic>.from(snapshot.value as Map);

        List<Map<String, dynamic>> tempList = [];

        usersMap.forEach((key, value) {
          // Cast the value to Map<String, dynamic>
          Map<String, dynamic> userData = Map<String, dynamic>.from(value);

          tempList.add({
            "userId": key,
            "fullName": userData["personalInfo"]["fullName"] ?? "No Name",
            "userTitle": userData["personalInfo"]["usertitle"] ?? "No Title",
            "profilePicture": userData["personalInfo"]["profilePicture"] ??
                "https://www.infopedia.ai/no-image.png",
            "userData": userData, // Pass full user data
          });
        });

        setState(() {
          usersList = tempList;
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users List")),
      body: usersList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 boxes per row
            childAspectRatio: 0.8, // Adjust height of each box
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: usersList.length,
          itemBuilder: (context, index) {
            var user = usersList[index];
            return _buildUserCard(user, context);
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(user["profilePicture"]),
          ),
          SizedBox(height: 8),
          Text(user["fullName"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(user["userTitle"], style: TextStyle(fontSize: 14, color: Colors.grey)),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDataPageForAll(userData: user["userData"]),
                ),
              );
            },
            child: Text("View"),
          ),
        ],
      ),
    );
  }
}