import 'package:MrRecipe/models/restaurant_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RestaurantDetails extends StatefulWidget {
  final String name;

  RestaurantDetails(this.name);

  @override
  _RestaurantDetailsState createState() => _RestaurantDetailsState();
}

class _RestaurantDetailsState extends State<RestaurantDetails> {
  // List<FoodModel> foodList = FoodModel.list;
  List<RestaurantModel> restaurantList = [];

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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(widget.name),
            Container(
              padding: EdgeInsets.only(right: 20, left: 20, top: 25),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  )),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: restaurantList.length,
                itemBuilder: (context, index) {
                  return buildItemRow(
                    name: restaurantList[index].prodName,
                    url: restaurantList[index].prodImg,
                    price: restaurantList[index].prodPrice,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class buildItemRow extends StatelessWidget {
  final String name;
  final String url;
  final double price;

  const buildItemRow({
    this.name,
    this.url,
    this.price,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover, image: AssetImage(url)),
                  borderRadius: BorderRadius.circular(15)),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                Text("$price€"),
                SizedBox(height: 15),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
