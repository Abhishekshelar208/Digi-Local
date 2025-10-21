import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditEvents extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditEvents({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditEventsState createState() => _EditEventsState();
}

class _EditEventsState extends State<EditEvents> {
  late DatabaseReference _shopRef;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<Map<String, dynamic>> eventsList = [];
  File? _selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    _loadEvents();
  }

  void _loadEvents() {
    if (widget.shopData['Events'] != null) {
      eventsList = (widget.shopData['Events'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File imageFile, String title) async {
    Reference storageRef = FirebaseStorage.instance.ref().child('events/${widget.shopId}/${DateTime.now().millisecondsSinceEpoch}_$title.jpg');
    await storageRef.putFile(imageFile);
    return await storageRef.getDownloadURL();
  }

  Future<void> _addEvent() async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter event title")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String imageUrl = "https://www.infopedia.ai/no-image.png";
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!, titleController.text);
      }

      setState(() {
        eventsList.add({
          "title": titleController.text,
          "description": descriptionController.text,
          "image": imageUrl,
        });
        titleController.clear();
        descriptionController.clear();
        _selectedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _removeEvent(int index) {
    setState(() {
      eventsList.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _shopRef.update({
        "Events": eventsList,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Events updated successfully!")),
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
          "Edit Events/Gallery",
          style: GoogleFonts.blinker(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Event/Gallery Image",
                    style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: titleController,
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                    decoration: InputDecoration(
                      hintText: 'Event title',
                      hintStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
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
                  SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Event description (optional)',
                      hintStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
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
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.image),
                        label: Text(_selectedImage == null ? "Pick Image" : "Image Selected"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedImage == null ? Colors.grey[700] : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _addEvent,
                        child: Text("Add Event"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Gallery (${eventsList.length} items)",
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: eventsList.isEmpty
                        ? Center(
                            child: Text(
                              "No events added yet",
                              style: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: eventsList.length,
                            itemBuilder: (context, index) {
                              final event = eventsList[index];
                              return Card(
                                color: Colors.white,
                                elevation: 2,
                                margin: EdgeInsets.symmetric(vertical: 5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      event['image'],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) => Icon(Icons.image, size: 60),
                                    ),
                                  ),
                                  title: Text(
                                    event['title'],
                                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  subtitle: event['description'].isNotEmpty
                                      ? Text(
                                          event['description'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.blinker(fontSize: 14, color: Colors.grey[600]),
                                        )
                                      : null,
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeEvent(index),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  SizedBox(height: 20),
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
}
