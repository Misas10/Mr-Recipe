import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/*Widget appBarMain(BuildContext context) {
  return AppBar(
    title: Image.asset(
      "assets/images/flooop.png",
      height: 120,
    ),
  );
}
*/

EdgeInsets appHorizontalPadding() {
  return EdgeInsets.symmetric(horizontal: 24);
}

InputDecoration inputTextDecoration(String labelText, var icon) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: TextStyle(color: Colors.black54, fontSize: 17),
    //hintText: hintText,
    //floatingLabelBehavior: FloatingLabelBehavior.always,
    focusedBorder: outlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
    enabledBorder: outlineInputBorder(),
    suffixIcon: Padding(
        padding: EdgeInsets.fromLTRB(0, 20, 20, 20),
        child: Icon(icon, color: Colors.grey)),
  );
}

OutlineInputBorder outlineInputBorderError() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(28),
    gapPadding: 10,
    borderSide: BorderSide(color: Colors.red, width: 1.5));

OutlineInputBorder outlineInputBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(28),
    gapPadding: 10,
    borderSide: BorderSide(color: Colors.grey));

Center titleText(String text) {
  return Center(
    child: Text(text,
        style: GoogleFonts.lato(fontSize: 35, color: Colors.black54)),
  );
}

TextStyle simpleTextSyle() {
  return TextStyle(color: Colors.black, fontSize: 16);
}

TextStyle smallTextSyle() {
  return TextStyle(color: Colors.black, fontSize: 15);
}

logo() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Image.asset(
        "assets/images/logo_slogan.png",
        height: 100,
      )
    ],
  );
}

Color primarycolor() {
  return Color.fromARGB(255, 254, 92, 25);
}

// buttonText() {
//   return TextStyle(fontSize: 18, color: Colors.white);
// }

buildButton(var context, String texto, String routeName) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 40,
    child: MaterialButton(
        color: primarycolor(),
        //alignment: Alignment.center,
        //width: MediaQuery.of(context).size.width,
        //padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Text(texto, style: TextStyle(color: Colors.white, fontSize: 17)),
        onPressed: () {
          Navigator.pushReplacementNamed(context, routeName);
        }),
  );
}

// LOGIN/REGISTAR VALIDATION
final RegExp emailValidatorRegExp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
const String EmailNullError = "Insira o seu email";
const String InvalidEmailError = "Insira um email válido";
const String PassNullError = "Insira a sua password";
const ShortPassError = "A password é curta demais (min. 6 caractéres)";
const String MatchPassError = "As passwords não são iguais";
