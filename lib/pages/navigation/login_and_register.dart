import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';

class LoginAndRegister extends StatefulWidget {
  @override
  _LoginAndRegisterState createState() => _LoginAndRegisterState();
}

class _LoginAndRegisterState extends State<LoginAndRegister> {
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

  Color _bgColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    if (_pageState == 0) {
      debugPrint("Login");
      _loginYOffSet = 170;
      _registerYOffSet = screenHeight;
      _loginWidth = screenWidth;
      _loginXOffSet = 0;
      _loginOpacity = 1;
      title = "Login";
    } else {
      debugPrint("registar");
      _loginYOffSet = 150;
      _registerYOffSet = 180;
      _loginWidth = screenWidth - 20;
      _loginOpacity = .7;
      title = "Registar";
      // _bgColor = Colors.blue;
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
          GestureDetector(
            onTap: () {
              setState(() {
                if (_pageState != 0)
                  _pageState = 0;
                else
                  _pageState = 1;
              });
            },
            child: AnimatedContainer(
              width: _loginWidth,
              curve: Curves.fastLinearToSlowEaseIn,
              duration: Duration(milliseconds: 1000),
              transform:
                  Matrix4.translationValues(_loginXOffSet, _loginYOffSet, 1),
              decoration: BoxDecoration(
                color: BgColor.withOpacity(_loginOpacity),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                if (_pageState != 1)
                  _pageState = 1;
                else
                  _pageState = 0;
              });
            },
            child: AnimatedContainer(
              curve: Curves.fastLinearToSlowEaseIn,
              duration: Duration(milliseconds: 1200),
              transform: Matrix4.translationValues(0, _registerYOffSet, 1),
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
}
