import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digilocal/pages/requestPage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'edituserdatapage.dart';
import 'fullscreenimageview.dart';

class UserDataPageForAll extends StatefulWidget {
  final Map<String, dynamic> userData;

  UserDataPageForAll({required this.userData});

  @override
  State<UserDataPageForAll> createState() => _UserDataPageForAllState();
}



class _UserDataPageForAllState extends State<UserDataPageForAll> {
  Widget _buildStatCard(String title, String value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen width
        double screenWidth = MediaQuery.of(context).size.width;

        // Check if the device is a mobile or PC
        bool isMobile = screenWidth < 600;

        return Container(
          height: isMobile ? 100 : 150, // Smaller height for mobile
          width: isMobile ? 160 : 200,  // Adjust width based on screen size
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(isMobile ? 8 : 16), // Adjust padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.blinker(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : 16, // Font size for mobile/PC
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12), // Responsive spacing
              Text(
                value,
                style: GoogleFonts.blinker(
                  color: Colors.grey[700],
                  fontSize: isMobile ? 34 : 42, // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );

  }

  List<Map<String, dynamic>> projects = [
    {
      "image": "https://example.com/image.jpg",
      "title": "Sample Project",
      "description": "This is a sample description.",
      "productprice": "\$99",
      "purchaseLink": "https://example.com/buy",
      "likes": 0,
      "dislikes": 0,
    },
  ];


  void _incrementLikes(int index) {
    setState(() {
      projects[index]["likes"]++;
    });
  }

  void _incrementDislikes(int index) {
    setState(() {
      projects[index]["dislikes"]++;
    });
  }


  @override
  Widget build(BuildContext context) {
    // Handle null fields
    List<dynamic> skills = widget.userData["services"] ?? [];
    List<dynamic> tools = widget.userData["coupons"] ?? [];
    List<dynamic> softSkills = widget.userData["products"] ?? [];
    List<dynamic> achievements = widget.userData["Events"] ?? [];
    List<dynamic> experiences = widget.userData["Offers"] ?? [];
    List<dynamic> projects = widget.userData["Products"] ?? [];

    void _launchURL(String url) async {
      if (url.isNotEmpty) {
        Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          print("Could not launch $url");
        }
      }
    }

    return Scaffold(
      backgroundColor: Color(0xffF2F0EF), //off white
      appBar: AppBar(
        title: Text(
          "Shop Details",
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => FullScreenImageView(
                      imageUrl: widget.userData["shopInfo"]["shopImage"],
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(widget.userData["shopInfo"]["shopImage"]),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Full Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.userData["shopInfo"]["shopName"],
                  style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            // User Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.userData["subCategory"],
                  style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 20),

            // About Yourself
            Text(
              "Address",
              style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color:  Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              widget.userData["shopInfo"]["address"],
              style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.transparent,
                    blurRadius: 0.5,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatCard("Products Category", "${widget.userData["NoofProducts"]}"),
                      SizedBox(width: 25),
                      _buildStatCard("Shop Timings", "${widget.userData["ShopTimings"]}"),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatCard("Years of Experience", "${widget.userData["yearsofExperience"]}"),
                      SizedBox(width: 25),
                      _buildStatCard("Google Rating", "${widget.userData["googleRating"]}+"),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),

            // Skills
            Text(
              "Services Offered",
              style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: skills.map<Widget>((skill) {
                return Chip(
                  label: Text(skill.toString()),
                  labelStyle: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[300]),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            //Tools / Software
            Text(
              "Coupons",
              style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: tools.map<Widget>((tool) {
                return Chip(
                  label: Text(tool.toString()),
                  labelStyle: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[300]),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Soft Skills
            Text(
              "Products Category",
              style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: softSkills.map<Widget>((skill) {
                return Chip(
                  label: Text(skill.toString()),
                  labelStyle: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[300]),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Projects
            Text(
              "Products",
              style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            // SizedBox(
            //   height: 450,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     itemCount: projects.length,
            //     itemBuilder: (context, index) {
            //       var project = projects[index];
            //       return Container(
            //         width: 300,
            //         margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            //         child: Card(
            //           color: Colors.white,
            //           elevation: 4,
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(20),
            //           ),
            //           child: Padding(
            //             padding: const EdgeInsets.all(12.0),
            //             child: SingleChildScrollView(
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   // Image at the top
            //                   if (project["image"] != null && project["image"].isNotEmpty)
            //                     GestureDetector(
            //                       onTap: () {
            //                         showDialog(
            //                           context: context,
            //                           builder: (context) => FullScreenImageView(imageUrl: project["image"]),
            //                         );
            //                       },
            //                       child: ClipRRect(
            //                         borderRadius: BorderRadius.circular(12),
            //                         child: Image.network(
            //                           project["image"],
            //                           width: double.infinity,
            //                           height: 200,
            //                           fit: BoxFit.cover,
            //                           errorBuilder: (context, error, stackTrace) => Icon(
            //                             Icons.image_not_supported,
            //                             size: 50,
            //                             color: Colors.grey,
            //                           ),
            //                         ),
            //                       ),
            //                     ),
            //
            //                   SizedBox(height: 8),
            //                   // Title
            //                   Text(
            //                     project["title"] ?? "No Title",
            //                     style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            //                   ),
            //                   SizedBox(height: 4),
            //                   // Description
            //                   Text(
            //                     project["description"] ?? "No Description",
            //                     style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            //                   ),
            //                   SizedBox(height: 4),
            //                   // Description
            //                   Text(
            //                     project["productprice"] ?? "No productprice",
            //                     style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            //                   ),
            //                   SizedBox(height: 8),
            //                   SizedBox(height: 10),
            //                   // Action buttons (GitHub & YouTube)
            //                   Row(
            //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //                     children: [
            //                       ElevatedButton.icon(
            //                         onPressed: () {
            //                           final url = project["purchaseLink"] ?? "";
            //                           _launchURL(url);
            //                         },
            //                         icon: Icon(Icons.code, color: Colors.grey[300]),
            //                         label: Text(
            //                           "Buy Now",
            //                           style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[300]),
            //                         ),
            //                         style: ElevatedButton.styleFrom(
            //                           backgroundColor: Colors.black,
            //                           shape: RoundedRectangleBorder(
            //                             borderRadius: BorderRadius.circular(100),
            //                           ),
            //                           padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            //                         ),
            //                       ),
            //                       // ElevatedButton.icon(
            //                       //   onPressed: () {
            //                       //     final url = project["projectyoutubelink"] ?? "";
            //                       //     _launchURL(url);
            //                       //   },
            //                       //   icon: Icon(Icons.video_library, color: Colors.grey[300]),
            //                       //   label: Text(
            //                       //     "YouTube",
            //                       //     style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[300]),
            //                       //   ),
            //                       //   style: ElevatedButton.styleFrom(
            //                       //     backgroundColor: Colors.black,
            //                       //     shape: RoundedRectangleBorder(
            //                       //       borderRadius: BorderRadius.circular(100),
            //                       //     ),
            //                       //     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            //                       //   ),
            //                       // ),
            //                     ],
            //                   ),
            //                   SizedBox(height: 20),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),

            SizedBox(
              height: 450,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  var project = projects[index];
                  return Container(
                    width: 300,
                    margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (project["image"] != null && project["image"].isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  project["image"],
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            SizedBox(height: 8),
                            Text(
                              project["title"] ?? "No Title",
                              style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            SizedBox(height: 4),
                            Text(
                              project["description"] ?? "No Description",
                              style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                            ),
                            SizedBox(height: 4),
                            Text(
                              project["productprice"] ?? "No productprice",
                              style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _incrementLikes(index),
                                  icon: Icon(Icons.thumb_up, color: Colors.white),
                                  label: Text("${project["likes"]}"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _incrementDislikes(index),
                                  icon: Icon(Icons.thumb_down, color: Colors.white),
                                  label: Text("${project["dislikes"]}"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                final url = project["purchaseLink"] ?? "";
                                _launchURL(url);
                              },
                              icon: Icon(Icons.shopping_cart, color: Colors.white),
                              label: Text("Buy Now"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // Experiences
            Text(
              "Offers & Discounts",
              style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: experiences.length,
                itemBuilder: (context, index) {
                  var experience = experiences[index];
                  return Container(
                    width: 300,
                    margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              experience["title"] ?? "No Title",
                              style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            SizedBox(height: 4),
                            // Description
                            Text(
                              experience["description"] ?? "No Description",
                              style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // Achievements
            Text(
              "Shop Features",
              style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 330,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  var achievement = achievements[index];
                  return Container(
                    width: 300,
                    margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image at the top
                              if (achievement["image"] != null && achievement["image"].isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => FullScreenImageView(imageUrl: achievement["image"]),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      achievement["image"],
                                      width: double.infinity,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),

                              SizedBox(height: 8),
                              // Title
                              Text(
                                achievement["title"] ?? "No Title",
                                style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              SizedBox(height: 4),
                              // Description
                              Text(
                                achievement["description"] ?? "No Description",
                                style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestPage(userId: widget.userData["accountLinks"]["email"]),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent, // Background color changed to red
                    foregroundColor: Colors.white, // Text color white for contrast
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10), // Increased size
                    minimumSize: Size(200, 0), // Explicitly setting width and height
                  ),
                  child: Text(
                    "Inquiry",
                    style: GoogleFonts.blinker(
                      color: Colors.white, // Set color to white to ensure the gradient is visible
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}