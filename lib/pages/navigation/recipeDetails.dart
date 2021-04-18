import 'package:MrRecipe/widgets/sabt.dart';
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
  final List preparation;
  final List categories;

  RecipeDetails(
      {@required this.recipeName,
      @required this.ingredientes,
      @required this.image,
      @required this.id,
      @required this.calories,
      @required this.recipeUids,
      @required this.user,
      @required this.preparation,
      @required this.categories});

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
      recipesRef.doc(id).update({"utilizadores_que_deram_like": recipeUids});
    } else {
      debugPrint("Não existe");

      setState(() {
        recipeUids.add(widget.user.uid);
      });
      debugPrint(recipeUids.toString());

      // Atualiza os dados na BD
      recipesRef.doc(id).update({"utilizadores_que_deram_like": recipeUids});
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
          color: Colors.white, size: 30);
    }
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,

      // A parte principal do widget
      // Onde mostra todas as informações da receita para o utilizador
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: SABT(
              child: Text(
                widget.recipeName,
                style:
                    titleTextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            primary: true,
            backgroundColor: PrimaryColor,
            expandedHeight: height / 2.5,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.image),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.black.withOpacity(.4),
                      Colors.black.withOpacity(.01),
                      Colors.black.withOpacity(.0),
                      Colors.black.withOpacity(.0),
                      Colors.black.withOpacity(.0),
                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  ),
                ),
              ),
              title: Text(
                "",
                // widget.recipeName,
                style: titleTextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            actions: [
              IconButton(
                  icon: widget.user == null
                      ? Icon(Icons.favorite_border_outlined,
                          color: Colors.white, size: 30)
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
                    var preparation = widget.preparation
                        .map((value) =>
                            "${widget.preparation.indexOf(value.toString()) + 1} . \t${value.toString().trim()}.")
                        .join('\n');
                    // Partilha a receita formata
                    Share.share("${widget.recipeName}\n\n" +
                        "Ingredientes: \n" +
                        "$ingredients \n\n" +
                        "Preparação: \n\n$preparation\n");
                  })
            ],
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          buildRecipeInfo()
        ],
      ),
    );
  }

  Widget buildRecipeInfo() => SliverToBoxAdapter(
        child: Container(
          padding: appHorizontalPadding(),
          decoration: BoxDecoration(
              // color: Colors.black,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(25))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(widget.recipeName,
                  style: titleTextStyle(
                      fontWeight: FontWeight.bold, fontSize: 28)),
              const SizedBox(height: 20),

              // INGREDIENTES
              Center(
                child: buildRecipeDetailsText("Ingredientes"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 120, vertical: 2),
                child: Container(height: 1.5, color: Colors.green),
              ),
              const SizedBox(height: 8),

              Text("Para até 4 pessoas", style: simpleTextStyle(fontSize: 17)),
              // const SizedBox(height: 20),
              Container(
                child: buildRecipeIngredients(),
              ),
              const SizedBox(height: 35),

              // PREPARAÇÃO
              buildRecipeDetailsText("Preparação"),
              // const SizedBox(height: 15),
              Container(
                child: buildRecipePreparation(),
              ),
              const SizedBox(height: 35),

              // CATEGORIAS
              buildRecipeDetailsText("Categorias"),
              Container(
                child: buildCategories(),
              ),
              const SizedBox(height: 20)
            ],
          ),
        ),
      );

  Text buildRecipeDetailsText(String text) => Text(
        text,
        style: simpleTextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      );

  ListView buildRecipePreparation() {
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) => const Divider(
        height: 30,
        color: Colors.transparent,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.preparation.length,
      itemBuilder: (context, index) {
        return Row(
          children: [
            Container(
              child: Text(
                "\t${index + 1}\t\t",
                style: TextStyle(fontSize: 25, color: Colors.grey),
              ),
            ),
            Expanded(
              child: Text(
                widget.preparation[index],
                style: simpleTextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  ListView buildRecipeIngredients() {
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) => const Divider(
        height: 30,
        thickness: 1,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.ingredientes.length,
      itemBuilder: (context, index) {
        return Row(
          children: [
            Text(
              "${widget.ingredientes[index]}",
              style: simpleTextStyle(fontSize: 17),
            ),
            Spacer(),
            Text(
              "quantidade",
              style: simpleTextStyle(fontSize: 17),
            )
          ],
        );
      },
    );
  }

  buildCategories() {
    return ListView.builder(
        padding: EdgeInsets.only(top: 8),
        shrinkWrap: true,
        // scrollDirection: Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                new Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.categories[index],
                      style: simpleTextStyle(fontSize: 17),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class BuildItemRow extends StatelessWidget {
  final String name;
  final int steps;

  const BuildItemRow({
    this.name,
    this.steps,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        steps == null
            ? Container()
            : Container(
                child: Text(
                  "\t$steps\t\t",
                  style: TextStyle(fontSize: 25, color: Colors.grey),
                ),
              ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: simpleTextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
