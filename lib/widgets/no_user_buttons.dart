import 'package:MrRecipe/pages/navigation/login_and_register.dart';
import 'package:page_transition/page_transition.dart';

import '../pages/app.dart';
import '../services/auth.dart';
import 'widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NoUserButtons extends StatefulWidget {
  @override
  _NoUserButtonsState createState() => _NoUserButtonsState();
}

class _NoUserButtonsState extends State<NoUserButtons> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Inicie a sessão para que possa criar e guardar as suas receitas favoritas",
          style: simpleTextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5),
        buildButton("Login", 0),
        buildButton("Registar", 1),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _isSigningIn
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(PrimaryColor),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: OutlinedButton(
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
                            builder: (context) => App(),
                          ),
                        );
                      } else {
                        setState(() {
                          _isSigningIn = false;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image(
                            image: AssetImage("assets/icons/google_icon.png"),
                            height: 32,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              "Login com o Google",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Container buildButton(String label, int pageState) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      width: MediaQuery.of(context).size.width / 1.5,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        onPressed: () => Navigator.push(
          context,
          PageTransition(
            child: LoginAndRegister(pageState: pageState),
            type: PageTransitionType.bottomToTop,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
