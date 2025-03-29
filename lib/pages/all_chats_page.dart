import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_screen.dart';

class AllChats extends StatefulWidget {
  @override
  _AllChatsState createState() => _AllChatsState();
}

class _AllChatsState extends State<AllChats> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _chatsRef = FirebaseDatabase.instance.ref().child("chats");
  List<Map<String, dynamic>> activeChats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActiveChats();
  }

  Future<void> _fetchActiveChats() async {
    User? user = _auth.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    String userEmail = user.email!.replaceAll('.', '_');
    List<Map<String, dynamic>> tempChats = [];

    DatabaseEvent chatsEvent = await _chatsRef.once();
    if (chatsEvent.snapshot.exists) {
      Map<dynamic, dynamic> chatsData = chatsEvent.snapshot.value as Map<dynamic, dynamic>;

      chatsData.forEach((chatId, chatMessages) {
        // Check if the chatId contains the current user's email
        if (chatId.contains(userEmail)) {
          // Extract the other party's email from the chatId
          String otherPartyEmail = chatId.replaceAll(userEmail, "").replaceAll("_", "");
          tempChats.add({
            "chatId": chatId,
            "otherPartyEmail": otherPartyEmail,
          });
        }
      });

      setState(() {
        activeChats = tempChats;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF), //off white,,
      appBar: AppBar(
        title: Text(
          "Chats",
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : activeChats.isEmpty
          ? Center(child: Text("No active chats.",style:  GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[700]),))
          : ListView.builder(
        itemCount: activeChats.length,
        itemBuilder: (context, index) {
          var chat = activeChats[index];
          return ListTile(
            title: Text(chat["otherPartyEmail"],style: GoogleFonts.blinker(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatId: chat["chatId"],
                    receiverName: chat["otherPartyEmail"], // You can replace this with the actual name if available
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}