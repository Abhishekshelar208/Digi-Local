import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'dart:convert';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String chatRoomId;
  final String userName;
  final String userId;

  ChatPage({required this.chatRoomId, required this.userName, required this.userId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<types.Message> _messages = [];
  late types.User _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _currentUser = types.User(id: user.uid, firstName: user.displayName);
      _loadMessages();
    }
  }

  void _loadMessages() {
    _database.child("chats/${widget.chatRoomId}").onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        List<types.Message> loadedMessages = [];
        data.forEach((key, value) {
          loadedMessages.add(types.TextMessage(
            id: key,
            author: types.User(id: value["senderId"] ?? ""),
            text: value["text"] ?? "",
            createdAt: value["timestamp"],
          ));
        });
        setState(() {
          _messages = loadedMessages.reversed.toList();
        });
      }
    });
  }

  void _sendMessage(types.PartialText message) {
    String messageId = Uuid().v4();
    _database.child("chats/${widget.chatRoomId}/$messageId").set({
      "senderId": _currentUser.id,
      "text": message.text,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with ${widget.userName}")),
      body: Chat(
        messages: _messages,
        onSendPressed: (message) => _sendMessage(message),
        user: _currentUser,
      ),
    );
  }
}
