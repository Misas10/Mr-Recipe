import 'package:MrRecipe/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../database/database.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Favorites extends StatefulWidget {
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites>
    with AutomaticKeepAliveClientMixin {
  var id;
  int nIds = 0;

  Map recipe;
  User currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference recipesRef =
      FirebaseFirestore.instance.collection('Recipes');
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
    getCurrentUser();

    recipesRef
        .where("utilizadores_que_deram_like", arrayContains: currentUser.uid)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                setState(() {
                  recipe = doc.data();
                  id = doc['id'];

                  recipeUids = doc["utilizadores_que_deram_likes"];
                  nIds += 1;
                  debugPrint("recipe: ${recipe.toString()}");
                });
              })
            });
  }

  getCurrentUser() async {
    setState(() {
      currentUser = auth.currentUser;
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
    recipeUids.remove(currentUser.uid);
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
            Text("Favorites"),
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
        stream: recipesRef.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Ouve um erro");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return new ListView.separated(
            shrinkWrap: true,
            itemCount: recipe.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(height: 30, thickness: 1),
            itemBuilder: (context, index) {
              return Slidable(
                actionPane: SlidableScrollActionPane(),
                secondaryActions: [
                  IconSlideAction(
                      caption: 'Apagar', color: Colors.red, icon: Icons.delete)
                ],
                child: new Dismissible(
                  key: Key(recipeUids[index]),
                  onDismissed: (direction) {
                    recipeUids.removeAt(index);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(_removedSnackBar);
                  },
                  background: new Container(color: Colors.red),
                  child: new ListTile(
                      title: Text('${currentUser.uid}'),
                      onTap: () {} // => addFavorites(currentUser.uid),
                      ),
                ),
              );
            },
          );
        });
  }
}
