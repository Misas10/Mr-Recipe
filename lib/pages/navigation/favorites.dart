import 'package:MrRecipe/pages/navigation/recipeDetails.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../database/database.dart';

class Favorites extends StatefulWidget {
  final User user;

  const Favorites({Key key, this.user}) : super(key: key);

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites>
    with AutomaticKeepAliveClientMixin {
  // var id;

  CollectionReference recipesRef =
      FirebaseFirestore.instance.collection("Recipes");
  List<String> ingredients = [
    "tomate",
    "cebola",
    "cenoura",
    "alface",
    "beterraba"
  ];
  List recipeUids;

  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    debugPrint("---- Favorites ----\n");

    recipesRef
        .where("utilizadores_que_deram_likes", arrayContains: widget.user.uid)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                setState(() {
                  recipeUids = doc["utilizadores_que_deram_likes"];
                });
              })
            });
  }

  void newRecipe() {
    addRecipe(
        author: "Mr. Recipe",
        time: 30,
        name: "Teste1",
        quantity: 6,
        ingredients: ingredients,
        imgUrl: "assets/images/vegetais.jpg",
        calories: 600);
  }

  deleteRecipe() {
    recipeUids.remove(widget.user.uid);
  }

  final _removedSnackBar = SnackBar(
    content: Text("Receita removida dos favoritos"),
    backgroundColor: Colors.red,
    duration: const Duration(seconds: 2),
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Container(
        // padding: appHorizontalPadding(),
        color: BgColor,
        child: Column(
          children: [
            streamBuilder(),
            OutlinedButton(
                child: Text("Adicionar Receita teste"),
                onPressed: () {
                  newRecipe();
                }),
          ],
        ),
      ),
    );
  }

  StreamBuilder streamBuilder() {
    return StreamBuilder<QuerySnapshot>(
        stream: recipesRef
            .where("utilizadores_que_deram_likes",
                arrayContains: widget.user.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Ouve um erro");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return new ListView.separated(
            shrinkWrap: true,
            itemCount: snapshot.data.docs.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(height: 30, thickness: 1),
            itemBuilder: (context, index) {
              var recipes = snapshot.data.docs;
              var usersLiked = recipes[index]['utilizadores_que_deram_likes'];
              debugPrint("\n\n ---- ListView ----\n" +
                  "${recipes[index]['utilizadores_que_deram_likes'][index]}\n\n");
              return Dismissible(
                direction: DismissDirection.endToStart,
                key: Key(usersLiked[index]),
                onDismissed: (direction) {
                  debugPrint("$index");
                  recipes.removeWhere((element) =>
                      element.data()['utilizadores_que_deram_likes'] == index);
                  debugPrint(
                      "receitasUids: ${recipes[index]['utilizadores_que_deram_likes'][index]}");

                  ScaffoldMessenger.of(context).showSnackBar(_removedSnackBar);
                },
                background: new Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: new ListTile(
                    title: Text('${recipes[index]['nome_receita']}'),
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              child: RecipeDetails(
                                recipeName: recipes[index]['nome_receita'],
                                ingredientes: recipes[index]['ingredientes'],
                                image: recipes[index]['img_url'],
                                calories: recipes[index]['calorias'],
                                id: recipes[index]['id'],
                                recipeUids: recipes[index]
                                    ['utilizadores_que_deram_likes'],
                                user: widget.user,
                              ),
                              type: PageTransitionType.rightToLeft));
                    }),
              );
            },
          );
        });
  }
}
