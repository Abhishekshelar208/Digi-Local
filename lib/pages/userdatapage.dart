import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'edituserdatapage.dart';
import 'fullscreenimageview.dart';

class UserDataPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  UserDataPage({required this.userData});

  @override
  Widget build(BuildContext context) {
    // Handle null fields
    List<dynamic> skills = userData["skills"] ?? [];
    List<dynamic> tools = userData["tools"] ?? [];
    List<dynamic> softSkills = userData["softSkills"] ?? [];
    List<dynamic> achievements = userData["achievements"] ?? [];
    List<dynamic> experiences = userData["experiences"] ?? [];
    List<dynamic> projects = userData["projects"] ?? [];

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
      appBar: AppBar(
        title: Text(userData["personalInfo"]["fullName"]),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to the edit page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUserDataPage(userData: userData),
                ),
              );
            },
          ),
        ],
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
                      imageUrl: userData["personalInfo"]["profilePicture"],
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(userData["personalInfo"]["profilePicture"]),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Full Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userData["personalInfo"]["fullName"],
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),

            // User Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userData["personalInfo"]["usertitle"],
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20),

            // About Yourself
            Text(
              "About Me",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              userData["personalInfo"]["aboutyourself"],
              style: TextStyle(fontSize: 16, color: Colors.white60),
            ),
            SizedBox(height: 20),

            // Skills
            Text(
              "Skills",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: skills.map<Widget>((skill) {
                return Chip(
                  label: Text(skill.toString()),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Tools / Software
            Text(
              "Tools / Software",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: tools.map<Widget>((tool) {
                return Chip(
                  label: Text(tool.toString()),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Soft Skills
            Text(
              "Soft Skills",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: softSkills.map<Widget>((skill) {
                return Chip(
                  label: Text(skill.toString()),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Projects
            Text(
              "Projects",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
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
                              if (project["image"] != null && project["image"].isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => FullScreenImageView(imageUrl: project["image"]),
                                    );
                                  },
                                  child: ClipRRect(
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
                                ),

                              SizedBox(height: 8),
                              // Title
                              Text(
                                project["title"] ?? "No Title",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              // Description
                              Text(
                                project["description"] ?? "No Description",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                              SizedBox(height: 8),
                              // Project tech stack
                              Text(
                                project["techstack"] ?? "No techstack",
                                style: GoogleFonts.blinker(
                                  fontSize: 15,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10),
                              // Action buttons (GitHub & YouTube)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      final url = project["projectgithublink"] ?? "";
                                      _launchURL(url);
                                    },
                                    icon: Icon(Icons.code, color: Colors.white),
                                    label: Text(
                                      "GitHub",
                                      style: GoogleFonts.blinker(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      final url = project["projectyoutubelink"] ?? "";
                                      _launchURL(url);
                                    },
                                    icon: Icon(Icons.video_library, color: Colors.white),
                                    label: Text(
                                      "YouTube",
                                      style: GoogleFonts.blinker(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
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
              "Experiences",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            // Description
                            Text(
                              experience["description"] ?? "No Description",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
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
              "Achievements",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              // Description
                              Text(
                                achievement["description"] ?? "No Description",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
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
                  onPressed: () {},
                  child: Text("Request"),
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