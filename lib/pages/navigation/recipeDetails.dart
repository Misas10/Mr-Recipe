import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeDetails extends StatelessWidget {
  final String recipeName;
  final List ingredientes;
  final String image; // mostra a imagem principal

  RecipeDetails({this.recipeName, this.ingredientes, this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Hero(
                child: Container(
                    height: MediaQuery.of(context).size.height * .55,
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                    )),
                tag: "recipeImg",
              ),

              Container(
                padding: appHorizontalPadding(),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: ingredientes.length,
                  itemBuilder: (context, index) {
                    int i = index + 1;

                    return buildItemRow(
                      name: "$i. ${ingredientes[index]}",
                      url: "assets/images/frutas.png",
                    );
                  },
                ),
              ),

              // Hero(
              //   child: Container(
              //       height: MediaQuery.of(context).size.height * .55,
              //       child: Image.asset(image, fit: BoxFit.cover)),
              //   tag: image,
              // ),

              // DraggableScrollableSheet(
              //   maxChildSize: 1,
              //   initialChildSize: .6,
              //   minChildSize: .6,
              //   builder: (context, controller) {
              //     return SingleChildScrollView(
              //       child: Container(
              //         padding: EdgeInsets.only(left: 15),
              //         decoration: BoxDecoration(
              //             color: Colors.white,
              //             borderRadius: BorderRadius.only(
              //                 topLeft: Radius.circular(30),
              //                 topRight: Radius.circular(30))),
              //         child: ListView.builder(
              //           physics: NeverScrollableScrollPhysics(),
              //           shrinkWrap: true,
              //           itemCount: ingredientes.length,
              //           itemBuilder: (context, index) {
              //             int i = index + 1;

              //             return buildItemRow(
              //               name: "$i. ${ingredientes[index]}",
              //               url: "assets/images/frutas.png",
              //             );
              //           },
              //         ),
              //       ),
              //     );
              //   },
              // ),
              // Container(
              //   color: Colors.amber,
              // ),
              //Text(recipeName),
              // Container(
              //   child: ListView.builder(
              //     physics: NeverScrollableScrollPhysics(),
              //     shrinkWrap: true,
              //     itemCount: ingredientes.length,
              //     itemBuilder: (context, index) {
              //       int i = index + 1;

              //       return buildItemRow(
              //         name: "$i. ${ingredientes[index]}",
              //         url: "assets/images/frutas.png",
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class buildItemRow extends StatelessWidget {
  final String name;
  final String url;

  const buildItemRow({
    this.name,
    this.url,
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
                    style: GoogleFonts.roboto(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
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
