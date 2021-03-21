import 'package:MrRecipe/services/auth.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings>
    with AutomaticKeepAliveClientMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: BgColor,
      padding: appHorizontalPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 100),
          Center(
              child: Text("Definições", style: titleTextStyle(fontSize: 30))),
          SizedBox(height: 80),
          FutureBuilder(
            future: context.read<AuthService>().getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return displayUserInfo(context, snapshot);
              } else
                return CircularProgressIndicator(
                  backgroundColor: PrimaryColor,
                );
            },
          ),
          SizedBox(height: 60),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 40,
            //margin: ,
            child: MaterialButton(
                color: PrimaryColor,
                // alignment: Alignment.center,
                // width: MediaQuery.of(context).size.width,
                // padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                child: Text("Logout",
                    style: TextStyle(color: Colors.white, fontSize: 17)),
                onPressed: () {
                  context.read<AuthService>().signOut();
                }),
          ),
        ],
      ),
    );
  }
}

Widget displayUserInfo(context, snapshot) {
  final user = snapshot.data;
  var userName = user.displayName ?? "null"; 
  var userEmail = user.email;
  
  return Container(
    child: Column(
      children: [
        Text("Nome: $userName \nEmail: $userEmail",
            style: simpleTextStyle(fontSize: 18)),
      ],
    ),
  );
}
