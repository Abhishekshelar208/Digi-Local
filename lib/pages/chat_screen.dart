import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String receiverName;

  ChatScreen({required this.chatId, required this.receiverName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref("chats");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _listenForMessages();
  }

  void _listenForMessages() {
    _chatRef.child(widget.chatId).onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> chatData = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> tempMessages = chatData.entries.map((entry) {
          return {
            "messageId": entry.key,
            "senderEmail": entry.value["senderEmail"],
            "message": entry.value["message"],
            "timestamp": entry.value["timestamp"],
          };
        }).toList();

        // Sort messages by timestamp (oldest to newest)
        tempMessages.sort((a, b) => a["timestamp"].compareTo(b["timestamp"]));

        setState(() {
          messages = tempMessages;
        });

        // Scroll to the last message after a short delay
        Future.delayed(Duration(milliseconds: 100), () {
          _scrollToBottom();
        });
      }
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    User? user = _auth.currentUser;
    if (user == null) return;

    String messageText = _messageController.text.trim();
    _messageController.clear();

    String messageId = _chatRef.child(widget.chatId).push().key!;
    await _chatRef.child(widget.chatId).child(messageId).set({
      "senderEmail": user.email,
      "message": messageText,
      "timestamp": DateTime.now().toIso8601String(),
    });

    // Scroll to the last message
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF), //off white,
      appBar: AppBar(
        title: Text(
          "Chat with ${widget.receiverName}",
          style: GoogleFonts.blinker(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF), //off white
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,  // Attach scroll controller
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                bool isMe = message["senderEmail"] == _auth.currentUser?.email;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue.shade400 : Color(0xFF4dc590),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message["message"], style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style:  GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(14),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
