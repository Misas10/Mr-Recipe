// import 'package:MrRecipe/pages/account/login.dart';
import 'package:MrRecipe/pages/navigation/navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'user_account/login.dart';
import 'package:provider/provider.dart';


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

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      return NavBar();
    }
    return Login();
  }
}

