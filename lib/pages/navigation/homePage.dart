import 'package:MrRecipe/models/category_model.dart';
import 'package:MrRecipe/models/recipe_model.dart';
import 'package:MrRecipe/widgets/widget.dart';
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
  List<Recipe> recipeList = [];
  List<FoodCategory> _categories = categories;
  ScrollController _controller = new ScrollController();

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

          return new ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return recipesView(
                context,
                snapshot.data.docs[index]['ingredientes'],
                snapshot.data.docs[index]['ingredientes'][index],
                snapshot.data.docs[index]['autor'],
                snapshot.data.docs[index]['img_url'],
              );
            },
          );
        },
      )),
    ]);
    //]);
  }

  Widget recipeBuild() {
    return new ListView(shrinkWrap: true, children: <Widget>[
      new Container(
        height: 200.0,
        color: Colors.blue,
      ),
      const SizedBox(
        height: 20,
      ),
      new Container(
        height: 200.0,
        color: Colors.red,
      ),
      const SizedBox(
        height: 20,
      ),
      new Container(
        height: 200.0,
        color: Colors.green,
      ),
    ]);
  }
}

// Mostra as receitas em perquenos quadrados
Widget recipesView(var context, List id, String title, subTitle, String url) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: GestureDetector(
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(url), fit: BoxFit.cover),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 3, spreadRadius: 1, color: Colors.grey)
                  ],
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              padding: const EdgeInsets.all(25),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        subTitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RestaurantDetails(title, id)));
        }),
  );
}
