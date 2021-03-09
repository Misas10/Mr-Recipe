import 'dart:ui';
import 'package:MrRecipe/pages/wrapper.dart';
import 'package:MrRecipe/services/auth.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    var connectivityResult = await (Connectivity().checkConnectivity());
    debugPrint(connectivityResult.toString());
    if (connectivityResult == ConnectivityResult.mobile) {
       // I am connected to a mobile network.
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
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
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontFamily: 'Lato'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      // Corpo
                      "Veja já as suas receitas favoritas!",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Roboto'),
                    ),
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
