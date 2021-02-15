
import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: appHorizontalPadding(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo.png", height: 100),
              SizedBox(height: 30),
              Text(
                "Olá seja bem-vindo ao Dinity.",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 30),
              buildButton(context, "Próximo", "/login"),
            ],
          ),
        ),
      ),
    );
  }
}
