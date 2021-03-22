import 'package:MrRecipe/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecipeDetails extends StatefulWidget {
  final String recipeName;
  final List ingredientes;
  final String image; // mostra a imagem principal
  final String id;
  final int calories;
  final List recipeUids;

  RecipeDetails(
      {@required this.recipeName,
      @required this.ingredientes,
      @required this.image,
      @required this.id,
      @required this.calories,
      @required this.recipeUids});

  @override
  _RecipeDetailsState createState() => _RecipeDetailsState();
}

class _RecipeDetailsState extends State<RecipeDetails> {
  User currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference recipesRef =
      FirebaseFirestore.instance.collection("Recipes");
  Map recipe;
  List recipeUids;
  String id;

  void initState() {
    super.initState();
    debugPrint("\n---- InitState RecipeDetails ----");
    setState(() {
      // Guarda o utilizador atual na variável 'currentUser'
      currentUser = auth.currentUser;
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

  // Permite dar Like/dislike à receita
  void likeRecipe() {
    debugPrint("\n----- Recipe Liked -----");
    debugPrint("id: $id");
    debugPrint("${recipeUids.toString()}");

    // adiciona ou retira os utilizadores que deram/retiraram da BD

    if (recipeUids.contains(currentUser.uid)) {
      debugPrint("Existe");
      setState(() {
        recipeUids.remove(currentUser.uid);
      });

      // Atualiza os dados na BD
      recipesRef.doc(id).update({"utilizadores_que_deram_likes": recipeUids});
    } else {
      debugPrint("Não existe");

      setState(() {
        recipeUids.add(currentUser.uid);
      });
      debugPrint(recipeUids.toString());

      // Atualiza os dados na BD
      recipesRef.doc(id).update({"utilizadores_que_deram_likes": recipeUids});
    }
  }

  final _insertedSnackBar = SnackBar(
    content: Text("Receita adicionada aos favoritos"),
    backgroundColor: Colors.green,
    duration: const Duration(seconds: 2),
  );

  final _removedSnackBar = SnackBar(
    content: Text("Receita removida dos favoritos"),
    backgroundColor: Colors.red,
    duration: const Duration(seconds: 2),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: BgColor,
        appBar: AppBar(
          title: Row(
            children: [
              Text(widget.recipeName, style: simpleTextStyle()),
              Spacer(),
              GestureDetector(
                child: recipeUids.contains(currentUser.uid)
                    ? Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 30,
                      )
                    : Icon(Icons.favorite_border_outlined,
                        color: Colors.black, size: 30),
                onTap: () {
                  likeRecipe();
                  if (recipeUids.contains(currentUser.uid))
                    ScaffoldMessenger.of(context)
                        .showSnackBar(_insertedSnackBar);
                  else
                    ScaffoldMessenger.of(context)
                        .showSnackBar(_removedSnackBar);
                },
              ),
            ],
          ),
          elevation: 0,
        ),
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
