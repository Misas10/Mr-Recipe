import 'package:MrRecipe/pages/navigation/recipeDetails.dart';
import 'package:MrRecipe/pages/user_account/login.dart';
import 'package:MrRecipe/pages/user_account/registar.dart';
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
    // debugPrint("---- Favorites ----\n UserId: ${widget.user.uid}");
    if (widget.user != null) {
      recipesRef
          .where("utilizadores_que_deram_like", arrayContains: widget.user.uid)
          .get()
          .then((QuerySnapshot querySnapshot) => {
                querySnapshot.docs.forEach((doc) {
                  setState(() {
                    recipeUids = doc["utilizadores_que_deram_like"];
                  });
                })
              });
    }
  }

  void newRecipe() {
    addRecipe(
        author: "Mr. Recipe",
        time: 30,
        name: "Teste1",
        portion: 6,
        ingredients: ingredients,
        imgUrl: "assets/images/vegetais.jpg",
        calories: 600,
        categories: [
          "Carne"
        ],
        preparation: [
          "Reservar algo para mais tarde",
          "Fazer este segundo passo e finalizar a receita"
        ]);
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
          color: BgColor,
          child: widget.user == null ? container() : streamBuilder()),
    );
  }

  Container container() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Não nenhum utilizador logado",
            style: titleTextStyle(fontSize: 20),
          ),
          TextButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Login())),
              child: Text("Login")),
          TextButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Registar())),
              child: Text("Registar")),
          TextButton(onPressed: () {}, child: Text("Google"))
        ],
      ),
    );
  }

  // mostra todos os documentes em que o utilizador atual deu like
  StreamBuilder streamBuilder() {
    return StreamBuilder<QuerySnapshot>(
        stream: recipesRef
            .where("utilizadores_que_deram_like",
                arrayContains: widget.user.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Ouve um erro");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return Column(
            children: [
              new ListView.separated(
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(height: 30, thickness: 1),
                itemBuilder: (context, index) {
                  var recipes = snapshot.data.docs;
                  List usersLiked =
                      recipes[index]['utilizadores_que_deram_like'];
                  debugPrint(
                      "\n\n ---- ListView ----\n receitasUids: $usersLiked");

                  return createCard(recipes[index]['id'],
                      usersLiked.reversed.toList(), index, context, recipes);
                },
              ),
              TextButton(onPressed: newRecipe, child: Text("Criar Receita"))
            ],
          );
        });
  }

  // cria cards e ao clicar neles vai para o RecipeDetais
  // permintindo apagá-los ao deslizar para a esquerda
  Dismissible createCard(String id, usersLiked, int index, BuildContext context,
      List<QueryDocumentSnapshot> recipes) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      key: Key(recipes[index]['id']),
      onDismissed: (direction) {
        usersLiked.remove(widget.user.uid);
        debugPrint("receitasUids: $usersLiked");
        setState(() {
          recipesRef
              .doc(id)
              .update({"utilizadores_que_deram_like": usersLiked});
        });
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
                      recipeUids: recipes[index]['utilizadores_que_deram_like'],
                      user: widget.user,
                      categories: recipes[index]["categorias"],
                      preparation: recipes[index]["preparação"],
                    ),
                    type: PageTransitionType.rightToLeft));
          }),
    );
  }
}
