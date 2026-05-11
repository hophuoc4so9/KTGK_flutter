import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrudServices {
  Future<String> addNewContacts(String name, String phone, String email) async {
        User? user = FirebaseAuth.instance.currentUser;
    if (user == null)   throw Exception("User not logged in");

    Map<String, dynamic> data = {
      'name': name,
      'phone': phone,
      'email': email
    };
    try {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).collection("contacts").add(data);
      return "Document added successfully";
    } catch (e) {
      return e.toString();
    }
  }
  Future<String> updateContacts(String id, String name, String phone, String email) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null)   throw Exception("User not logged in");
    Map<String, dynamic> data = {
      'name': name,
      'phone': phone,
      'email': email
    };
    try {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).collection("contacts").doc(id).update(data);
      return "Document updated successfully";
    } catch (e) {
      return e.toString();
    }
  }
  Stream<QuerySnapshot> getContacts({String? search}) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null)   throw Exception("User not logged in");


    var contacts = FirebaseFirestore.instance.collection("users").doc(user!.uid).collection("contacts").orderBy("name");
    if (search != null && search.isNotEmpty) {
      String searchEnd = search + '\uf8ff';
      contacts = contacts.where("name", isLessThan: searchEnd);
    }
    return contacts.snapshots();
  }
  Future<String> deleteContacts(String id) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null)   throw Exception("User not logged in");

    try {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).collection("contacts").doc(id).delete();
      return "Document deleted successfully";
    } catch (e) {
      return e.toString();
    }
  }
  
}