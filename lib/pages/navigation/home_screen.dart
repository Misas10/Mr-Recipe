import 'package:MrRecipe/models/category_model.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:page_transition/page_transition.dart';
import '../../widgets/Category_food_card.dart';
import 'package:MrRecipe/pages/navigation/recipeDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../models/category_model.dart';

class HomePage extends StatefulWidget {
  final User user;

  HomePage({Key key, this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  CollectionReference recipes =
      FirebaseFirestore.instance.collection('Recipes');
  List<FoodCategory> _categories = categories;

  @override
  void initState() {
    super.initState();

    debugPrint("homePage");
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Container(
        padding: appHorizontalPadding(),
        color: BgColor,
        child: ListView(physics: BouncingScrollPhysics(), children: [
          const SizedBox(height: 30),
          Container(
            child: Text(
              "O que vai desejar hoje?",
              style: titleTextStyle(
                fontSize: 30,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text("Categorias", style: titleTextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Container(
            height: 80,
            // color: Colors.black,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _categories.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return FoodCard(
                  categoryName: _categories[index].categoryName,
                  categoryIcon: _categories[index].categoryIcon,
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          Text("Receitas em destaque", style: titleTextStyle(fontSize: 25)),
          const SizedBox(height: 12),
          Container(
              // mostra os dados de uma certa collection
              // neste caso a 'Recipes'
              // height: 100,
              width: 100,
              child: buildRecipes()),
          SizedBox(height: 10)
        ]),
      ),
    );
  }

//Mostra as receitas em perquenos quadrados
  buildRecipes() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: StreamBuilder<QuerySnapshot>(
        stream: recipes.snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return Text('Erro');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                padding: EdgeInsets.only(top: 15),
                child: CircularProgressIndicator(backgroundColor: PrimaryColor),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'Sem dados',
                style: titleTextStyle(color: Colors.red, fontSize: 25),
              ),
            );
          }

          return new ListView.separated(
            separatorBuilder: (BuildContext context, int index) => Divider(
              color: Colors.transparent,
            ),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var recipes = snapshot.data.docs;

              return GestureDetector(
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
                },
                child: Container(
                  padding:
                      EdgeInsets.only(bottom: 10, top: 5, right: 5, left: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.2 / 1, // width : ecrã

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: ClipRRect(
                              child: Image.asset(
                                recipes[index]['img_url'],
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text("${recipes[index]['nome_receita']}",
                            style: simpleTextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
