import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';

// PASSWORD FIELD

class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labeltext;
  final List <String> error;

  const PasswordFormField({
    Key key,
    this.controller,
    this.labeltext,
    this.error,
  })  : assert(controller != null),
        super(key: key);

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _showPassword = true;

  @override
  Widget build(BuildContext context) {
    List <String> errors = widget.error;

    return TextFormField(
      keyboardType: TextInputType.visiblePassword,
      onChanged: (val) {
        if(val.isNotEmpty && errors.contains(PassNullError)){
          setState(() {
            errors.remove(PassNullError);
          });

        }else if(val.length >= 6 && errors.contains(ShortPassError)){
          setState(() {
            errors.remove(ShortPassError);
          });
        }
      },
      validator: (val) {
        if(val.isEmpty && !errors.contains(PassNullError)){
          setState(() {
            errors.add(PassNullError);
          });
        }else if(val.length < 6 && !errors.contains(ShortPassError)
        && val.isNotEmpty){
          setState(() {
            errors.add(ShortPassError);
          });
        }
        return null;
      },
      controller: widget.controller,
      decoration: InputDecoration(
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
            child: Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 20, 20),
                child: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
          labelStyle: TextStyle(color: Colors.black54, fontSize: 17),
          labelText: widget.labeltext,
          focusedBorder: outlineInputBorder(),
          enabledBorder: outlineInputBorder()),
      obscureText: _showPassword,
    );
  }



}
