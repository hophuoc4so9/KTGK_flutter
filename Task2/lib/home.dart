import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotuanphuoc_2224802010872_lab4/controllers/user_service.dart';
import 'package:hotuanphuoc_2224802010872_lab4/controllers/chat_service.dart';
import 'package:hotuanphuoc_2224802010872_lab4/screens/chat_screen.dart';
import 'package:hotuanphuoc_2224802010872_lab4/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String search = "";
  int _limit = 10;
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();
  Color themeColor = const Color(0xFF6C63FF);
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep AppBar exactly as your original code with the "..." PopupMenuButton
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                print("Settings");
                Navigator.pushNamed(context, '/settings');
              } else if (value == 'logout') {
                 _userService.logout().then((_) {
                  Navigator.pushReplacementNamed(context, '/login');
                });
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 10),
                    Text("Settings"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text("Logout"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      // Add bottom navigation bar to switch between tabs
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: themeColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) {
      // TAB 1: Original Home user list
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _userService.getUsers(
          limit: _limit,
          search: search,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return buildItem(
                  context,
                  snapshot.data!.docs[index],
                );
              },
            );
          }
        },
      );
    } else if (_currentIndex == 1) {
      // TAB 2: Recent Chats list stream
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _chatService.getRecentChats(currentUserId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          // Sort recent chats by timestamp descending
          docs.sort((a, b) {
            final tA = a.data()['timestamp'] ?? '0';
            final tB = b.data()['timestamp'] ?? '0';
            return tB.compareTo(tA);
          });

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "No recent conversations",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return RecentChatTile(
                chatroomData: docs[index].data(),
                currentUserId: currentUserId,
              );
            },
          );
        },
      );
    } else {
      // TAB 3: Embedded Settings screen
      return const SettingsScreen();
    }
  }

  // Exact original buildItem code for displaying each contact
  Widget buildItem(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    Map<String, dynamic> data = document.data();

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: data['photoUrl'] != null && data['photoUrl'] != ''
              ? NetworkImage(data['photoUrl'])
              : null,
          child: data['photoUrl'] == null || data['photoUrl'] == ''
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(data['nickname'] ?? data['email'] ?? 'No Name'),
        subtitle: Text(data['aboutMe'] ?? ''),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                peerId: document.id,
                peerName: data['nickname'] ?? '',
                peerAvatar: data['photoUrl'] ?? '',
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- SUB-WIDGET: RECENT CHAT TILE ---
class RecentChatTile extends StatelessWidget {
  final Map<String, dynamic> chatroomData;
  final String currentUserId;

  const RecentChatTile({
    super.key,
    required this.chatroomData,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> users = chatroomData['users'] ?? [];
    final String peerId = users.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    if (peerId.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(peerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final peerData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final String nickname = peerData['nickname'] ?? peerData['email'] ?? 'User';
        final String photoUrl = peerData['photoUrl'] ?? '';
        final String lastMessage = chatroomData['lastMessage'] ?? '';
        final String timestampStr = chatroomData['timestamp'] ?? '';

        String formattedTime = '';
        if (timestampStr.isNotEmpty) {
          try {
            final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestampStr));
            formattedTime = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
          } catch (_) {}
        }

        return Card(
          elevation: 0.5,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 26,
              backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty ? const Icon(Icons.person, size: 28) : null,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nickname,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formattedTime,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ],
            ),
            subtitle: Container(
              margin: const EdgeInsets.only(top: 4),
              child: Text(
                lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    peerId: peerId,
                    peerName: nickname,
                    peerAvatar: photoUrl,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}