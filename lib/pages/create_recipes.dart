import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';

class CreateRecipe extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        child: Container(
          color: Colors.white,
          padding: appHorizontalPadding(),
          child: Column(
            children: [
              buildTextField(context, controller, "Nome da receita"),
            ],
          ),
        ),
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      ),
    );
  }

  buildTextField(
      var context, TextEditingController controller, String labelText) {
    return TextFormField(
      // keyboardType: TextInputType,
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
    );
  }
}
