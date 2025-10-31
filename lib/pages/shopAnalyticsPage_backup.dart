import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopAnalytics extends StatefulWidget {
  @override
  _ShopAnalyticsState createState() => _ShopAnalyticsState();
}

class _ShopAnalyticsState extends State<ShopAnalytics> {
  int visitorCount = 0;
  int bookingsCount = 0;
  int _offerCount = 0;

  List<Map<String, dynamic>> _offerDetailsList = [];

  @override
  void initState() {
    super.initState();
    _fetchVisitorCount();
    _loadBookingsCount();
    _displayOfferCountInCard();
  }

  Future<void> _fetchVisitorCount() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) {
      print("User not logged in or email not available.");
      return;
    }
    String userEmail = currentUser.email!;

    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(
        "DigiLocal");
    DatabaseEvent event = await dbRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      Map<dynamic, dynamic> shops = snapshot.value as Map<dynamic, dynamic>;
      for (var shopID in shops.keys) {
        var shopData = shops[shopID];
        if (shopData["shopInfo"] != null &&
            shopData["shopInfo"]["shopEmail"] == userEmail) {
          DatabaseReference visitedRef = dbRef.child(shopID).child(
              "StoreVisitedUsersEmails");
          DatabaseEvent visitedEvent = await visitedRef.once();
          DataSnapshot visitedSnapshot = visitedEvent.snapshot;
          if (visitedSnapshot.value != null) {
            setState(() {
              visitorCount =
                  (visitedSnapshot.value as Map<dynamic, dynamic>).length;
            });
          }
          break;
        }
      }
    }
  }

  Future<void> _loadBookingsCount() async {
    int count = await _getBookingsCount();
    setState(() {
      bookingsCount = count;
    });
  }

  Future<int> _getBookingsCount() async {
    // Fetch the current user's email
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) {
      print("Current user not logged in or email not available.");
      return 0;
    }
    String userEmail = currentUser.email!;

    // Reference to the "online Bookings" node
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(
        "online Bookings");

    // Fetch all the bookings
    DatabaseEvent event = await dbRef.once();
    DataSnapshot snapshot = event.snapshot;

    int bookingsCount = 0;

    if (snapshot.value != null) {
      Map<dynamic, dynamic> bookings = snapshot.value as Map<dynamic, dynamic>;

      bookings.forEach((key, booking) {
        // Check if shopEmail matches the current user's email
        if (booking["shopEmail"] == userEmail) {
          bookingsCount++; // Increment the counter for each match
        }
      });
    }

    return bookingsCount;
  }

  Future<void> _displayOfferCountInCard() async {
    int offerCount = await _getOfferCountForCurrentUser();
    setState(() {
      _offerCount =
          offerCount; // Store the count in a variable to display in your card
    });
  }


  Future<int> _getOfferCountForCurrentUser() async {
    // Fetch the current user's email
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) {
      print("Current user not logged in or email not available.");
      return 0; // Return 0 if no user is logged in
    }
    String userEmail = currentUser.email!;

    // Reference to the "offers" node
    DatabaseReference offersRef = FirebaseDatabase.instance.ref().child(
        "offers");

    // Query the "offers" node where creator_email matches the current user's email
    DatabaseEvent event = await offersRef.orderByChild("creator_email").equalTo(
        userEmail).once();

    DataSnapshot snapshot = event.snapshot;

    // If snapshot has data, count the number of offers
    if (snapshot.exists) {
      Map<dynamic, dynamic> offersData = snapshot.value as Map<dynamic,
          dynamic>;
      return offersData.length; // The number of matching offers
    } else {
      return 0; // No matching offers found
    }
  }

  Future<void> _displayOfferDetails() async {
    List<Map<String,
        dynamic>> offerDetails = await _getOfferDetailsForCurrentUser();

    // Now you can display offer details, e.g., in a GridView or ListView
    setState(() {
      _offerDetailsList = offerDetails; // Store the details in a state variable
    });
  }


  Future<List<Map<String, dynamic>>> _getOfferDetailsForCurrentUser() async {
    // Fetch the current user's email
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) {
      print("Current user not logged in or email not available.");
      return []; // Return empty list if no user is logged in
    }
    String userEmail = currentUser.email!;

    // Reference to the "offers" node
    DatabaseReference offersRef = FirebaseDatabase.instance.ref().child(
        "offers");

    // Query the "offers" node where creator_email matches the current user's email
    DatabaseEvent event = await offersRef.orderByChild("creator_email").equalTo(
        userEmail).once();

    DataSnapshot snapshot = event.snapshot;

    List<Map<String, dynamic>> offersDataList = [];

    // If snapshot has data, process each offer
    if (snapshot.exists) {
      Map<dynamic, dynamic> offers = snapshot.value as Map<dynamic, dynamic>;

      offers.forEach((offerID, offerData) {
        // Get the name of the offer
        String offerName = offerData["name"];

        // Get the LikedUsersEmail and DislikeUsersEmail counts
        Map<dynamic, dynamic>? likedUsersEmail = offerData["LikedUsersEmail"];
        Map<dynamic,
            dynamic>? dislikeUsersEmail = offerData["DislikeUsersEmail"];

        // Count the LikedUsersEmail and DislikeUsersEmail
        int likedCount = likedUsersEmail?.length ?? 0;
        int dislikeCount = dislikeUsersEmail?.length ?? 0;

        // Add the offer details to the list
        offersDataList.add({
          "name": offerName,
          "likedCount": likedCount,
          "dislikeCount": dislikeCount,
        });
      });
    }

    return offersDataList;
  }


  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> cards = [
      {"color": Colors.red, "number": visitorCount, "name": "Visitors"},
      {
        "color": Colors.blue,
        "number": bookingsCount,
        "name": "Online Bookings"
      },
      {"color": Colors.green, "number": _offerCount, "name": "Offers"},
      {"color": Colors.amber, "number": 4, "name": "Reviews"},
    ];

    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text(
          "Shop Analytics",
          style: GoogleFonts.blinker(
              fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // First 4 cards
              GridView.builder(
                shrinkWrap: true,
                // Use shrinkWrap to limit the size of the grid
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Display 2 items in a row for the 4 cards
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: cards[index]["color"],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${cards[index]["number"]}",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FittedBox(
                              child: Text(
                                cards[index]["name"],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 16),
              // Space between the 4 cards and the offers section

              // Offers section (GridView for offers)
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _getOfferDetailsForCurrentUser(),
                // Ensure to call the function to get offers
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator()); // Show loading indicator while fetching data
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  List<Map<String, dynamic>> offerDetailsList = snapshot.data ??
                      [];

                  return GridView.builder(
                    shrinkWrap: true,
                    // Use shrinkWrap to limit the size of the grid
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1, // Display offers in single column
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3,
                    ),
                    itemCount: offerDetailsList.length,
                    itemBuilder: (context, index) {
                      var offer = offerDetailsList[index];
                      return Card(
                        color: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                offer['name'],
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton.icon(onPressed: () {  },
                                    icon: Icon(Icons.thumb_up,color: Colors.white,),
                                    label: Text("${offer['likedCount']}"),),
                                  TextButton.icon(onPressed: () {  },
                                    icon: Icon(Icons.thumb_down,color: Colors.white,),
                                    label: Text("${offer['dislikeCount']}"),),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}