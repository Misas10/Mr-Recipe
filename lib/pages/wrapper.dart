import 'package:MrRecipe/pages/Splash_screen.dart';
import 'package:MrRecipe/pages/navigation/navigation.dart';
import 'package:MrRecipe/pages/user_account/login.dart';
import 'package:MrRecipe/pages/user_account/registar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Verifica se há ou não utilizador 'logado' na app
// Se ouver vai para a página inicial
// Caso contrário vai para o Login

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({
    Key key,
  }) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool isFirstTime;
  int launchCount;

  void setValue() async {
    final prefs = await SharedPreferences.getInstance();
    launchCount = prefs.getInt('counter') ?? 0;
    prefs.setInt('counter', launchCount + 1);
    debugPrint(launchCount.toString());
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    setValue();

    if (firebaseUser != null) {
      return NavBar();
    }
    if (launchCount == null) {
      return SplashScreen();
    }
    return wrapperLoginRegister();
  }

  wrapperLoginRegister() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              child: Image.asset("assets/images/healthy_food_vector.jpg"),
            ),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Botão registar-se para página de registo
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Registar()));
                  },
                  child: const Text(
                    "Regista-se",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                      primary: Colors.grey,
                      backgroundColor: Colors.amber,
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * .13,
                          vertical: 16)),
                ),
                const SizedBox(width: 10),

                // Botão Login para página de login
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login()));
                  },
                  child: const Text("Login",
                      style: TextStyle(color: Colors.amber)),
                  style: OutlinedButton.styleFrom(
                    primary: Colors.grey,
                    side: const BorderSide(color: Colors.amber),
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * .19,
                        vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Botão para criar/registar conta com o google
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * .03),
              child: OutlinedButton(
                onPressed: () {},
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        child: Image.asset(
                          "assets/icons/google_icon.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Login com o Google",
                        style: TextStyle(color: Colors.amber),
                      ),
                    ],
                  ),
                ),
                style: OutlinedButton.styleFrom(
                    primary: Colors.grey,
                    side: const BorderSide(color: Colors.amber),
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
