import 'package:MrRecipe/pages/app.dart';
import 'registar.dart';
import 'package:MrRecipe/services/auth.dart';
import 'package:flutter/gestures.dart';
import 'package:page_transition/page_transition.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_field_validator/form_field_validator.dart';

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

    return Scaffold(
      backgroundColor: BgColor,
      appBar: buildAppBar(context, "Login", "Registar-se"),
      body: GestureDetector(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              SizedBox(
                height: 10,
              ),
              SizedBox(height: 30),
              Container(
                // height: MediaQuery.of(context).size.height - 350,
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: appHorizontalPadding(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Form(
                        autovalidateMode: AutovalidateMode.always,
                        key: _formKey,
                        child: Column(
                          children: [
                            emailFormField(emailController),
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
                            // FormError(errors: errors),
                            SizedBox(height: 20),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 40,
                              child: MaterialButton(
                                  color: PrimaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Text("Login",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 17)),
                                  onPressed: () {
                                    debugPrint(emailController.text +
                                        passwordController.text);
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                      context.read<AuthService>().logIn(
                                          email: emailController.text.trim(),
                                          password:
                                              passwordController.text.trim());
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => App(),
                                          ));
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
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
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      ),
    );
  }

  // PASSWORD FORM FIELD
  TextFormField passwordFormField(
      TextEditingController controller, String labeltext) {
    return TextFormField(
      keyboardType: TextInputType.visiblePassword,
      validator: MultiValidator(
          [RequiredValidator(errorText: "Campo Obrigratório *")]),
      controller: controller,
      decoration: InputDecoration(
        labelText: "Password",
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
        border: OutlineInputBorder(),
      ),
      obscureText: _showPassword,
      style: simpleTextStyle(fontSize: 17),
    );
  }
}
