import 'package:MrRecipe/models/recipe_model.dart';
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
  User currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference favorites =
      FirebaseFirestore.instance.collection('Favoritos');
  List<String> ingredients = [
    "tomate",
    "cebola",
    "cenoura",
    "alface",
    "beterraba"
  ];

  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  getCurrentUser() async {
    setState(() {
      currentUser = auth.currentUser;
    });
  }

  void newRecipe() {
    var recipe = new Recipe(
      author: "Mr. Recipe",
      time: 30,
      name: "Teste1",
      quantity: 6,
      ingredients: ingredients,
      imgUrl: "assets/images/vegetais.jpg",
      calories: 600,
    );

    addRecipe(
        author: "Mr. Recipe",
        time: 30,
        name: "Teste1",
        quantity: 6,
        ingredients: ingredients,
        imgUrl: "assets/images/vegetais.jpg",
        calories: 600);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      // padding: appHorizontalPadding(),
      color: BgColor,
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Slidable(
                // dismissal: SlidableDismissal(
                //   child: SlidableDrawerDismissal(),
                //   onDismissed: (actionType) {
                //     SnackBar(
                //       content: Text('Deleted dismiss'),
                //     );
                //   },
                // ),
                actionPane: SlidableScrollActionPane(),
                secondaryActions: [
                  IconSlideAction(
                      caption: 'Apagar', color: Colors.red, icon: Icons.delete)
                ],
                child: ListTile(
                    title: Text('${currentUser.uid}'),
                    onTap: () {} // => addFavorites(currentUser.uid),
                    ),
              );
            },
          ),
          OutlinedButton(
              child: Text("Adicionar Receita teste"),
              onPressed: () {
                newRecipe();
              }),
        ],
      ),
    );
  }

  StreamBuilder streamBuilder() {
    return StreamBuilder<QuerySnapshot>(
        stream: favorites.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Ouve um erro");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return new ListView(
            shrinkWrap: true,
          );
        });
  }
}
