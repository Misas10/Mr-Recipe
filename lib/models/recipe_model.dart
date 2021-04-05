import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Recipe {
  // String id;
  String imgUrl;
  String author;
  String name;
  int calories;
  int quantity;
  List<String> ingredients = [];
  int time;
  Set usersFavorites = {};

  Recipe(
      {@required this.author,
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

  Map<String, dynamic> toJson(String id) {
    return {
      "id": id,
      "nome_receita": this.name,
      "autor": this.author,
      "calorias": this.calories,
      //"servintes": servings,
      "img_url": this.imgUrl,
      "quantidade": this.quantity,
      "ingredientes": this.ingredients,
      "tempo_total": this.time,
      "utilizadores_que_deram_likes": this.usersFavorites
    };
  }
}
