import 'package:firebase_database/firebase_database.dart';

class User {
  DatabaseReference userId;
  String email;
  String password;

  User({this.email, this.password});
}
