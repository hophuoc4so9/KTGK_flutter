import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotuanphuoc_2224802010872_lab4/common/common.dart';
import 'package:hotuanphuoc_2224802010872_lab4/controllers/chat_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

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
    groupChatId = _getGroupChatId(currentUserId, widget.peerId);

    focusNode.addListener(() {
      if (focusNode.hasFocus && mounted) {
        setState(() => isShowSticker = false);
      }
    });
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  String _getGroupChatId(String a, String b) =>
      a.hashCode <= b.hashCode ? '$a-$b' : '$b-$a';

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
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;
    setState(() => isLoading = true);
    try {
      final url = await _chatService.uploadChatImage(picked);
      await _chatService.sendMessage(
        groupChatId: groupChatId,
        currentUserId: currentUserId,
        peerId: widget.peerId,
        content: url,
        type: 1,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
      _scrollToBottom();
    }
  }

  Future<void> sendVideo() async {
    final picked =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => isLoading = true);
    try {
      final url = await _chatService.uploadChatVideo(picked);
      await _chatService.sendMessage(
        groupChatId: groupChatId,
        currentUserId: currentUserId,
        peerId: widget.peerId,
        content: url,
        type: 3,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
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
    if (mounted) setState(() => isShowSticker = false);
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

  // --- Message builder ---

  Widget buildMessageItem(
      DocumentSnapshot document, DocumentSnapshot? prevDocument) {
    final data = document.data() as Map<String, dynamic>;
    final prevData = prevDocument?.data() as Map<String, dynamic>?;
    final bool isMe = data['idFrom'] == currentUserId;
    final int type = data['type'] ?? 0;

    final int ts = int.tryParse(data['timestamp'] ?? '') ?? 0;
    final int prevTs =
        int.tryParse(prevData?['timestamp'] ?? '') ?? 0;

    final DateTime date = DateTime.fromMillisecondsSinceEpoch(ts);
    final DateTime? prevDate =
        prevTs > 0 ? DateTime.fromMillisecondsSinceEpoch(prevTs) : null;

    final bool showSeparator =
        prevDate == null || !DateUtils.isSameDay(date, prevDate);

    return Column(
      children: [
        if (showSeparator) _buildDateSeparator(date),
        Container(
          margin:
              const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 15,
                  backgroundImage: widget.peerAvatar.isNotEmpty
                      ? NetworkImage(widget.peerAvatar)
                      : null,
                  backgroundColor:
                      AppTheme.primary.withValues(alpha: 0.15),
                  child: widget.peerAvatar.isEmpty
                      ? Text(
                          widget.peerName.isNotEmpty
                              ? widget.peerName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
              ],
              type == 2
                  ? _buildStickerMessage(data['content'])
                  : type == 3
                      ? _buildVideoMessage(data['content'], isMe)
                      : _buildStandardMessage(
                          data['content'], type, isMe),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    String label;
    if (DateUtils.isSameDay(date, now)) {
      label = 'Today';
    } else if (DateUtils.isSameDay(
        date, now.subtract(const Duration(days: 1)))) {
      label = 'Yesterday';
    } else {
      label = DateFormat('MMMM d, yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(children: [
        Expanded(
            child: Divider(color: Colors.grey.shade300, thickness: 0.8)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(label,
                style: AppTheme.caption
                    .copyWith(color: Colors.grey.shade700)),
          ),
        ),
        Expanded(
            child: Divider(color: Colors.grey.shade300, thickness: 0.8)),
      ]),
    );
  }

  Widget _buildStickerMessage(String assetPath) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Image.asset(
        assetPath,
        width: 110,
        height: 110,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) =>
            const Icon(Icons.broken_image, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildStandardMessage(String content, int type, bool isMe) {
    if (type == 1) {
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => _FullscreenImageScreen(imageUrl: content)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          child: CachedNetworkImage(
            imageUrl: content,
            width: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 200,
              height: 150,
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              width: 200,
              height: 150,
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image,
                  color: Colors.grey, size: 40),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        gradient: isMe ? AppTheme.sentBubbleGradient : null,
        color: isMe ? null : AppTheme.receivedBubble,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Text(
        content,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black87,
          fontSize: 15,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _buildVideoMessage(String videoUrl, bool isMe) {
    final thumbnailUrl = videoUrl
        .replaceFirst('/upload/', '/upload/w_300,h_200,c_fill,so_0/')
        .replaceAll(RegExp(r'\.\w+$'), '.jpg');

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => _VideoPlayerScreen(videoUrl: videoUrl)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: thumbnailUrl,
              width: 200,
              height: 150,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 200,
                height: 150,
                color: Colors.grey.shade300,
                child:
                    const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                width: 200,
                height: 150,
                color: Colors.grey.shade800,
                child: const Icon(Icons.videocam,
                    size: 48, color: Colors.white54),
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow,
                  color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  // --- Input bar ---

  Widget buildInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: sendImage,
              icon: const Icon(Icons.image_outlined,
                  color: AppTheme.primary),
              tooltip: "Send image",
            ),
            IconButton(
              onPressed: sendVideo,
              icon: const Icon(Icons.videocam_outlined,
                  color: AppTheme.primary),
              tooltip: "Send video",
            ),
            IconButton(
              onPressed: () {
                focusNode.unfocus();
                setState(() => isShowSticker = !isShowSticker);
              },
              icon: Icon(
                isShowSticker
                    ? Icons.keyboard
                    : Icons.emoji_emotions_outlined,
                color: AppTheme.primary,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.receivedBubble,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: textController,
                  focusNode: focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => sendTextMessage(),
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: AppTheme.caption.copyWith(fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: sendTextMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: AppTheme.sentBubbleGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStickerPanel() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
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
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(localStickers[index],
                  fit: BoxFit.contain),
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
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (isShowSticker) setState(() => isShowSticker = false);
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          elevation: 0.5,
          backgroundColor: Colors.white,
          leading: const BackButton(color: AppTheme.navyDark),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: widget.peerAvatar.isNotEmpty
                    ? NetworkImage(widget.peerAvatar)
                    : null,
                backgroundColor:
                    AppTheme.primary.withValues(alpha: 0.15),
                child: widget.peerAvatar.isEmpty
                    ? Text(
                        widget.peerName.isNotEmpty
                            ? widget.peerName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold),
                      )
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
                        color: AppTheme.navyDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: const BoxDecoration(
                            color: AppTheme.onlineGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Text(
                          'Online',
                          style: TextStyle(
                              color: AppTheme.onlineGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
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
                Expanded(
                  child: StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                    stream:
                        _chatService.getMessages(groupChatId, limit),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                    AppTheme.primary)));
                      }

                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary
                                      .withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 56,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Say hello to ${widget.peerName}!",
                                style: AppTheme.caption
                                    .copyWith(fontSize: 15),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10),
                        reverse: true,
                        controller: scrollController,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final prevDoc = index + 1 < docs.length
                              ? docs[index + 1]
                              : null;
                          return buildMessageItem(
                              docs[index], prevDoc);
                        },
                      );
                    },
                  ),
                ),
                buildInput(),
                if (isShowSticker) buildStickerPanel(),
              ],
            ),
            if (isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                              AppTheme.primary)),
                      SizedBox(height: 12),
                      Text("Uploading...",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Fullscreen image viewer ---

class _FullscreenImageScreen extends StatelessWidget {
  final String imageUrl;

  const _FullscreenImageScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation(AppTheme.primary)),
            errorWidget: (context, url, error) =>
                const Icon(Icons.broken_image, color: Colors.white54),
          ),
        ),
      ),
    );
  }
}

// --- Video player screen ---

class _VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerScreen({required this.videoUrl});

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..initialize().then((_) {
            if (mounted) {
              setState(() => _initialized = true);
              _controller.play();
            }
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation(AppTheme.primary)),
      ),
      floatingActionButton: _initialized
          ? FloatingActionButton(
              backgroundColor: AppTheme.primary,
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}
