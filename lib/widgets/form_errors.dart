import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';

class FormError extends StatelessWidget {
  const FormError({Key key, @required this.errorLabel}) : super(key: key);

  final String errorLabel;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(
        Icons.error,
        color: Colors.red,
        size: 25,
      ),
      SizedBox(width: 10),
      Text(
        errorLabel,
        style: simpleTextStyle(),
      ),
    ]);
  }
}
