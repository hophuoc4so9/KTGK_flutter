import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'image_upload_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
    String groupChatId,
    int limit,
  ) {
    return _firestore
        .collection('chatrooms')
        .doc(groupChatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<void> sendMessage({
    required String groupChatId,
    required String currentUserId,
    required String peerId,
    required String content,
    required int type,
  }) async {
    final DocumentReference messageRef = _firestore
        .collection('chatrooms')
        .doc(groupChatId)
        .collection('messages')
        .doc();

    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    await messageRef.set({
      'idFrom': currentUserId,
      'idTo': peerId,
      'timestamp': timestamp,
      'content': content,
      'type': type,
    });

    await _firestore.collection('chatrooms').doc(groupChatId).set({
      'users': [currentUserId, peerId],
      'lastMessage': type == 0
          ? content
          : type == 1
              ? '[Image]'
              : type == 2
                  ? '[Sticker]'
                  : '[Video]',
      'timestamp': timestamp,
      'lastSenderId': currentUserId,
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRecentChats(String userId) {
    return _firestore
        .collection('chatrooms')
        .where('users', arrayContains: userId)
        .snapshots();
  }

  Future<String> uploadChatImage(XFile imageFile) async {
    return await ImageUploadService.uploadImage(imageFile);
  }

  Future<String> uploadChatVideo(XFile videoFile) async {
    return await ImageUploadService.uploadVideo(videoFile);
  }
}
