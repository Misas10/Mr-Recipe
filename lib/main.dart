import 'dart:async';
import 'package:MrRecipe/pages/app.dart';
import 'package:MrRecipe/pages/onboarding_screen.dart';
import 'package:MrRecipe/services/auth.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/http.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isFirstTime;

  @override
  void initState() {
    getIsFirstTime();
    super.initState();
  }

  getIsFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    bool isFirstTimeValue = prefs.getBool("isFirstTime") ?? true;
    // if (isFirstTimeValue) prefs.setBool("isFirstTime", true);
    setState(() {
      isFirstTime = isFirstTimeValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final HttpService httpService = HttpService();
    debugPrint(httpService.getRecipe().toString());

    if (isFirstTime == null) {
      return Container(
        child: Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(PrimaryColor),
        )),
        color: Colors.white,
      );
    }
    return MultiProvider(
      providers: [
        Provider<AuthService>(
            create: (_) => AuthService(FirebaseAuth.instance)),
        // StreamProvider(
        //   initialData: context.read<AuthService>(),
        //     create: (context) => context.read<AuthService>().authStateChanges)
      ],
      child: MaterialApp(
        initialRoute: "/",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: PrimaryColor, accentColor: Colors.white),
        home: isFirstTime ? OnboardingScreen() : App(fromMain: true),
      ),
    );
  }
}
