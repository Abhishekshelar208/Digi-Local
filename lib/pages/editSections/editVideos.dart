import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditVideos extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditVideos({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditVideosState createState() => _EditVideosState();
}

class _EditVideosState extends State<EditVideos> {
  late DatabaseReference _shopRef;
  TextEditingController titleController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  List<Map<String, dynamic>> videosList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    _loadVideos();
  }

  void _loadVideos() {
    if (widget.shopData['videos'] != null) {
      videosList = (widget.shopData['videos'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
  }

  String _extractYouTubeVideoId(String url) {
    // Extract YouTube video ID from various URL formats
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1) ?? '';
  }

  String _getThumbnailUrl(String videoUrl) {
    final videoId = _extractYouTubeVideoId(videoUrl);
    if (videoId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
    return 'https://via.placeholder.com/320x180?text=No+Thumbnail';
  }

  void _addVideo() {
    if (titleController.text.isEmpty || urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both title and URL")),
      );
      return;
    }

    final videoId = _extractYouTubeVideoId(urlController.text);
    if (videoId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid YouTube URL")),
      );
      return;
    }

    setState(() {
      videosList.add({
        "title": titleController.text.trim(),
        "url": urlController.text.trim(),
        "thumbnail": _getThumbnailUrl(urlController.text),
      });
      titleController.clear();
      urlController.clear();
    });
  }

  void _removeVideo(int index) {
    setState(() {
      videosList.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _shopRef.update({
        "videos": videosList,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Videos updated successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text(
          "Shop Videos",
          style: GoogleFonts.blinker(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Card(
                    color: Colors.blue.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Add YouTube videos to showcase your shop, products, or services",
                              style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  Text(
                    "Add Video",
                    style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 12),

                  // Title Input
                  TextField(
                    controller: titleController,
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                    decoration: InputDecoration(
                      labelText: 'Video Title',
                      hintText: 'e.g., Shop Tour 2024',
                      prefixIcon: Icon(Icons.title),
                      hintStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
                      labelStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // URL Input
                  TextField(
                    controller: urlController,
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                    decoration: InputDecoration(
                      labelText: 'YouTube URL',
                      hintText: 'https://youtube.com/watch?v=...',
                      prefixIcon: Icon(Icons.link),
                      hintStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
                      labelStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Add Button
                  ElevatedButton.icon(
                    onPressed: _addVideo,
                    icon: Icon(Icons.add),
                    label: Text("Add Video"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Videos List
                  Text(
                    "Videos (${videosList.length})",
                    style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 12),

                  if (videosList.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "No videos added yet",
                              style: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...videosList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final video = entry.value;
                      return Card(
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              video['thumbnail'],
                              width: 80,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => Container(
                                width: 80,
                                height: 60,
                                color: Colors.grey.shade300,
                                child: Icon(Icons.video_library, color: Colors.grey),
                              ),
                            ),
                          ),
                          title: Text(
                            video['title'],
                            style: GoogleFonts.blinker(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            video['url'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.blinker(fontSize: 12, color: Colors.blue),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeVideo(index),
                          ),
                        ),
                      );
                    }).toList(),

                  SizedBox(height: 32),

                  // Save Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        minimumSize: Size(200, 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "Save Changes",
                        style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    urlController.dispose();
    super.dispose();
  }
}
