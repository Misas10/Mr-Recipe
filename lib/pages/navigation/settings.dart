import 'package:MrRecipe/pages/user_account/login.dart';
import 'package:MrRecipe/pages/user_account/registar.dart';
import 'package:MrRecipe/pages/wrapper.dart';
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

// extension para capitalizar Strings
extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach =>
      this.split(" ").map((str) => str.inCaps).join(" ");
}

class _SettingsState extends State<Settings>
    with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColor,
        title: Text("Conta"),
        centerTitle: true,
      ),
      backgroundColor: BgColor,
      body: Container(
        padding: appHorizontalPadding(),
        child: Column(
          children: [
            widget.user == null ? Container() : _buildUserProfile(context),
            _buildItemSetting("Definições", Icons.settings),
            widget.user != null
                ? _buildItemSetting("Logout", Icons.logout, isLoggedOut: true)
                : Container(),
            // _buildItemSettings(),
            // _buildItemSettings(),
            // _buildItemSettings(),
          ],
        ),
      ),
    );
  }

  Container noUserLogged() {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Não nenhum utilizador logado",
          style: titleTextStyle(fontSize: 20),
        ),
        TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => Login())),
            child: Text("Login")),
        TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => Registar())),
            child: Text("Registar")),
        TextButton(onPressed: () {}, child: Text("Google"))
      ],
    ));
  }

  Column _buildUserProfile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        Center(child: Text("Perfil", style: titleTextStyle(fontSize: 30))),
        SizedBox(height: 60),
        Container(
          child: Column(
            children: [
              CircleAvatar(
                minRadius: 40,
                backgroundColor: Colors.lightBlue,
                child: Text(
                  "${widget.user.displayName[0].inCaps}",
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "${widget.user.displayName.inCaps}",
                style:
                    simpleTextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 80),
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
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (builder) => AuthWrapper()));
              }),
        ),
      ],
    );
  }

  _buildItemSetting(String label, IconData iconData,
      {bool isLoggedOut = false}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: GestureDetector(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              isLoggedOut ? Icon(iconData, color: Colors.red) : Icon(iconData),
              SizedBox(width: 10),
              isLoggedOut
                  ? Text(label,
                      style: TextStyle(fontSize: 20, color: Colors.red))
                  : Text(label, style: TextStyle(fontSize: 20)),
              Spacer(),
              isLoggedOut ? Container() : Icon(Icons.arrow_forward),
            ],
          ),
        ),
        onTap: () {
          isLoggedOut
              ? context.read<AuthService>().signOut().then((value) =>
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (builder) => AuthWrapper())))
              : debugPrint(label);
        },
      ),
    );
  }
}
