import 'dart:async';
import 'dart:ui';
import 'package:MrRecipe/pages/wrapper.dart';
import 'package:MrRecipe/services/auth.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    setValue();
    super.initState();
  }

  void setValue() async {
    final prefs = await SharedPreferences.getInstance();
    int launchCount = prefs.getInt('counter') ?? 0;
    prefs.setInt('counter', launchCount + 1);
    if (launchCount == 0) {
      print("first launch"); //setState to refresh or move to some other page
    } else {
      print("Not first launch");
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider logo = AssetImage("assets/images/starter-image.jpg");
    return MultiProvider(
      providers: [
        Provider<AuthService>(
            create: (_) => AuthService(FirebaseAuth.instance)),
        StreamProvider(
            create: (context) => context.read<AuthService>().authStateChanges)
      ],
      child: SafeArea(
        child: Scaffold(
          body: Container(
            //height: 400,
            //constraints: BoxConstraints.expand(height: 300),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: ResizeImage(logo, width: 500, height: 750),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(.9),
                    Colors.black.withOpacity(.8),
                    Colors.black.withOpacity(.2),
                  ],
                  begin: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      // Título
                      "Seja Bem-vindo ao Mr. Recipe",
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 50,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                        // Corpo
                        "Veja já as suas receitas favoritas!",
                        style: GoogleFonts.roboto(
                            color: Colors.white, fontSize: 20)),
                    const SizedBox(
                      height: 80,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(10)),
                      child: MaterialButton(
                        minWidth: double.infinity,
                        child: Text(
                          "Começar",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AuthWrapper()));
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
