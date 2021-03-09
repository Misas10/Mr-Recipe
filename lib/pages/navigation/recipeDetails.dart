import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';

class RecipeDetails extends StatelessWidget {
  final String recipeName;
  final List ingredientes;
  final String image; // mostra a imagem principal

  RecipeDetails({this.recipeName, this.ingredientes, this.image});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Hero(
                  child: Container(
                      height: MediaQuery.of(context).size.height * .45,
                      child: Image.asset(
                        image,
                        fit: BoxFit.cover,
                      )),
                  tag: "recipeImg",
                ),
                Container(
                  padding: appHorizontalPadding(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text("Ingredientes",
                          style: simpleTextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Container(
                        child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(
                            height: 50,
                            //thickness: 1,
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: ingredientes.length,
                          itemBuilder: (context, index) {
                            return BuildItemRow(
                              name: "${ingredientes[index]}",
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BuildItemRow extends StatelessWidget {
  final String name;

  const BuildItemRow({
    this.name,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: simpleTextStyle(
                      fontSize: 18,
                    )),
              ],
            ),
          ],
        ),
      ],
    );
  }
}