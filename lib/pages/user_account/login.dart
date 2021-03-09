import 'package:MrRecipe/pages/navigation/navigation.dart';
import 'registar.dart';
import 'package:MrRecipe/services/auth.dart';
import 'package:MrRecipe/widgets/form_errors.dart';
import 'package:flutter/gestures.dart';
import 'package:page_transition/page_transition.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _showPassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TapGestureRecognizer _gestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          PageTransition(
              child: Registar(), type: PageTransitionType.rightToLeft),
        );
      };

    return GestureDetector(
      child: Scaffold(
        backgroundColor: BgColor,
        appBar: buildAppBar(context, "Login"),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              SizedBox(
                height: 10,
              ),
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
                            emailFormField(),
                            SizedBox(
                              height: 10,
                            ),
                            passwordFormField(
                              passwordController,
                              "Password",
                            ),
                            const SizedBox(height: 20),
                            Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Esqueceu-se da palavra-passe?",
                                style: TextStyle(
                                    //color: Colors.white,
                                    fontSize: 15,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                            const SizedBox(height: 20),
                            FormError(errors: errors),
                            SizedBox(height: 20),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 40,
                              child: MaterialButton(
                                  color: PrimaryColor,
                                  //alignment: Alignment.center,
                                  //width: MediaQuery.of(context).size.width,
                                  //padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Text("Login",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 17)),
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                    }
                                    context.read<AuthService>().logIn(
                                        email: emailController.text.trim(),
                                        password:
                                            passwordController.text.trim());
                                    NavBar();
                                  }),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Não tem conta? ",
                            style: simpleTextStyle(
                                color: Colors.black, fontSize: 12),
                            children: [
                              TextSpan(
                                  text: "Registe-se",
                                  style: TextStyle(
                                      //color: Colors.white,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
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
        style: simpleTextStyle(color: Colors.black, fontSize: 14),
        decoration: inputTextDecoration("Email", Icons.email));
  }

  // PASSWORD FORM FIELD
  TextFormField passwordFormField(
      TextEditingController controller, String labeltext) {
    return TextFormField(
      keyboardType: TextInputType.visiblePassword,
      onChanged: (val) {
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
