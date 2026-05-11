import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'image_upload_service.dart';

class ChatService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

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
    DocumentReference messageRef = _firestore
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

    // Save parent metadata for Recent Chats listing
    await _firestore.collection('chatrooms').doc(groupChatId).set({
      'users': [currentUserId, peerId],
      'lastMessage': type == 0
          ? content
          : (type == 1 ? '[Hình ảnh]' : '[Sticker]'),
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

  Future<String> uploadChatImage(File imageFile) async {
    return await ImageUploadService.uploadImage(imageFile);
  }
}