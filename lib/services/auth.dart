import 'package:MrRecipe/widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  bool isSigningIn;

  AuthService(this._firebaseAuth);

  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  // GET CURRENT USER
  Future getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  // Sign in with email and password
  Future<String> logIn({String email, String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      debugPrint("Logged Succefully");
      return "Logado";
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return e.message;
    }
  }

  // Register with email and password
  Future<String> register({String email, String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      debugPrint("Registered Succefully");
      return "Registado";
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return e.message;
    }
  }

  static Future signInWithGoogle({@required BuildContext context}) async {
    final googleSignIn = GoogleSignIn();
    final _firebaseAuth = FirebaseAuth.instance;
    User user;
    // isSigningIn = true;

    final googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      // isSigningIn = false;
      final googleAuth = await googleSignInAccount.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      try {
        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          debugPrint("Este utilizador já existe");
        } else if (e.code == 'invalid-credential') {
          debugPrint("Ocorreu um erro ao acessar as credenciais");
        }
      } catch (e) {
        debugPrint("Ocorreu um erro ao fazer Login com o Google");
      }

      return user;
    }
  }

  // Desconeta a conta atual 'logada'
  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();

    if (accountType == "google") {
      await googleSignIn.disconnect();
    }
    await _firebaseAuth.signOut();
  }
}
