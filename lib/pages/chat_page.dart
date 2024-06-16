import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translink/authentication/auth_service.dart';
import 'package:translink/components/chat_bubble.dart';
import 'package:translink/components/chat_textfield.dart';

import '../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Text controller
  final TextEditingController _messageController = TextEditingController();

  // Chat & auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // For text field focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Add listener to focus node
    myFocusNode.addListener(
      () {
        if (myFocusNode.hasFocus) {
          // Cause a delay so the keyboard has time to show up
          // Then the remaining amount of space will be calculated
          // Then scroll down
          Future.delayed(
            const Duration(milliseconds: 500),
            () => scrollDown(),
          );
        }
      },
    );

    // Wait a bit for list view to be built, then scroll to bottom
    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  // Scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Send message
  void sendMessage() async {
    // If there is something inside the text field
    if (_messageController.text.isNotEmpty) {
      // Send the message
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);

      // Clear text controller
      _messageController.clear();
    }

    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.receiverEmail,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(5),
          child: Container(
            height: 1.5,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          // Display all messages
          Expanded(
            child: _buildMessageList(),
          ),
          // User input
          _buildUserInput(),
        ],
      ),
    );
  }

  // Build message list
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      builder: (context, snapshot) {
        // Errors
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading ...");
        }

        // Return list view
        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
      stream: _chatService.getMessages(widget.receiverID, senderID),
    );
  }

  // Build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Is current user
    bool isCurrentUser = data["senderID"] == _authService.getCurrentUser()!.uid;

    // Align message to the right if sender is the current user, otherwise left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
          ),
        ],
      ),
    );
  }

  // Build message input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 25,
      ),
      child: Row(
        children: [
          // Text field should take up most of the space
          Expanded(
            child: ChatTextField(
              controller: _messageController,
              hintText: "Type a message ...",
              obscureText: false,
              focusNode: myFocusNode,
            ),
          ),

          // Send button
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.5, color: Colors.black,
              ),
              color: Colors.deepPurple[400],
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(
              right: 25,
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
