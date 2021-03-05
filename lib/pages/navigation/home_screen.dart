import 'dart:async';

import 'package:MrRecipe/models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/Category_food_card.dart';
import 'package:MrRecipe/pages/navigation/recipeDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/category_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  CollectionReference recipes =
      FirebaseFirestore.instance.collection('Recipes');
  List<FoodCategory> _categories = categories;

  _timer() {
    Timer(Duration(seconds: 2), () {
      debugPrint("PASSARAM 2 SEGUNDOS");
    });
  }

  @override
  void initState() {
    super.initState();

    debugPrint("initState");
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: ListView(physics: BouncingScrollPhysics(), children: [
        const SizedBox(height: 30),
        Container(
          child: Text(
            "O que vai desejar hoje?",
            style: GoogleFonts.lato(
              fontSize: 30,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text("Categorias", style: GoogleFonts.lato(fontSize: 20)),
        const SizedBox(height: 12),
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
        Text("Receitas em destaque", style: GoogleFonts.lato(fontSize: 25)),
        const SizedBox(height: 12),
        Container(
            // mostra os dados de uma certa collection
            // neste caso a 'Recipes'
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
                      child: CircularProgressIndicator()));
            }

            if (!snapshot.hasData) {
              return Text('Sem dados');
            }

            return new GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var recipes = snapshot.data.docs;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetails(
                            recipeName: recipes[index]['nome'],
                            ingredientes: recipes[index]['ingredientes'],
                            image: recipes[index]['img_url'],
                          ),
                        ));
                  },
                  child: AspectRatio(
                    aspectRatio: 1 / 1, // width : ecrã

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
                              //tag: "recipeImg",
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text("${recipes[index]['nome']}",
                            style: GoogleFonts.roboto())
                      ],
                    ),
                  ),
                );
              },
            );
          },
        )),
      ]),
    );
  }

// Mostra as receitas em perquenos quadrados
  Widget recipesView(var context, List id, String title, subTitle, String url) {
    return GestureDetector(
      child: Column(children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                image:
                    DecorationImage(image: AssetImage(url), fit: BoxFit.cover),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(blurRadius: 3, spreadRadius: 1, color: Colors.grey)
                ],
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10))),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      subTitle,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
