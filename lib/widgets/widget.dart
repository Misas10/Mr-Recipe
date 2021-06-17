import 'package:flutter/material.dart';

String accountType = "";

EdgeInsets appHorizontalPadding() {
  return EdgeInsets.symmetric(horizontal: 10);
}

AppBar customAppBar(String title) {
  return AppBar(
    title: Text(
      title,
      style: titleTextStyle(fontSize: 24),
    ),
    centerTitle: true,
  );
}

InputDecoration inputTextDecoration(String labelText) {
  return InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
    labelText: labelText,
  );
}

OutlineInputBorder outlineInputBorderError() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    gapPadding: 10,
    borderSide: BorderSide(color: Colors.red, width: 1.5));

OutlineInputBorder outlineInputBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    gapPadding: 10,
    borderSide: BorderSide(color: Colors.grey));

TextStyle titleTextStyle(
    {Color color, double fontSize, FontWeight fontWeight = FontWeight.normal}) {
  return TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: 'Roboto',
      fontWeight: fontWeight);
}

TextStyle simpleTextStyle(
    {Color color = Colors.black,
    double fontSize,
    FontWeight fontWeight = FontWeight.normal}) {
  return TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: 'Roboto',
      fontWeight: fontWeight);
}

Container buildButton(var context, String texto, String routeName) {
  return Container(
    // O width recebe a largura do ecrã todo
    width: MediaQuery.of(context).size.width,
    height: 40,
    child: MaterialButton(
        // Define a cor para a Primarycolor
        color: PrimaryColor,
        // Define as bordas do botão como redondas
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Text(texto, style: TextStyle(color: Colors.white, fontSize: 17)),
        // Ao clicar no botão o utilizador é levado para outra página
        onPressed: () {
          Navigator.pushReplacementNamed(context, routeName);
        }),
  );
}

// Colors
const Color BgColor = Colors.white;
const Color PrimaryColor = Color.fromRGBO(43, 137, 139, 1);

// LOGIN/REGISTAR VALIDATION
final RegExp emailValidatorRegExp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
const String EmailNullError = "Insira o seu email";
const String InvalidEmailError = "Insira um email válido";
const String PassNullError = "Insira a sua password";
const ShortPassError = "A password é curta demais (min. 6 caractéres)";
const String MatchPassError = "As passwords não são iguais";

