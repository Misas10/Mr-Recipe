import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart' as uuid; // Serve para criar ids únicos

class Recipe {
  String id;
  String imgUrl;
  String author;
  String name;
  int calories;
  int quantity;
  List<String> ingredients = [];
  int time;
  Set usersFavorites = {};

  Recipe(
      {@required this.id,
      @required this.author,
      @required this.name,
      // @required this.calories,
      @required this.quantity,
      @required this.ingredients,
      @required this.time,
      @required this.imgUrl});

  void likeRecipe(User user) {
    if (this.usersFavorites.contains(user.uid))
      this.usersFavorites.remove(user.uid);
    else
      this.usersFavorites.add(user.uid);

    // this.update();
  }

  // void update() {
  //   updateRecipe(this, this.id);
  // }

  // void setId(DocumentReference id) {
  //   this.id = id;
  // }

  factory Recipe.toJson(Map<String, dynamic> json) {
    return Recipe(
      id: uuid.Uuid().v4(),
      name: json['name'] as String,
      author: json['author'] as String,
      // calories: ,
      imgUrl: json['imgUrl'] as String,
      quantity: json['quantity'] as int,
      ingredients: json['ingredients'] as List<String>,
      time: json['time'] as int,
    );
  }
}
