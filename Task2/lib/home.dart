import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotuanphuoc_2224802010872_lab4/common/common.dart';
import 'package:hotuanphuoc_2224802010872_lab4/controllers/chat_service.dart';
import 'package:hotuanphuoc_2224802010872_lab4/controllers/user_service.dart';
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
  final int _limit = 20;
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.navyDark,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chat_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              "Messenger",
              style: GoogleFonts.sora(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.pushNamed(context, '/settings');
              } else if (value == 'logout') {
                _userService.logout().then((_) {
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                });
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: "Contacts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) {
      return _buildContactsTab();
    } else if (_currentIndex == 1) {
      return _buildChatsTab();
    } else {
      return const SettingsScreen(embedded: true);
    }
  }

  Widget _buildContactsTab() {
    return Column(
      children: [
        // Search bar
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: TextField(
            onChanged: (v) => setState(() => search = v),
            decoration: InputDecoration(
              hintText: "Search contacts...",
              hintStyle: AppTheme.caption.copyWith(fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _userService.getUsers(limit: _limit, search: search),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primary)),
                );
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search,
                          size: 72, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text("No contacts found",
                          style: AppTheme.caption.copyWith(fontSize: 15)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: docs.length,
                itemBuilder: (context, index) =>
                    _buildContactItem(context, docs[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final String nickname = data['nickname'] ?? data['email'] ?? 'No Name';
    final String photoUrl = data['photoUrl'] ?? '';
    final String aboutMe = data['aboutMe'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage:
                  photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
              child: photoUrl.isEmpty
                  ? Text(
                      nickname.isNotEmpty ? nickname[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.onlineGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          nickname,
          style: GoogleFonts.sora(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppTheme.navyDark),
        ),
        subtitle: aboutMe.isNotEmpty
            ? Text(aboutMe,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.caption.copyWith(fontSize: 13))
            : null,
        trailing: const Icon(Icons.chevron_right,
            color: AppTheme.primary, size: 20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                peerId: document.id,
                peerName: nickname,
                peerAvatar: photoUrl,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _chatService.getRecentChats(currentUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primary)),
          );
        }

        final docs = snapshot.data!.docs;
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
                Icon(Icons.forum_outlined,
                    size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text("No conversations yet",
                    style: GoogleFonts.sora(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text("Go to Contacts to start chatting",
                    style: AppTheme.caption),
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
  }
}

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
      future:
          FirebaseFirestore.instance.collection('users').doc(peerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final peerData =
            snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final String nickname =
            peerData['nickname'] ?? peerData['email'] ?? 'User';
        final String photoUrl = peerData['photoUrl'] ?? '';
        final String lastMessage = chatroomData['lastMessage'] ?? '';
        final String timestampStr = chatroomData['timestamp'] ?? '';

        String formattedTime = '';
        if (timestampStr.isNotEmpty) {
          try {
            final date = DateTime.fromMillisecondsSinceEpoch(
                int.parse(timestampStr));
            final now = DateTime.now();
            if (DateUtils.isSameDay(date, now)) {
              formattedTime =
                  "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
            } else {
              formattedTime =
                  "${date.day}/${date.month}";
            }
          } catch (_) {}
        }

        return Container(
          margin:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage:
                      photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                  child: photoUrl.isEmpty
                      ? Text(
                          nickname.isNotEmpty
                              ? nickname[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.onlineGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nickname,
                    style: GoogleFonts.sora(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.navyDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(formattedTime,
                    style:
                        AppTheme.caption.copyWith(color: Colors.grey.shade400)),
              ],
            ),
            subtitle: Container(
              margin: const EdgeInsets.only(top: 3),
              child: Text(
                lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.caption.copyWith(
                    color: Colors.grey.shade600, fontSize: 13),
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
