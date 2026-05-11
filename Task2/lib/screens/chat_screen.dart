import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hotuanphuoc_2224802010872_lab4/controllers/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String peerAvatar;

  const ChatScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    required this.peerAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  bool isShowSticker = false;
  bool isLoading = false;
  int limit = 20;

  late String currentUserId;
  late String groupChatId;

  
  final List<String> localStickers = [
    'images/gif1.gif',
    'images/gif2.gif',
    'images/gif3.gif',
    'images/gif4.gif',
  ];

  @override
  void initState() {
    super.initState();

    currentUserId = FirebaseAuth.instance.currentUser!.uid;

    groupChatId = getGroupChatId(
      currentUserId,
      widget.peerId,
    );

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          isShowSticker = false;
        });
      }
    });
  }

  String getGroupChatId(
    String currentId,
    String peerId,
  ) {
    if (currentId.hashCode <= peerId.hashCode) {
      return '$currentId-$peerId';
    } else {
      return '$peerId-$currentId';
    }
  }

  Future<void> sendTextMessage() async {
    if (textController.text.trim().isEmpty) return;

    await _chatService.sendMessage(
      groupChatId: groupChatId,
      currentUserId: currentUserId,
      peerId: widget.peerId,
      content: textController.text.trim(),
      type: 0,
    );

    textController.clear();
    _scrollToBottom();
  }

  Future<void> sendImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, 
    );

    if (picked == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      String imageUrl = await _chatService.uploadChatImage(
        File(picked.path),
      );

      await _chatService.sendMessage(
        groupChatId: groupChatId,
        currentUserId: currentUserId,
        peerId: widget.peerId,
        content: imageUrl,
        type: 1,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> sendSticker(String stickerUrl) async {
    await _chatService.sendMessage(
      groupChatId: groupChatId,
      currentUserId: currentUserId,
      peerId: widget.peerId,
      content: stickerUrl,
      type: 2, 
    );

    setState(() {
      isShowSticker = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isMe = data['idFrom'] == currentUserId;
    int type = data['type'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.peerAvatar.isNotEmpty
                  ? NetworkImage(widget.peerAvatar)
                  : null,
              child: widget.peerAvatar.isEmpty
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
          ],

        
          type == 2
              ? _buildStickerMessage(data['content'])
              : _buildStandardMessage(data['content'], type, isMe),
        ],
      ),
    );
  }

  
  Widget _buildStickerMessage(String assetPath) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Image.asset(
        assetPath,
        width: 120,
        height: 120,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
        },
      ),
    );
  }

  // Classic Chat Bubble (Text or Image)
  Widget _buildStandardMessage(String content, int type, bool isMe) {
    return Container(
      padding: type == 0
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
          : EdgeInsets.zero,
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: type == 0
            ? (isMe ? const Color(0xFF6C63FF) : Colors.grey.shade100)
            : Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
        boxShadow: type == 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: type == 0
          ? Text(
              content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.3,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                content,
                width: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 200,
                    height: 150,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
    );
  }

  Widget buildInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            // Image Picker Button
            IconButton(
              onPressed: sendImage,
              icon: const Icon(Icons.image_outlined, color: Color(0xFF6C63FF)),
            ),

            // Sticker Drawer Toggle Button
            IconButton(
              onPressed: () {
                focusNode.unfocus();
                setState(() {
                  isShowSticker = !isShowSticker;
                });
              },
              icon: Icon(
                isShowSticker ? Icons.keyboard : Icons.emoji_emotions_outlined,
                color: const Color(0xFF6C63FF),
              ),
            ),

            // Input TextField
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: textController,
                  focusNode: focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => sendTextMessage(),
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Send Button
            CircleAvatar(
              backgroundColor: const Color(0xFF6C63FF),
              radius: 18,
              child: IconButton(
                onPressed: sendTextMessage,
                icon: const Icon(Icons.send, color: Colors.white, size: 16),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sticker Grid Drawer View
  Widget buildStickerPanel() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: localStickers.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => sendSticker(localStickers[index]),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                localStickers[index],
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isShowSticker,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isShowSticker) {
          setState(() {
            isShowSticker = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6FB),
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          leading: const BackButton(color: Colors.black87),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: widget.peerAvatar.isNotEmpty
                    ? NetworkImage(widget.peerAvatar)
                    : null,
                child: widget.peerAvatar.isEmpty
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.peerName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Chat list messages
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _chatService.getMessages(
                      groupChatId,
                      limit,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Say hello to ${widget.peerName}!",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        reverse: true,
                        controller: scrollController,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          return buildMessageItem(docs[index]);
                        },
                      );
                    },
                  ),
                ),

                // Input Bar
                buildInput(),

                // Sticker Panel Drawer
                if (isShowSticker) buildStickerPanel(),
              ],
            ),

            // Loading state screen overlay
            if (isLoading)
              Container(
                color: Colors.black12,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}