import 'package:MrRecipe/database/database.dart';
import 'package:MrRecipe/widgets/form_errors.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:MrRecipe/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/widgets.dart';

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
  // List<User> users = [];
  bool _showPassword = true;

  // Permite Apagar o campo "password"
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
        body: SafeArea(
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              buildAppBar(context, "Registar-se", "Login"),
              Container(
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
                            // TextFormField(
                            //     // keyboardType: KeyBoardT,
                            //     ),
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: nameController,
                              decoration: inputTextDecoration("Nome"),
                            ),
                            const SizedBox(height: 10),
                            emailFormField(),

                            const SizedBox(height: 10),
                            passwordFormField("Password", passwordController),
                            const SizedBox(
                              height: 10,
                            ),
                            passwordFormField("Confirme a Password",
                                confirmPasswordController),
                            const SizedBox(height: 20),

                            Container(
                              padding: EdgeInsets.only(left: 20, right: 10),
                              child: Text(
                                "Ao criar uma conta automaticamente aceita os nossos termos",
                                style: simpleTextStyle(
                                    color: Color.fromRGBO(102, 102, 102, 1)),
                              ),
                            ),

                            FormError(errors: errors),

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
                                          color: Colors.white, fontSize: 17)),
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                    }
                                    context.read<AuthService>().register(
                                        email: emailController.text.trim(),
                                        password:
                                            passwordController.text.trim());
                                    addUsers(emailController.text,
                                        passwordController.text);
                                    Navigator.pop(context);
                                  }),
                            ),
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
      ),
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
    );
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
        style: simpleTextStyle(color: Colors.black, fontSize: 16),
        decoration: inputTextDecoration("Email"));
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
            child: Container(
                padding: EdgeInsets.only(top: 17, right: 15),
                child: Text(
                  "mostrar",
                  style: simpleTextStyle(color: PrimaryColor),
                )),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          labelStyle: TextStyle(color: Colors.black54, fontSize: 17),
          labelText: labeltext,
          focusedBorder: outlineInputBorder(),
          enabledBorder: outlineInputBorder()),
      obscureText: _showPassword,
    );
  }
}
