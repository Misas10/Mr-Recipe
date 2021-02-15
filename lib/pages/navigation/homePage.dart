import 'package:MrRecipe/models/category_model.dart';
import 'package:MrRecipe/models/restaurant_model.dart';
import '../../widgets/Category_food_card.dart';
import 'package:MrRecipe/pages/navigation/restaurantDetails.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/category_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<RestaurantModel> restaurantList = [];
  List<FoodCategory> _categories = categories;

  @override
  void initState() {
    super.initState();
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference().child("Restaurants");

    databaseReference.once().then((DataSnapshot dataSnapShot) {
      restaurantList.clear();
      var keys = dataSnapShot.value.keys;
      var values = dataSnapShot.value;

      for (var key in keys) {
        RestaurantModel restaurantModel = new RestaurantModel(
          values[key]['nome'],
          values[key]['img'],
          values[key]['morada'],
          values[key]['produtos']['Nome_prod'],
          values[key]['produtos']['img_prod'],
          values[key]['produtos']['preço'],
        );
        restaurantList.add(restaurantModel);
      }
      setState(() {
        //
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 70),
          Container(
              margin: EdgeInsets.only(left: 20),
              child: Text("Home",
                  style: GoogleFonts.lato(
                      fontSize: 30, fontWeight: FontWeight.bold))),
          SizedBox(height: 15),
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
          SizedBox(height: 15),
          Container(
            child: restaurantList.length == 0
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: restaurantList.length,
                      itemBuilder: (context, index) {
                        return restaurantPage(
                            context,
                            restaurantList[index].name,
                            restaurantList[index].morada,
                            restaurantList[index].img);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

Widget restaurantPage(var context, String title, subTitle, String url) {
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
                  builder: (context) => RestaurantDetails(title)));
        }),
  );
}
