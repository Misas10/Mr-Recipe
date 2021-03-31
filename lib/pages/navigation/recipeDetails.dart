import 'package:MrRecipe/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class RecipeDetails extends StatefulWidget {
  final String recipeName;
  final List ingredientes;
  final String image; // mostra a imagem principal
  final String id;
  final int calories;
  final List recipeUids;
  final User user;

  RecipeDetails(
      {@required this.recipeName,
      @required this.ingredientes,
      @required this.image,
      @required this.id,
      @required this.calories,
      @required this.recipeUids,
      @required this.user});

  @override
  _RecipeDetailsState createState() => _RecipeDetailsState();
}

class _RecipeDetailsState extends State<RecipeDetails> {
  final CollectionReference recipesRef =
      FirebaseFirestore.instance.collection("Recipes");
  Map recipe;
  List recipeUids;
  String id;

  void initState() {
    super.initState();
    debugPrint("\n---- InitState RecipeDetails ----");
    setState(() {
      recipeUids = widget.recipeUids;
      getRecipe();
    });

    debugPrint("${recipeUids.toString()}");

    debugPrint("---- End InitState ---- \n");
  }

  getRecipe() async {
    recipesRef
        .where("id", isEqualTo: widget.id)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                setState(() {
                  recipe = doc.data();
                  id = widget.id;
                });
              })
            });
  }
  // Ativada quando o utilizado clica no ícone do coração
  // Permite dar Like/dislike à receita
  void likeRecipe() {
    debugPrint("\n----- Recipe Liked -----");
    debugPrint("id: $id");
    debugPrint("${recipeUids.toString()}");

    // Adiciona ou retira os utilizadores que deram/retiraram da BD
    if (recipeUids.contains(widget.user.uid)) {
      debugPrint("Existe");
      setState(() {
        recipeUids.remove(widget.user.uid);
      });

      // Atualiza os dados na BD
      recipesRef.doc(id).update({"utilizadores_que_deram_likes": recipeUids});
    } else {
      debugPrint("Não existe");

      setState(() {
        recipeUids.add(widget.user.uid);
      });
      debugPrint(recipeUids.toString());

      // Atualiza os dados na BD
      recipesRef.doc(id).update({"utilizadores_que_deram_likes": recipeUids});
    }
  }

  // Resulta
  final _insertedSnackBar = SnackBar(
    content: Text(
      "Receita adicionada aos favoritos",
      style: simpleTextStyle(color: Colors.white),
    ),
    backgroundColor: PrimaryColor,
    duration: const Duration(seconds: 2),
  );

  final _removedSnackBar = SnackBar(
    content: Text(
      "Receita removida dos favoritos",
      style: simpleTextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.red,
    duration: const Duration(seconds: 2),
  );

  // Contrói um ícone baseado na base de dado da receita 
  // Caso o utilizador esteja na base de dados/deu like
  // Mostra o coração vermelho, caso contrário, o coração fica vazio
  Icon heartIcon() {
    if (recipeUids.contains(widget.user.uid)) {
      return Icon(
        Icons.favorite,
        color: Colors.red,
        size: 30,
      );
    } else {
      return Icon(Icons.favorite_border_outlined,
          color: Colors.black, size: 30);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: BgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Text(widget.recipeName, style: simpleTextStyle()),
              Spacer(),
              IconButton(
                  icon: widget.user == null
                      ? Icon(Icons.favorite_border_outlined,
                          color: Colors.black, size: 30)
                      : heartIcon(),
                  onPressed: () {
                    if (widget.user != null) {
                      likeRecipe();
                      if (recipeUids.contains(widget.user.uid))
                        ScaffoldMessenger.of(context)
                            .showSnackBar(_insertedSnackBar);
                      else
                        ScaffoldMessenger.of(context)
                            .showSnackBar(_removedSnackBar);
                    }
                  }),
              IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    // formata a lista dos ingredientes
                    var ingredients = widget.ingredientes
                        .map((value) => "\t - ${value.toString().trim()}")
                        .join('\n');
                    // formata a lista da preração
                    var preparation;
                    // Partilha a receita formata
                    Share.share("${widget.recipeName}\n\n" +
                        "Ingredientes: \n" +
                        "$ingredients \n\n" +
                        "Preparação: \n");
                  })
            ],
          ),
          elevation: 0,
        ),
        // A parte principal do widget
        // Onde mostra todas as informações da receita para o utilizador
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * .4,
                  child: Image.asset(
                    widget.image,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  padding: appHorizontalPadding(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      Text(
                        "Ingredientes",
                        style: simpleTextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text("Para até 4 pessoas",
                          style: simpleTextStyle(fontSize: 16)),
                      const SizedBox(height: 20),
                      Container(
                        child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(
                            height: 30,
                            thickness: 1,
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: widget.ingredientes.length,
                          itemBuilder: (context, index) {
                            return BuildItemRow(
                              name: "${widget.ingredientes[index]}",
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        child: Text(
                          "Preparação",
                          style: simpleTextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 15)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // StreamBuilder streamBuilder() {
  //   return StreamBuilder<QuerySnapshot>(
  //       stream: recipesRef.snapshots(),
  //       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //         if (snapshot.hasError) {
  //           return Text("Ouve um erro");
  //         }

  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return CircularProgressIndicator();
  //         }

  //         return new Column(children: [
  //           Container(
  //             height: MediaQuery.of(context).size.height * .4,
  //             child: Image.asset(
  //               widget.image,
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //           Container(
  //             padding: appHorizontalPadding(),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const SizedBox(height: 15),
  //                 Text(
  //                   "Ingredientes",
  //                   style: simpleTextStyle(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 2),
  //                 Text("Para até 4 pessoas",
  //                     style: simpleTextStyle(fontSize: 16)),
  //                 const SizedBox(height: 20),

  //                 const SizedBox(height: 20),
  //                 Container(
  //                   child: Text(
  //                     "Preparação",
  //                     style: simpleTextStyle(
  //                         fontSize: 20, fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //                 SizedBox(height: 15)
  //               ],
  //             ),
  //           ),
  //         ]);
  //       });
  // }
}
// 'AppBar' onde está o títulos e botões
class BuildItemRow extends StatelessWidget {
  final String name;

  const BuildItemRow({
    this.name,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: simpleTextStyle(
                      fontSize: 18,
                    )),
              ],
            ),
            Spacer(),
            Text(
              "quantidade",
              style: simpleTextStyle(),
            )
          ],
        ),
      ],
    );
  }
}
