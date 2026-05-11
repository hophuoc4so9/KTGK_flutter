import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
class AuthServices {

  Future<String> createAccountWithEmail(
    String email,
    String password,
) async {
  try {

    UserCredential userCredential =
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': email.split('@')[0],
        'email': email,
      });
    }

    return "Account created";

  } on FirebaseAuthException catch (e) {
    return e.message.toString();
  }
}
  Future<String> loginWithEmail(String email, String password) async {
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      return "Login successful";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }
  Future logout() async {
    await FirebaseAuth.instance.signOut();
    if(await GoogleSignIn().isSignedIn()){
      await GoogleSignIn().signOut();
    }
  }
 Future<String> continueWithGoogle() async {
  try {

    final GoogleSignInAccount? googleUser =
        await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential =
        GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance
            .signInWithCredential(credential);

    User? user = userCredential.user;

    if (user != null) {

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
      }, SetOptions(merge: true));
    }

    return "Login successful";

  } on FirebaseAuthException catch (e) {
    return e.message.toString();
  }
}
  Future<bool> isUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }
}

