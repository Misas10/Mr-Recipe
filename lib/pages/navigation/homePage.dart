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

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin{
  CollectionReference recipes = FirebaseFirestore.instance.collection('Recipes');
  List<Recipe> recipeList = [];
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

    return Container(
      padding: appHorizontalPadding(),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 65),
              Container(
                child: Text("Home",
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
                        child: CircularProgressIndicator()
                      )
                    );
                  }

                  return new ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder:(context, index){
                      return restaurantPage(
                            context,
                            snapshot.data.docs[index]['ingredientes'],
                            snapshot.data.docs[index]['ingredientes'][index],
                            snapshot.data.docs[index]['autor'],
                            snapshot.data.docs[index]['img_url'],
                    );
                  },
                );
              },
            )
          ),
        ],
      ),
    );
  }
}

// Mostra as receitas em perquenos quadrados
Widget restaurantPage(var context, List id, String title, subTitle, String url) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 25),
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
              padding: EdgeInsets.all(25),
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
            SizedBox(height: 20),
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
