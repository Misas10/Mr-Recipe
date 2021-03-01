import 'package:MrRecipe/models/category_model.dart';
import 'package:MrRecipe/models/recipe_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/Category_food_card.dart';
import 'package:MrRecipe/pages/navigation/restaurantDetails.dart';
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

  @override
  void initState() {
    super.initState();

    debugPrint("initState");
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView(physics: BouncingScrollPhysics(), children: [
      const SizedBox(height: 65),
      Container(
          child: Text("O que vai desejar hoje?",
              style: GoogleFonts.comfortaa(
                  fontSize: 30, fontWeight: FontWeight.bold))),
      const SizedBox(height: 15),
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
      const SizedBox(height: 15),
      Container(
          // mostra os dados de uma certa collection
          // neste caso a 'Recipes'
          child: StreamBuilder<QuerySnapshot>(
        stream: recipes.snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
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
                          builder: (context) => RestaurantDetails(
                              recipes[index]['nome'],
                              recipes[index]['ingredientes'])));
                },
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: ClipRRect(
                    child: Image.asset(
                      recipes[index]['img_url'],
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          );
        },
      )),
    ]);
    //]);
  }

// Mostra as receitas em perquenos quadrados
  Widget recipesView(var context, List id, String title, subTitle, String url) {
    return
        //padding: const EdgeInsets.symmetric(horizontal: 70),
        GestureDetector(
            child: Column(children: [
              Expanded(
                child: Container(
                  //height: 600,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(url), fit: BoxFit.cover),
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
                        BoxShadow(
                            blurRadius: 3, spreadRadius: 1, color: Colors.grey)
                      ],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  // padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Column(
                        //mainAxisSize: MainAxisSize.min,
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            subTitle,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RestaurantDetails(title, id)));
            });
  }
}
