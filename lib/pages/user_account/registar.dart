import 'package:MrRecipe/database/database.dart';
import 'package:MrRecipe/widgets/form_errors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:MrRecipe/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/widgets.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../app.dart';

class Registar extends StatefulWidget {
  @override
  _RegistarState createState() => _RegistarState();
}

class _RegistarState extends State<Registar> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  List<String> errors = [];

  bool _showPassword = true;
  bool userExists = false;
  Map userData = {};
  Map map = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection("Users")
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                map = {doc.data()['email']: doc.data()['password']};
                userData.addAll(map);
              }),
            });
    setState(() {});
  }

  @override
  void dispose() {
    emailController.dispose();
    confirmPasswordController.dispose();
    passwordController.dispose();
    nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TapGestureRecognizer _gestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pop(context);
      };

    return GestureDetector(
      child: Scaffold(
        backgroundColor: BgColor,
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            buildAppBar(context, "Registar-se"),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: appHorizontalPadding(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: nameController,
                            decoration: inputTextDecoration("Nome"),
                            validator: MultiValidator([
                              RequiredValidator(errorText: "Campo Obrigatório")
                            ]),
                          ),
                          const SizedBox(height: 10),
                          emailFormField(),

                          const SizedBox(height: 10),
                          passwordFormField("Password", passwordController),
                          const SizedBox(
                            height: 10,
                          ),
                          confirmPasswordFormField(
                              "Confirme a Password", confirmPasswordController),
                          const SizedBox(height: 20),

                          Container(
                            padding: EdgeInsets.only(left: 20, right: 10),
                            child: Text(
                              "Ao criar uma conta automaticamente aceita os nossos termos",
                              style: simpleTextStyle(
                                  color: Color.fromRGBO(102, 102, 102, 1)),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                              child: userExists
                                  ? FormError(
                                      errorLabel: "Esta conta já existe")
                                  : Container()),

                          const SizedBox(height: 30),

                          // BOTÃO
                          Container(
                            width: MediaQuery.of(context).size.width / 1.2,
                            height: 50,
                            child: MaterialButton(
                                color: PrimaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                child: Text("Registar",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 17)),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    if (userData
                                        .containsKey(emailController.text)) {
                                      debugPrint("Utilizador existe");
                                      setState(() {
                                        userExists = true;
                                      });
                                    } else {
                                      context
                                          .read<AuthService>()
                                          .register(
                                              email:
                                                  emailController.text.trim(),
                                              password: passwordController.text
                                                  .trim())
                                          .whenComplete(() => addUsers(
                                                      nameController.text,
                                                      emailController.text,
                                                      passwordController.text)
                                                  .whenComplete(
                                                () => Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          App()),
                                                ),
                                              ));
                                    }
                                  }
                                }),
                          ),
                          SizedBox(
                            height: 30,
                          )
                        ],
                      ),
                    ),
                    // SizedBox(height: 20),
                    // Center(
                    //   child: RichText(
                    //     text: TextSpan(
                    //       text: "Já tem uma conta? ",
                    //       style: simpleTextStyle(
                    //           color: Colors.black, fontSize: 12),
                    //       children: [
                    //         TextSpan(
                    //             text: "Faça Login",
                    //             style: TextStyle(
                    //                 fontWeight: FontWeight.bold,
                    //                 decoration: TextDecoration.underline),
                    //             recognizer: _gestureRecognizer),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
    );
  }

  // EMAIL FORM FIELD
  TextFormField emailFormField() {
    return TextFormField(
        keyboardType: TextInputType.emailAddress,
        validator: MultiValidator([
          RequiredValidator(errorText: "Campo Obrigatório"),
          EmailValidator(errorText: "Insira um email válido")
        ]),
        controller: emailController,
        style: simpleTextStyle(color: Colors.black, fontSize: 16),
        decoration: inputTextDecoration("Email"));
  }

  // PASSWORD FORM FIELD
  TextFormField passwordFormField(
      String labeltext, TextEditingController controller) {
    return TextFormField(
      keyboardType: TextInputType.visiblePassword,
      validator: MultiValidator([
        MinLengthValidator(6, errorText: "Mínimo 6 caratéres"),
      ]),
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
          child: Container(
              padding: EdgeInsets.only(top: 17, right: 15),
              child: Text(
                "mostrar",
                style: simpleTextStyle(color: PrimaryColor),
              )),
        ),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        labelStyle: TextStyle(color: Colors.black54, fontSize: 17),
        labelText: labeltext,
      ),
      obscureText: _showPassword,
    );
  }

  // CONFIRM PASSWORD FIELD
  TextFormField confirmPasswordFormField(
      String labeltext, TextEditingController controller) {
    return TextFormField(
      keyboardType: TextInputType.visiblePassword,
      validator: (val) =>
          MatchValidator(errorText: 'As passwords são diferentes')
              .validateMatch(val, passwordController.text),
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
          child: Container(
              padding: EdgeInsets.only(top: 17, right: 15),
              child: Text(
                "mostrar",
                style: simpleTextStyle(color: PrimaryColor),
              )),
        ),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        labelStyle: TextStyle(color: Colors.black54, fontSize: 17),
        labelText: labeltext,
      ),
      obscureText: _showPassword,
    );
  }
}
