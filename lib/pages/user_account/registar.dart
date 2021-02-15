import 'package:MrRecipe/database/database.dart';
import 'package:MrRecipe/widgets/form_errors.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:MrRecipe/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/widgets.dart';
import '../../models/user_model.dart';

class Registar extends StatefulWidget {
  @override
  _RegistarState createState() => _RegistarState();
}

class _RegistarState extends State<Registar> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  List<String> errors = [];
  List<User> users = [];
  bool _showPassword = true;
  final databaseReference = FirebaseDatabase.instance.reference();

  //Permite Apagar o texto do campo "password"
  @override
  void dispose() {
    emailController.dispose();
    confirmPasswordController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TapGestureRecognizer _gestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pop(context);
      };

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            //logo(),
            titleText("Registar-se"),
            SizedBox(height: 30),
            Container(
              //height: MediaQuery.of(context).size.height - 350,
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: appHorizontalPadding(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          emailFormField(),

                          SizedBox(height: 10),
                          passwordFormField("Password", passwordController),
                          SizedBox(
                            height: 10,
                          ),
                          passwordFormField(
                              "Confirme a Password", confirmPasswordController),
                          SizedBox(height: 20),

                          FormError(errors: errors),

                          SizedBox(height: 20),

                          // BOTÃO
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            child: MaterialButton(
                                color: primarycolor(),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                child: Text("Registar",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 17)),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                  }
                                  context.read<AuthService>().register(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim());
                                  saveUsers(emailController.text,
                                      passwordController.text);
                                  // databaseReference.child("Users").set({
                                  //   'email': emailController.text,
                                  //   'password': passwordController.text
                                  // });
                                  Navigator.pop(context);
                                }),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Já tem uma conta? ",
                          style: smallTextSyle(),
                          children: [
                            TextSpan(
                                text: "Faça Login",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline),
                                recognizer: _gestureRecognizer),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ));
  }

  // EMAIL FORM FIELD
  TextFormField emailFormField() {
    return TextFormField(
        keyboardType: TextInputType.emailAddress,
        onChanged: (val) {
          if (val.isNotEmpty && errors.contains(EmailNullError)) {
            setState(() {
              errors.remove(EmailNullError);
            });
          } else if (EmailValidator.validate(val) &&
              val.isEmpty &&
              errors.contains(InvalidEmailError)) {
            setState(() {
              errors.remove(InvalidEmailError);
            });
          }
        },
        validator: (val) {
          if (val.isEmpty && !errors.contains(EmailNullError)) {
            setState(() {
              errors.add(EmailNullError);
            });
          } else if (!EmailValidator.validate(val) &&
              !errors.contains(InvalidEmailError) &&
              val.isNotEmpty) {
            setState(() {
              errors.add(InvalidEmailError);
            });
          }
          return null;
        },
        controller: emailController,
        style: simpleTextSyle(),
        decoration: inputTextDecoration("Email", Icons.email));
  }

  // PASSWORD FORM FIELD
  TextFormField passwordFormField(
      String labeltext, TextEditingController controller) {
    return TextFormField(
      keyboardType: TextInputType.visiblePassword,
      onChanged: (val) {
        if (passwordController.text == confirmPasswordController.text &&
            errors.contains(MatchPassError)) {
          setState(() {
            errors.remove(MatchPassError);
          });
        }

        if (val.isNotEmpty && errors.contains(PassNullError)) {
          setState(() {
            errors.remove(PassNullError);
          });
        } else if (val.length >= 6 && errors.contains(ShortPassError)) {
          setState(() {
            errors.remove(ShortPassError);
          });
        }
      },
      validator: (val) {
        if (controller == passwordController) {
          if (val.isEmpty && !errors.contains(PassNullError)) {
            setState(() {
              errors.add(PassNullError);
            });
          } else if (val.length < 6 &&
              !errors.contains(ShortPassError) &&
              val.isNotEmpty) {
            setState(() {
              errors.add(ShortPassError);
            });
          } else if (passwordController.text !=
                  confirmPasswordController.text &&
              !errors.contains(MatchPassError) &&
              val.isNotEmpty &&
              !errors.contains(ShortPassError)) {
            setState(() {
              errors.add(MatchPassError);
            });
          }
        }
        return null;
      },
      controller: controller,
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
          labelText: labeltext,
          focusedBorder: outlineInputBorder(),
          enabledBorder: outlineInputBorder()),
      obscureText: _showPassword,
    );
  }
}

// TextFormField passwordFormField() {
//   return TextFormField(
//     decoration: PasswordFormField(
//         labeltext: "Password",
//         controller: passwordController),
//   );
// }
