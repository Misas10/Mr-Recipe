import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';
import '../../database/database.dart';

class Favorites extends StatefulWidget {
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites>
    with AutomaticKeepAliveClientMixin {
  List<String> ingredients = [
    "tomate",
    "cebola",
    "cenoura",
    "alface",
    "beterraba"
  ];

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      padding: appHorizontalPadding(),
      color: BgColor,
      child: Center(
        child: OutlinedButton(
            child: Text("Adicionar Receita teste"),
            onPressed: () {
              addRecipe(
                  name: "Teste1",
                  imgUrl: "assets/images/vegetais.jpg",
                  tempo: 30,
                  author: "Mr. Recipe",
                  quantity: 6,
                  ingredients: ingredients,
                  calories: 600);
            }),
      ),
    );
  }
}
