import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/shop_chat_service.dart';

class ShopChatScreen extends StatefulWidget {
  final Map<String, dynamic> shopData;

  const ShopChatScreen({super.key, required this.shopData});

  @override
  State<ShopChatScreen> createState() => _ShopChatScreenState();
}

class _ShopChatScreenState extends State<ShopChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ShopChatService _chatService = ShopChatService();
  
  List<Map<String, String>> _messages = [];
  bool _isTyping = false;
  bool _isSending = false;
  late String _shopId;

  @override
  void initState() {
    super.initState();
    _shopId = widget.shopData["shopInfo"]["shopName"] ?? "unknown_shop";
    
    // Load existing history or show welcome message
    _messages = _chatService.getHistory(_shopId);
    
    if (_messages.isEmpty) {
      final welcomeMsg = {
        'role': 'model',
        'message': 'Welcome to ${widget.shopData["shopInfo"]["shopName"]}! 👋\n\nI\'m your AI assistant. How can I help you today? Ask me about our products, timings, or location!'
      };
      setState(() {
        _messages = [welcomeMsg];
      });
      _chatService.saveMessage(_shopId, welcomeMsg);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    // 1. Add User Message
    final userMsg = {'role': 'user', 'message': text};
    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
      _isSending = true;
      _controller.clear();
    });
    _chatService.saveMessage(_shopId, userMsg);
    _scrollToBottom();

    // 2. Get AI Response
    try {
      final response = await _chatService.sendMessage(
        message: text,
        shopData: widget.shopData,
        history: _messages.take(_messages.length - 1).toList(),
      );

      // 3. Add AI Message
      if (mounted) {
        final modelMsg = {'role': 'model', 'message': response};
        setState(() {
          _isTyping = false;
          _messages.add(modelMsg);
        });
        _chatService.saveMessage(_shopId, modelMsg);
        _scrollToBottom();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _restartChat() async {
    _chatService.clearHistory(_shopId);
    setState(() {
      _messages = [];
    });
    
    // Show welcome message again
    final welcomeMsg = {
      'role': 'model',
      'message': 'Conversation restarted! 👋\n\nHow else can I help you today?'
    };
    setState(() {
      _messages = [welcomeMsg];
    });
    _chatService.saveMessage(_shopId, welcomeMsg);
    _scrollToBottom();
  }

  void _showRestartConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Restart Chat?", style: GoogleFonts.blinker(fontWeight: FontWeight.bold)),
        content: Text("This will clear your current conversation history.", style: GoogleFonts.blinker()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.blinker(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartChat();
            },
            child: Text("Restart", style: GoogleFonts.blinker(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EF),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.shopData["shopInfo"]["shopName"] ?? "Shop Chat",
              style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              "AI Assistant • Online",
              style: GoogleFonts.blinker(fontSize: 12, color: Colors.green),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black),
            tooltip: "Restart Chat",
            onPressed: _showRestartConfirmation,
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return _buildMessageBubble(msg['message']!, isUser);
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Typing...",
                  style: GoogleFonts.blinker(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.black : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message,
          style: GoogleFonts.blinker(
            fontSize: 16,
            color: isUser ? Colors.white : Colors.black87,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Ask about products...",
                hintStyle: GoogleFonts.blinker(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF2F0EF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.black,
            radius: 24,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
