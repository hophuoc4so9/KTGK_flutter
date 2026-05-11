import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
class AuthServices {

  Future<String> createAccountWithEmail(String email, String password) async {
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
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
    try{
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
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

