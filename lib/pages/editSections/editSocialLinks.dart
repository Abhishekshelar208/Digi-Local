import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditSocialLinks extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditSocialLinks({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditSocialLinksState createState() => _EditSocialLinksState();
}

class _EditSocialLinksState extends State<EditSocialLinks> {
  final _formKey = GlobalKey<FormState>();
  late DatabaseReference _shopRef;

  TextEditingController facebookController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  TextEditingController digiLocalController = TextEditingController();
  TextEditingController youtubeController = TextEditingController();
  TextEditingController twitterController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    final accountLinks = (widget.shopData['accountLinks'] as Map?)?.cast<String, dynamic>() ?? {};
    facebookController.text = accountLinks['facebook']?.toString() ?? '';
    instagramController.text = accountLinks['instagram']?.toString() ?? '';
    whatsappController.text = accountLinks['whatsapp']?.toString() ?? '';
    digiLocalController.text = accountLinks['digiLocal']?.toString() ?? '';
    youtubeController.text = accountLinks['youtube']?.toString() ?? '';
    twitterController.text = accountLinks['twitter']?.toString() ?? '';
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        await _shopRef.update({
          "accountLinks": {
            "facebook": facebookController.text.trim(),
            "instagram": instagramController.text.trim(),
            "whatsapp": whatsappController.text.trim(),
            "digiLocal": digiLocalController.text.trim(),
            "youtube": youtubeController.text.trim(),
            "twitter": twitterController.text.trim(),
          },
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Social Links updated successfully!")),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text(
          "Edit Social Links",
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildSocialField(facebookController, 'Facebook URL', Icons.facebook, 'https://facebook.com/yourpage'),
                    SizedBox(height: 15),
                    _buildSocialField(instagramController, 'Instagram URL', Icons.camera_alt, 'https://instagram.com/youraccount'),
                    SizedBox(height: 15),
                    _buildSocialField(whatsappController, 'WhatsApp Number', Icons.phone, '+91XXXXXXXXXX'),
                    SizedBox(height: 15),
                    _buildSocialField(youtubeController, 'YouTube Channel', Icons.video_library, 'https://youtube.com/@yourchannel'),
                    SizedBox(height: 15),
                    _buildSocialField(twitterController, 'Twitter/X Profile', Icons.alternate_email, 'https://twitter.com/yourhandle'),
                    SizedBox(height: 15),
                    _buildSocialField(digiLocalController, 'Website URL', Icons.language, 'https://yourwebsite.com'),
                    SizedBox(height: 40),
                    ElevatedButton(
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
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSocialField(TextEditingController controller, String label, IconData icon, String hint) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black54),
        labelStyle: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
        hintStyle: GoogleFonts.blinker(fontSize: 14, color: Colors.grey),
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
      keyboardType: TextInputType.url,
    );
  }
}
