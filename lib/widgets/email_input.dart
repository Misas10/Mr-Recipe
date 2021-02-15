import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';

// EMAIL FIELD

class EmailFormField extends StatefulWidget {
  const EmailFormField({
    Key key,
    @required this.emailController,
    @required this.errors
  }) : super(key: key);

  final TextEditingController emailController;
  final List<String> errors;

  @override
  _EmailFormFieldState createState() => _EmailFormFieldState();
}

class _EmailFormFieldState extends State<EmailFormField> {

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        keyboardType: TextInputType.emailAddress,
        validator: (val){
        if (val.isEmpty){
          setState(() {
            widget.errors.add(EmailNullError);
          });
          }
        return null;
        },
        controller: widget.emailController,
        style: simpleTextSyle(),
        decoration: inputTextDecoration("Email", Icons.email));
  }
}