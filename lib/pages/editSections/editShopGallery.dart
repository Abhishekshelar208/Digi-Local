import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditShopGallery extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditShopGallery({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditShopGalleryState createState() => _EditShopGalleryState();
}

class _EditShopGalleryState extends State<EditShopGallery> {
  late DatabaseReference _shopRef;
  List<String> galleryImages = [];
  bool isLoading = false;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    _loadGallery();
  }

  void _loadGallery() {
    galleryImages = (widget.shopData['shopGallery'] as List?)?.map((e) => e.toString()).toList() ?? [];
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      isUploading = true;
    });

    try {
      String imageUrl = await _uploadImage(File(pickedFile.path));
      setState(() {
        galleryImages.add(imageUrl);
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully!")),
      );
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: ${e.toString()}")),
      );
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('shop_gallery/${widget.shopId}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await storageRef.putFile(imageFile);
    return await storageRef.getDownloadURL();
  }

  void _removeImage(int index) {
    setState(() {
      galleryImages.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _shopRef.update({
        "shopGallery": galleryImages,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gallery updated successfully!")),
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
          "Shop Gallery",
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
                              "Upload images of your shop interior, products, or ambiance",
                              style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Add Image Button
                  ElevatedButton.icon(
                    onPressed: isUploading ? null : _pickAndUploadImage,
                    icon: isUploading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(Icons.add_photo_alternate),
                    label: Text(isUploading ? "Uploading..." : "Add Image"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Gallery Grid
                  Text(
                    "Gallery Images (${galleryImages.length})",
                    style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 12),

                  if (galleryImages.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Column(
                          children: [
                            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "No images in gallery yet",
                              style: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: galleryImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                galleryImages[index],
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) => Container(
                                  color: Colors.grey.shade300,
                                  child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red.withOpacity(0.8),
                                  padding: EdgeInsets.all(8),
                                ),
                                onPressed: () => _removeImage(index),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

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
}
