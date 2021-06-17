import 'package:MrRecipe/pages/navigation/recipeDetails.dart';
import 'package:MrRecipe/widgets/no_user_buttons.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
    // "tomate",
    // "cebola",
    // "cenoura",
    // "alface",
    // "beterraba"

    "400 g de bacalhau desfiado demolhado",
    "400 g de batata palha",
    "6 ovos m",
    "6 fatias de pão de forma",
    "1 cebola",
    "2 dentes de alho",
    "3 colheres (sopa) de azeite",
    "2 colheres (sopa) de azeitonas pretas",
    "2 colheres (sopa) de salsa picada",
    "Sal e pimenta q.b."
  ];
  List recipeUids;
  double windowWidth = 0;
  double windowHeight = 0;
  int pageTrasitionTime = 0;

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
    var id = firestore.collection("Users").doc().id;
    debugPrint(id.toString());
    addRecipe(
            id: id,
            author: "Mr. Recipe",
            time: 25,
            name: "Salada russa",
            portion: "14 unidades",
            ingredients: [
              "5 batatas médias (500 g)",
              "3-4 cenouras (300 g)"
              "2 ovos M",
              "300 g ervilhas congeladas",
              "4 colheres de maionese",
              "Sal e pimenta qb",
              "Cebolinho ou salsa para decorar",
            ],
            imgUrl: "assets/images/salada-arabe.jpg",
            categories: [
              "salada",
              "salada russa"
            ],
            preparation: [
              "Corte as batatas e as cenouras em cubos de um centímetro. Corte o feijão-verde e retire as ervilhas do congelador. Coza os ovos 10 minutos em água fervente com uma colher de chá de sal.",
              "Use dois tachos com água fervente e tempere com sal de forma moderada. Deixe as cenouras ferver por alguns minutos e adicione as batatas. No outro tacho ferva as ervilhas e o feijão-verde. Deixe cozer durante 10 minutos",
              "Escorra os vegetais e deixe arrefecer. Corte os ovos em pedaços pequenos e reserve uma metade para decorar. Numa taça larga misture os ingredientes e adicione a maionese.",
              "Envolva lentamente, tempere com sal e pimenta com moderação.",
              "Sirva polvilhados com mais salsa picada e as sementes de papoila.",
              "Coloque película aderente e reserve no frigorífico.",
              "Depois de tirar do frigorífico aguarde alguns minutos antes de servir. Decore com cebolinho e ovo",
            ],
            dificulty: 'Fácil',
            chefNotes:
                "")
        .then((value) {
      firestore.collection("Users").doc(widget.user.uid).update({
        "receitas_criadas": FieldValue.arrayUnion([id])
      });
    });
  }

  // deleteRecipe() {
  //   recipeUids.remove(widget.user.uid);
  // }

  final _removedSnackBar = SnackBar(
    content: const Text("Receita removida dos favoritos"),
    backgroundColor: Colors.red,
    duration: const Duration(seconds: 2),
    action: SnackBarAction(
      label: "Desfazer",
      textColor: Colors.white,
      onPressed: () {
        debugPrint("clicou");
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    super.build(context);

    return Scaffold(
      appBar: customAppBar("Favoritos"),
      backgroundColor: BgColor,
      body: Container(
          width: double.infinity,
          child: widget.user == null ? noUserLoggedScreen() : streamBuilder()),
    );
  }

  noUserLoggedScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Não há nenhum utilizador logado",
          style: titleTextStyle(fontSize: 20),
        ),
        SizedBox(height: 20),
        NoUserButtons(),
      ],
    );
  }

  // mostra todos as receitas em que o utilizador atual deu like
  StreamBuilder streamBuilder() {
    return StreamBuilder<QuerySnapshot>(
        stream: recipesRef
            .where("utilizadores_que_deram_like",
                arrayContains: widget.user.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          var recipes = snapshot.data.docs;

          if (snapshot.hasError) {
            return Text("Ouve um erro");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return Column(
            children: [
              new Text(
                "\nVocê tem ${recipes.length} receita(s) guardada(s)",
                style: simpleTextStyle(
                  fontSize: 15,
                  color: PrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              new ListView.separated(
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(height: 30, thickness: 1),
                itemBuilder: (context, index) {
                  List usersLiked =
                      recipes[index]['utilizadores_que_deram_like'];
                  debugPrint(
                      "\n\n ---- ListView ----\n receitasUids: $usersLiked");

                  return createCard(recipes[index]['id'],
                      usersLiked.reversed.toList(), index, context, recipes);
                },
              ),
              TextButton(onPressed: newRecipe, child: Text("Criar receita"))
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
      confirmDismiss: (direction) async => await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirmar"),
            content: Text("Tem a certeza que quer apagar este item?"),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("APAGAR")),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("CANCELAR"),
              ),
            ],
          );
        },
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
                      categories: recipes[index]["categorias"],
                      preparation: recipes[index]["preparação"],
                      portion: recipes[index]['porção'],
                    ),
                    type: PageTransitionType.rightToLeft));
          }),
    );
  }
}
