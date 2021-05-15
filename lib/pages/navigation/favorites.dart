import 'package:MrRecipe/pages/navigation/login_and_register.dart';
import 'package:MrRecipe/pages/navigation/recipeDetails.dart';
import 'package:MrRecipe/widgets/google_sign_in_button.dart';
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
    addRecipe(
        author: "teleculinaria",
        time: 40,
        name: "Bacalhau à brás",
        portion: 2,
        ingredients: ingredients,
        imgUrl: "assets/images/bacalhau-a-bras.jpg",
        calories: 600,
        categories: [
          "peixe",
          "bacalhau"
        ],
        preparation: [
          "Descasque a cebola e corte-a em lâminas. Descasque e pique os dentes de alho. Leve ao lume um tacho com o azeite, junte a cebola e o alho e deixe alourar.",
          "Adicione o bacalhau, tempere com sal e pimenta e envolva bem. Junte 2/3 da batata-palha e envolva novamente.",
          "Bata ligeiramente os ovos, acrescente-os ao preparado anterior e mexa rapidamente (sem deixar secar).",
          "Por fim, junte a salsa picada e a restante batata-palha e envolva cuidadosamente. Sirva com as azeitonas pretas."
        ]);
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
            child:
                widget.user == null ? noUserLoggedScreen() : streamBuilder()));
  }

  noUserLoggedScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Não nenhum utilizador logado",
          style: titleTextStyle(fontSize: 20),
        ),
        SizedBox(height: 20),
        buildButton("Login", 0),
        buildButton("Registar", 1),
        GoogleSignInButton(),
      ],
    );
  }

  Container buildButton(String label, int pageState) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      width: MediaQuery.of(context).size.width / 1.5,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        onPressed: () => Navigator.push(
          context,
          PageTransition(
            child: LoginAndRegister(pageState: pageState),
            type: PageTransitionType.bottomToTop,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ),
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
                      user: widget.user,
                      categories: recipes[index]["categorias"],
                      preparation: recipes[index]["preparação"],
                    ),
                    type: PageTransitionType.rightToLeft));
          }),
    );
  }
}
