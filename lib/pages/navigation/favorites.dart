import 'package:flutter/material.dart';
import '../../database/database.dart';

class Favorites extends StatefulWidget {
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> with AutomaticKeepAliveClientMixin{
  List<String> ingredients = [
    "tomate", 
    "cebola", 
    "salsicha",
    "arroz",
    "feijão"
  ];

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {

    super.build(context);

    return Container(
      child: Center(
        child: FlatButton(child: Text("Adicionar Receita teste"), onPressed: (){
          addRecipe(name: "Teste", imgUrl: "assets/images/frutas.png", tempo: 30,
            author: "Mr. Recipe", quantity: 6, ingredients: ingredients, calories: 600);
        }),
      ),
    );
  }
}