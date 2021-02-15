import 'package:firebase_database/firebase_database.dart';

class FoodModel {
  DatabaseReference foodId;
  String foodName;
  double price;
  String imgUrl;

  FoodModel({this.foodId, this.price, this.foodName, this.imgUrl});
}
