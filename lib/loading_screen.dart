import 'dart:async';

import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool _showCircular = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(milliseconds: 1800), () {
      setState(() {
        _showCircular = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Container(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Positioned(
          //   right: 0,
          //   left: 0,
          //   top: 130,
          //   child:
          Container(
            child: Image.asset("assets/icons/Logo.png"),
          ),
          // ),
          _showCircular
              ?
              // ? Positioned(
              //   left: MediaQuery.of(context).size.width / 2,
              //   top: MediaQuery.of(context).size.height / 1.5,
              //     child:
              Container(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    backgroundColor: Colors.black,
                    valueColor: new AlwaysStoppedAnimation<Color>(PrimaryColor),
                  ),
                )
              //)
              : Container(),
        ],
      )),
    );
  }
}
