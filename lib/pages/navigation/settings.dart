import 'package:MrRecipe/services/auth.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  final User user;

  const Settings({Key key, this.user}) : super(key: key);

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
          Text(
            "Nome: ${widget.user.displayName}",
            style: simpleTextStyle(fontSize: 18),
          ),
          Text("Email: ${widget.user.email}",
              style: simpleTextStyle(fontSize: 18)),
          SizedBox(height: 60),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 40,
            child: MaterialButton(
                color: PrimaryColor,
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
