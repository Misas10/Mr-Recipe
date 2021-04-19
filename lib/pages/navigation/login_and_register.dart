import 'package:MrRecipe/pages/wrapper.dart';
import 'package:MrRecipe/services/auth.dart';
import 'package:MrRecipe/widgets/form_errors.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';

class LoginAndRegister extends StatefulWidget {
  final int pageState;

  LoginAndRegister({@required this.pageState});

  @override
  _LoginAndRegisterState createState() => _LoginAndRegisterState();
}

class _LoginAndRegisterState extends State<LoginAndRegister> {
  final _formKey = GlobalKey<FormState>();
  Map userData = {};
  Map map = {};
  bool userExists = true;
  bool _showPassword = true;
  bool _enabledTextField = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _pageState = 0;
  double screenWidth = 0;
  double screenHeight = 0;
  String title = "Login";

  //  LOGIN VARIABLES
  double _loginYOffSet = 0;
  double _loginXOffSet = 0;
  double _loginWidth = 0;
  double _loginOpacity = 1;

  // REGISTER VARIABLES
  double _registerYOffSet = 0;

  // FORGOT PASSWORD VARIABLES
  double _forgotXOffSet = 0;

  Color _bgColor = Colors.white;

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection("Users")
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                map = {doc.data()['email']: doc.data()['password']};
                userData.addAll(map);
              }),
            });

    setState(() {
      _pageState = widget.pageState;
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    if (_pageState == 0) {
      debugPrint("Login");
      _forgotXOffSet = screenWidth;
      _loginXOffSet = 0;

      _loginYOffSet = 170;
      _registerYOffSet = screenHeight;
      _loginWidth = screenWidth;
      _loginOpacity = 1;
      title = "Login";
      _enabledTextField = true;
      //
    } else if (_pageState == 1) {
      debugPrint("registar");
      FocusScope.of(context).unfocus();
      _loginYOffSet = 150;
      _registerYOffSet = 180;
      _loginWidth = screenWidth - 20;
      _loginOpacity = .7;
      title = "Registar";
      _enabledTextField = false;
      //
    } else {
      title = "Recuperar palavra-passe";
      FocusScope.of(context).unfocus();

      _loginXOffSet = -screenWidth - 200;
      _forgotXOffSet = 0;
    }

    return Scaffold(
      backgroundColor: PrimaryColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: screenHeight / 10,
            child: Text(
              title,
              style: titleTextStyle(color: Colors.white, fontSize: 30),
            ),
          ),
          AnimatedContainer(
            width: _loginWidth,
            curve: Curves.linear,
            duration: Duration(milliseconds: 500),
            transform:
                Matrix4.translationValues(_loginXOffSet, _loginYOffSet, 1),
            decoration: BoxDecoration(
              color: BgColor.withOpacity(_loginOpacity),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  children: [
                    emailFormField(_emailController),
                    SizedBox(
                      height: 10,
                    ),
                    passwordFormField(
                      _passwordController,
                      "Password",
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _pageState = 2;
                        });
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Esqueceu-se da palavra-passe?",
                          style: TextStyle(
                              // color: Colors.white,
                              fontSize: 15,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      child: userExists
                          ? Container()
                          : FormError(
                              errorLabel:
                                  "O email ou password estão incorretos"),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 40,
                      child: MaterialButton(
                          color: PrimaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          child: const Text("Login",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 19)),
                          onPressed: () {
                            debugPrint(_emailController.text +
                                _passwordController.text);
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              if (userData[_emailController.text] !=
                                  _passwordController.text) {
                                debugPrint("O utilizador não existe");
                                setState(() {
                                  userExists = false;
                                });
                              } else {
                                debugPrint("O utilizador existe");
                                context
                                    .read<AuthService>()
                                    .logIn(
                                        email: _emailController.text.trim(),
                                        password:
                                            _passwordController.text.trim())
                                    .whenComplete(
                                      () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AuthWrapper(),
                                        ),
                                      ),
                                    );
                              }
                            }
                          }),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _pageState = 1;
                          });
                        },
                        child: const Text(
                          "Registar",
                          style: TextStyle(
                            color: PrimaryColor,
                            fontSize: 18,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: PrimaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _pageState = 0;
              });
            },
            child: AnimatedContainer(
              curve: Curves.fastLinearToSlowEaseIn,
              duration: Duration(milliseconds: 1000),
              transform: Matrix4.translationValues(0, _registerYOffSet, 1),
              decoration: BoxDecoration(
                color: BgColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _pageState = 0;
              });
              debugPrint("Forgot pass");
            },
            child: AnimatedContainer(
              curve: Curves.linear,
              duration: Duration(milliseconds: 500),
              transform:
                  Matrix4.translationValues(_forgotXOffSet, _loginYOffSet, 1),
              decoration: BoxDecoration(
                color: BgColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextFormField emailFormField(TextEditingController controller) {
    return TextFormField(
      enabled: _enabledTextField,
      keyboardType: TextInputType.emailAddress,
      validator: MultiValidator(
        [
          RequiredValidator(errorText: "Campo Obrigatório *"),
          EmailValidator(errorText: "Insira um email válido"),
        ],
      ),
      controller: controller,
      style: simpleTextStyle(color: Colors.black, fontSize: 17),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        labelText: "Email",
      ),
    );
  }

  TextFormField passwordFormField(
      TextEditingController controller, String labeltext) {
    return TextFormField(
      enabled: _enabledTextField,
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
      obscureText: _showPassword,
      style: simpleTextStyle(fontSize: 17),
    );
  }
}
