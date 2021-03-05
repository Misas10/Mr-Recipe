import 'package:MrRecipe/pages/Splash_screen.dart';
import 'package:MrRecipe/pages/navigation/home_screen.dart';
import 'package:MrRecipe/pages/user_account/login.dart';
import 'package:MrRecipe/pages/navigation/navigation.dart';
import 'package:MrRecipe/pages/user_account/registar.dart';
import 'package:MrRecipe/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/images/starter-image.jpg"), context);
    
    return MultiProvider(
        providers: [
          Provider<AuthService>(
              create: (_) => AuthService(FirebaseAuth.instance)),
          StreamProvider(
              create: (context) => context.read<AuthService>().authStateChanges)
        ],
        child: MaterialApp(
            initialRoute: "/",
            routes: {
              '/home': (context) => HomePage(),
              '/login': (context) => Login(),
              '/registar': (context) => Registar(),
              '/navbar': (context) => NavBar()
            },
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: Colors.white,
              backgroundColor: Colors.white
              //scaffoldBackgroundColor: Color.fromARGB(225, 245, 244, 242)
            ),
            home: SplashScreen()));
  }
}
