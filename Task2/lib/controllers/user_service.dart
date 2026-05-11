import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'image_upload_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>?> getUserInfo() async {
    User? user = currentUser;

    if (user == null) return null;

    DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();

    return doc.data() as Map<String, dynamic>?;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUsers({
  int limit = 10,
  String? search,
}) {
  User? user = currentUser;

  if (user == null) {
    throw Exception("User not logged in");
  }

  Query<Map<String, dynamic>> query = _firestore
      .collection('users')
      .where(
        FieldPath.documentId,
        isNotEqualTo: user.uid,
      );

  if (search != null && search.isNotEmpty) {
    query = query
        .where(
          'nickname',
          isGreaterThanOrEqualTo: search,
        )
        .where(
          'nickname',
          isLessThanOrEqualTo: '$search\uf8ff',
        );
  }

  return query.limit(limit).snapshots();
}

  Future<String> uploadAvatar(File imageFile) async {
    return await ImageUploadService.uploadImage(imageFile);
  }

  Future<void> updateProfile({
    required String nickname,
    required String aboutMe,
    String? photoUrl,
  }) async {
    User? user = currentUser;

    if (user == null) throw Exception("User not logged in");

    await _firestore.collection('users').doc(user.uid).set({
      'nickname': nickname,
      'aboutMe': aboutMe,
      'photoUrl': photoUrl ?? '',
      'email': user.email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}