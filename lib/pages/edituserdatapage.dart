import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EditUserDataPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  EditUserDataPage({required this.userData});

  @override
  _EditUserDataPageState createState() => _EditUserDataPageState();
}

class _EditUserDataPageState extends State<EditUserDataPage> {
  // Controllers for text fields
  late TextEditingController _fullNameController;
  late TextEditingController _aboutYourselfController;
  late TextEditingController _userEmailController;
  late TextEditingController _userTitleController;
  late TextEditingController _profilePictureController;
  late TextEditingController _noOfSkillsController;
  late TextEditingController _monthsOfExperienceController;
  late TextEditingController _internshipsCompletedController;
  late TextEditingController _noOfProjectsCompletedController;
  late TextEditingController _skillsController;
  late TextEditingController _softSkillsController;
  late TextEditingController _toolsController;
  late TextEditingController _resumeFileController;
  late TextEditingController _achievementsController;
  late TextEditingController _experiencesController;
  late TextEditingController _projectsController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current data
    _fullNameController = TextEditingController(text: widget.userData["personalInfo"]["fullName"]);
    _aboutYourselfController = TextEditingController(text: widget.userData["personalInfo"]["aboutyourself"]);
    _userEmailController = TextEditingController(text: widget.userData["personalInfo"]["useremail"]);
    _userTitleController = TextEditingController(text: widget.userData["personalInfo"]["usertitle"]);
    _profilePictureController = TextEditingController(text: widget.userData["personalInfo"]["profilePicture"]);
    _noOfSkillsController = TextEditingController(text: widget.userData["NoofSKills"]);
    _monthsOfExperienceController = TextEditingController(text: widget.userData["MonthsofExperience"]);
    _internshipsCompletedController = TextEditingController(text: widget.userData["InternshipsCompleted"]);
    _noOfProjectsCompletedController = TextEditingController(text: widget.userData["NoofProjectsCompleted"]);
    _skillsController = TextEditingController(text: widget.userData["skills"].join(", "));
    _softSkillsController = TextEditingController(text: widget.userData["softSkills"].join(", "));
    _toolsController = TextEditingController(text: widget.userData["tools"].join(", "));
    _resumeFileController = TextEditingController(text: widget.userData["resumefile"]);
    _achievementsController = TextEditingController(text: _formatAchievements(widget.userData["achievements"]));
    _experiencesController = TextEditingController(text: _formatExperiences(widget.userData["experiences"]));
    _projectsController = TextEditingController(text: _formatProjects(widget.userData["projects"]));
    _emailController = TextEditingController(text: widget.userData["accountLinks"]["email"]);
  }

  @override
  void dispose() {
    // Dispose controllers
    _fullNameController.dispose();
    _aboutYourselfController.dispose();
    _userEmailController.dispose();
    _userTitleController.dispose();
    _profilePictureController.dispose();
    _noOfSkillsController.dispose();
    _monthsOfExperienceController.dispose();
    _internshipsCompletedController.dispose();
    _noOfProjectsCompletedController.dispose();
    _skillsController.dispose();
    _softSkillsController.dispose();
    _toolsController.dispose();
    _resumeFileController.dispose();
    _achievementsController.dispose();
    _experiencesController.dispose();
    _projectsController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Helper methods to format lists into strings
  String _formatAchievements(List<dynamic> achievements) {
    return achievements.map((achievement) {
      return "${achievement["title"]}: ${achievement["description"]} (${achievement["image"]})";
    }).join("\n");
  }

  String _formatExperiences(List<dynamic> experiences) {
    return experiences.map((experience) {
      return "${experience["title"]}: ${experience["description"]}";
    }).join("\n");
  }

  String _formatProjects(List<dynamic> projects) {
    return projects.map((project) {
      // Ensure techstack is a List<String>
      List<String> techstack = (project["techstack"] is List)
          ? List<String>.from(project["techstack"])
          : [project["techstack"].toString()];

      return "${project["title"]}: ${project["description"]} (${techstack.join(", ")})";
    }).join("\n");
  }

  void _saveChanges() async {
    // Update the user data
    setState(() {
      widget.userData["personalInfo"]["fullName"] = _fullNameController.text;
      widget.userData["personalInfo"]["aboutyourself"] = _aboutYourselfController.text;
      widget.userData["personalInfo"]["useremail"] = _userEmailController.text;
      widget.userData["personalInfo"]["usertitle"] = _userTitleController.text;
      widget.userData["personalInfo"]["profilePicture"] = _profilePictureController.text;
      widget.userData["NoofSKills"] = _noOfSkillsController.text;
      widget.userData["MonthsofExperience"] = _monthsOfExperienceController.text;
      widget.userData["InternshipsCompleted"] = _internshipsCompletedController.text;
      widget.userData["NoofProjectsCompleted"] = _noOfProjectsCompletedController.text;
      widget.userData["skills"] = _skillsController.text.split(", ");
      widget.userData["softSkills"] = _softSkillsController.text.split(", ");
      widget.userData["tools"] = _toolsController.text.split(", ");
      widget.userData["resumefile"] = _resumeFileController.text;
      widget.userData["achievements"] = _parseAchievements(_achievementsController.text);
      widget.userData["experiences"] = _parseExperiences(_experiencesController.text);
      widget.userData["projects"] = _parseProjects(_projectsController.text);
      widget.userData["accountLinks"]["email"] = _emailController.text;
    });

    // Save the updated data to Firebase Realtime Database
    try {
      DatabaseReference userRef = FirebaseDatabase.instance.ref("Users/${widget.userData["userId"]}");
      await userRef.update(widget.userData);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );

      // Navigate back to the user data page
      Navigator.pop(context);
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

  // Helper methods to parse strings into lists
  List<Map<String, dynamic>> _parseAchievements(String text) {
    return text.split("\n").map((line) {
      var parts = line.split(": ");
      return {
        "title": parts[0],
        "description": parts[1].split(" (")[0],
        "image": parts[1].split(" (")[1].replaceAll(")", ""),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _parseExperiences(String text) {
    return text.split("\n").map((line) {
      var parts = line.split(": ");
      return {
        "title": parts[0],
        "description": parts[1],
      };
    }).toList();
  }

  List<Map<String, dynamic>> _parseProjects(String text) {
    return text.split("\n").map((line) {
      var parts = line.split(": ");
      return {
        "title": parts[0],
        "description": parts[1].split(" (")[0],
        "techstack": parts[1].split(" (")[1].replaceAll(")", "").split(", "),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Info
            Text("Personal Info", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: _aboutYourselfController,
              decoration: InputDecoration(labelText: "About Yourself"),
            ),
            TextField(
              controller: _userEmailController,
              decoration: InputDecoration(labelText: "User Email"),
            ),
            TextField(
              controller: _userTitleController,
              decoration: InputDecoration(labelText: "User Title"),
            ),
            TextField(
              controller: _profilePictureController,
              decoration: InputDecoration(labelText: "Profile Picture URL"),
            ),
            SizedBox(height: 20),

            // Skills
            Text("Skills", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _noOfSkillsController,
              decoration: InputDecoration(labelText: "Number of Skills"),
            ),
            TextField(
              controller: _skillsController,
              decoration: InputDecoration(labelText: "Skills (comma-separated)"),
            ),
            TextField(
              controller: _softSkillsController,
              decoration: InputDecoration(labelText: "Soft Skills (comma-separated)"),
            ),
            TextField(
              controller: _toolsController,
              decoration: InputDecoration(labelText: "Tools (comma-separated)"),
            ),
            SizedBox(height: 20),

            // Experience
            Text("Experience", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _monthsOfExperienceController,
              decoration: InputDecoration(labelText: "Months of Experience"),
            ),
            TextField(
              controller: _internshipsCompletedController,
              decoration: InputDecoration(labelText: "Internships Completed"),
            ),
            TextField(
              controller: _noOfProjectsCompletedController,
              decoration: InputDecoration(labelText: "Number of Projects Completed"),
            ),
            SizedBox(height: 20),

            // Achievements
            Text("Achievements", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _achievementsController,
              maxLines: 5,
              decoration: InputDecoration(labelText: "Achievements (one per line)"),
            ),
            SizedBox(height: 20),

            // Experiences
            Text("Experiences", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _experiencesController,
              maxLines: 5,
              decoration: InputDecoration(labelText: "Experiences (one per line)"),
            ),
            SizedBox(height: 20),

            // Projects
            Text("Projects", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _projectsController,
              maxLines: 5,
              decoration: InputDecoration(labelText: "Projects (one per line)"),
            ),
            SizedBox(height: 20),

            // Account Links
            Text("Account Links", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}