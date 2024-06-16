import 'package:flutter/material.dart';
import 'package:translink/services/chat_service.dart';
import '../authentication/auth_service.dart';
import '../components/user_tile.dart';
import 'chat_page.dart';

class ChatRoomsPage extends StatefulWidget {
  ChatRoomsPage({Key? key}) : super(key: key);

  @override
  _ChatRoomsPageState createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
            child: const Center(
              child: Text(
                "Chat Rooms",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 5, 25, 15),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by a user's name",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  // Build a list for the users except for the current logged-in user
  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        // Error
        if (snapshot.hasError) {
          return const Center(
            child: Text("Error fetching users"),
          );
        }

        // Loading ...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Check if data exists
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No users found"),
          );
        }

        // Filter the user list based on the search query
        final filteredUsers = snapshot.data!.where((userData) {
          final fullName = userData["fullName"].toLowerCase();
          return fullName.contains(_searchQuery) &&
              userData["email"] != _authService.getCurrentUser()?.email;
        }).toList();

        // Return list view
        return ListView(
          children: filteredUsers
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // Build individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    return UserTile(
      text: userData["fullName"],
      onTap: () {
        // Tapped on a user -> go to chat page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverEmail: userData["email"],
              receiverID: userData["uid"],
            ),
          ),
        );
      },
    );
  }
}
