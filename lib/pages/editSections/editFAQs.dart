import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditFAQs extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditFAQs({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditFAQsState createState() => _EditFAQsState();
}

class _EditFAQsState extends State<EditFAQs> {
  late DatabaseReference _shopRef;
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  List<Map<String, dynamic>> faqList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    _loadFAQs();
  }

  void _loadFAQs() {
    if (widget.shopData['faqs'] != null) {
      faqList = (widget.shopData['faqs'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
  }

  void _addFAQ() {
    if (questionController.text.isEmpty || answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both question and answer")),
      );
      return;
    }

    setState(() {
      faqList.add({
        "question": questionController.text.trim(),
        "answer": answerController.text.trim(),
      });
      questionController.clear();
      answerController.clear();
    });
  }

  void _removeFAQ(int index) {
    setState(() {
      faqList.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _shopRef.update({
        "faqs": faqList,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("FAQs updated successfully!")),
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
          "FAQs",
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
                  Text(
                    "Add FAQ",
                    style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 12),

                  // Question Input
                  TextField(
                    controller: questionController,
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                    decoration: InputDecoration(
                      labelText: 'Question',
                      hintText: 'e.g., Do you provide home delivery?',
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

                  // Answer Input
                  TextField(
                    controller: answerController,
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Answer',
                      hintText: 'e.g., Yes, we deliver within 5 km radius',
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
                    onPressed: _addFAQ,
                    icon: Icon(Icons.add),
                    label: Text("Add FAQ"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  SizedBox(height: 24),

                  // FAQ List
                  Text(
                    "FAQs (${faqList.length})",
                    style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 12),

                  if (faqList.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          "No FAQs added yet",
                          style: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...faqList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final faq = entry.value;
                      return Card(
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              "Q${index + 1}",
                              style: GoogleFonts.blinker(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                          title: Text(
                            faq['question'],
                            style: GoogleFonts.blinker(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeFAQ(index),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  faq['answer'],
                                  style: GoogleFonts.blinker(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }
}
