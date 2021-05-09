import 'package:MrRecipe/pages/app.dart';
import 'package:MrRecipe/services/auth.dart';
import 'package:MrRecipe/widgets/form_errors.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import '../../database/database.dart';

class LoginAndRegister extends StatefulWidget {
  final int pageState;

  LoginAndRegister({@required this.pageState});

  @override
  _LoginAndRegisterState createState() => _LoginAndRegisterState();
}

class _LoginAndRegisterState extends State<LoginAndRegister> {
  User user;
  Map userData = {};
  Map map = {};
  bool _showPassword = true;
  bool _enabledTextField = true;
  int _animationTime = 450;

  int _pageState = 0;
  double screenWidth = 0;
  double screenHeight = 0;
  String title = "";

  //  LOGIN VARIABLES
  double _loginYOffSet = 0;
  double _loginXOffSet = 0;
  double _loginWidth = 0;
  double _loginOpacity = 1;
  bool loginUserExists = true;

  final _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailLoginController = TextEditingController();
  final TextEditingController _passwordLoginController =
      TextEditingController();

  // REGISTER VARIABLES
  double _registerYOffSet = 0;
  bool registerUserExits = false;

  final _registerFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailRegisterController =
      TextEditingController();
  final TextEditingController _passwordRegisterController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // FORGOT PASSWORD VARIABLES
  double _forgotXOffSet = 0;

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
    _emailLoginController.dispose();
    _passwordLoginController.dispose();
    _confirmPasswordController.dispose();

    _emailRegisterController.dispose();
    _passwordRegisterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = FirebaseAuth.instance.currentUser;

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
      // FocusScope.of(context).unfocus();
      _loginYOffSet = 150;
      _registerYOffSet = 180;
      _loginWidth = screenWidth - 20;
      _loginOpacity = .7;
      title = "Registar";
      _enabledTextField = false;
      _forgotXOffSet = screenWidth;
      //
    } else {
      title = "Recuperar palavra-passe";
      FocusScope.of(context).unfocus();

      _loginXOffSet = -screenWidth - 200;
      _forgotXOffSet = 0;
    }

    return Scaffold(
      backgroundColor: PrimaryColor,
      body: GestureDetector(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 25,
              left: 0,
              child: TextButton(
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white),
                    Text(
                      " Voltar",
                      style: TextStyle(
                        fontSize: 20,
                        // fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.pop(context);
                },
              ),
            ),
            Positioned(
              top: screenHeight / 10,
              child: Text(
                title,
                style: titleTextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
            buildLoginContainer(context),
            buildRegisterContainer(),
            buildForgotPassContainer(),
          ],
        ),
        onTap: () {
          if ("" == null) ;
        },
      ),
    );
  }

  GestureDetector buildForgotPassContainer() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _pageState = 0;
        });
        debugPrint("Forgot pass");
      },
      child: AnimatedContainer(
        curve: Curves.linear,
        duration: Duration(milliseconds: _animationTime),
        transform: Matrix4.translationValues(_forgotXOffSet, _loginYOffSet, 1),
        decoration: BoxDecoration(
          color: BgColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
      ),
    );
  }

  AnimatedContainer buildRegisterContainer() {
    bool enabledTextField = !_enabledTextField;

    return AnimatedContainer(
      curve: Curves.fastLinearToSlowEaseIn,
      duration: Duration(milliseconds: 1100),
      transform: Matrix4.translationValues(0, _registerYOffSet, 1),
      decoration: BoxDecoration(
        color: BgColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: Form(
              key: _registerFormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _pageState = 0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    // controller: nameController,
                    decoration: inputTextDecoration("Nome"),
                    validator: MultiValidator(
                        [RequiredValidator(errorText: "Campo Obrigatório")]),
                  ),
                  const SizedBox(height: 10),
                  emailFormField(_emailRegisterController, enabledTextField),

                  const SizedBox(height: 10),
                  passwordFormField(_passwordRegisterController, "Password",
                      enabledTextField),
                  const SizedBox(height: 10),
                  passwordFormField(_confirmPasswordController,
                      "Confirme a Password", enabledTextField),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: null,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 2, right: 10),
                        child: Text(
                          "Ao criar uma conta automaticamente \naceita os nossos termos",
                          style: simpleTextStyle(
                              color: Color.fromRGBO(102, 102, 102, 1)),
                        ),
                      ),
                    ],
                  ),

                  Container(
                      child: registerUserExits
                          ? FormError(errorLabel: "Esta conta já existe")
                          : Container()),

                  const SizedBox(height: 15),

                  // BOTÃO
                  Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: 40,
                    child: MaterialButton(
                        color: PrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        child: Text("Registar",
                            style:
                                TextStyle(color: Colors.white, fontSize: 19)),
                        onPressed: () {
                          if (_registerFormKey.currentState.validate()) {
                            _registerFormKey.currentState.save();
                            if (userData
                                .containsKey(_emailRegisterController.text)) {
                              debugPrint("Utilizador existe");
                              setState(() {
                                registerUserExits = true;
                              });
                            } else {
                              setState(() {
                                accountType = "email";
                              });
                              context
                                  .read<AuthService>()
                                  .register(
                                      email:
                                          _emailRegisterController.text.trim(),
                                      password: _passwordRegisterController.text
                                          .trim())
                                  .whenComplete(
                                    () => addUsers(
                                            _nameController.text,
                                            _emailRegisterController.text,
                                            _passwordRegisterController.text)
                                        .then(
                                      (_) => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => App(),
                                        ),
                                      ),
                                    ),
                                  );
                            }
                          }
                        }),
                  ),
                  const SizedBox(height: 200)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AnimatedContainer buildLoginContainer(BuildContext context) {
    return AnimatedContainer(
      width: _loginWidth,
      curve: Curves.linear,
      duration: Duration(milliseconds: _animationTime),
      transform: Matrix4.translationValues(_loginXOffSet, _loginYOffSet, 1),
      decoration: BoxDecoration(
        color: BgColor.withOpacity(_loginOpacity),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          autovalidateMode: AutovalidateMode.disabled,
          key: _loginFormKey,
          child: Column(
            children: [
              emailFormField(_emailLoginController, _enabledTextField),
              const SizedBox(height: 10),
              passwordFormField(
                  _passwordLoginController, "Password", _enabledTextField),
              const SizedBox(height: 20),
              // GestureDetector(
              //   onTap: () {
              //     setState(() {
              //       _pageState = 2;
              //     });
              //   },
              //   child: Container(
              //     alignment: Alignment.centerRight,
              //     child: Text(
              //       "Esqueceu-se da palavra-passe?",
              //       style: TextStyle(
              //           // color: Colors.white,
              //           fontSize: 15,
              //           decoration: TextDecoration.underline),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 20),
              Container(
                child: loginUserExists
                    ? Container()
                    : FormError(
                        errorLabel: "O email ou password estão incorretos"),
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
                        style: TextStyle(color: Colors.white, fontSize: 19)),
                    onPressed: () {
                      debugPrint(_emailLoginController.text +
                          _passwordLoginController.text);
                      if (_loginFormKey.currentState.validate()) {
                        _loginFormKey.currentState.save();
                        if (userData[_emailLoginController.text] !=
                            _passwordLoginController.text) {
                          debugPrint("O utilizador não existe");
                          setState(() {
                            loginUserExists = false;
                          });
                        } else {
                          debugPrint("O utilizador existe");
                          setState(() {
                            accountType = "email";
                          });
                          context
                              .read<AuthService>()
                              .logIn(
                                  email: _emailLoginController.text.trim(),
                                  password:
                                      _passwordLoginController.text.trim())
                              .then(
                                (_) => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => App(),
                                    )),
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
    );
  }

  TextFormField emailFormField(
      TextEditingController controller, bool enabledTextField) {
    return TextFormField(
      // onChanged: ,
      enabled: enabledTextField,
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

  TextFormField passwordFormField(TextEditingController controller,
      String labeltext, bool enabledTextField) {
    return TextFormField(
      enabled: enabledTextField,
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
              padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
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
