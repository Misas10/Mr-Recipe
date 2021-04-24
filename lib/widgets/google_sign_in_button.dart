import '../pages/app.dart';
import '../services/auth.dart';
import '../widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GoogleSignInButton extends StatefulWidget {
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _isSigningIn
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(PrimaryColor),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              onPressed: () async {
                setState(() {
                  _isSigningIn = true;
                });
                User user =
                    await AuthService.signInWithGoogle(context: context);
                setState(() {
                  _isSigningIn = false;
                });
                if (user != null) {
                  setState(() {
                    accountType = "google";
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => App(user: user),
                    ),
                  );
                } else {
                  setState(() {
                    _isSigningIn = false;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image(
                      image: AssetImage("assets/icons/google_icon.png"),
                      height: 35,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        "Login com o Google",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
