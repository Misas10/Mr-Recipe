import 'dart:async';
import 'package:MrRecipe/pages/app.dart';
import 'package:MrRecipe/pages/user_account/login.dart';
import 'package:MrRecipe/pages/user_account/registar.dart';
import 'package:MrRecipe/services/auth.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isFirstTime = true;
  StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    getIsFirstTime();
    super.initState();

    // Verifica a conexão à internet do smartphone
    // subscription = Connectivity()
    //     .onConnectivityChanged
    //     .listen((ConnectivityResult result) {
    //   debugPrint(result.toString());
    //   if (result == ConnectivityResult.none) {
    //     // Texto para quando não ouver conexão à internet
    //     return showDialog(
    //         context: context,
    //         builder: (BuildContext context) {
    //           return AlertDialog(
    //             title: Text('Ooops!'),
    //             content: SingleChildScrollView(
    //               child: ListBody(
    //                 children: <Widget>[
    //                   Text("Vôce não tem uma conexão á internet."),
    //                   Text(
    //                       "Para uma melhor experiência estabeleça uma conexão.")
    //                 ],
    //               ),
    //             ),
    //             actions: <Widget>[
    //               TextButton(
    //                   onPressed: () => Navigator.of(context).pop,
    //                   child: Text("Ok"))
    //             ],
    //           );
    //         });
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  getIsFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTimeValue = prefs.getBool("isFirstTime") ?? true;
    setState(() {
      isFirstTime = isFirstTimeValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/images/starter-image.jpg"), context);

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
        routes: {
          // '/home': (context) => HomePage(),
          '/login': (context) => Login(),
          '/registar': (context) => Registar(),
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: PrimaryColor, accentColor: Colors.white),
        home: App(),
      ),
    );
  }
}
