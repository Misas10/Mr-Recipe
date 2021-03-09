import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FoodCard extends StatelessWidget {
  final String categoryName, categoryIcon;

  FoodCard({this.categoryIcon, this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GestureDetector(
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 7.5),
            child: Row(
              children: <Widget>[
                SizedBox(width: 10),
                Container(
                    child: categoryIcon == null
                        ? Text('')
                        : Image.asset(categoryIcon, height: 30, width: 30)),
                SizedBox(width: 10),
                Center(
                    child: Text(
                  categoryName,
                  style: simpleTextStyle(),
                )),
                SizedBox(width: 10),
              ],
            ),
          ),
        ),
        onTap: () {},
      ),
    );
  }
}
