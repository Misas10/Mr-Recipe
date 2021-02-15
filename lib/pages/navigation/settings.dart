import 'package:MrRecipe/services/auth.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  //final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: appHorizontalPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(height: 100),
          Center(
              child: Text("Definições", style: GoogleFonts.lato(fontSize: 30))),
          SizedBox(height: 80),
          FutureBuilder(
            future: context.read<AuthService>().getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return displayUserInfo(context, snapshot);
              } else
                return CircularProgressIndicator();
            },
          ),
          SizedBox(height: 60),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 40,
            //margin: ,
            child: MaterialButton(
                color: primarycolor(),
                //alignment: Alignment.center,
                //width: MediaQuery.of(context).size.width,
                //padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
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
  return Container(
    child: Column(
      children: [
        Text("Nome: null \nEmail: ${user.email}",
            style: GoogleFonts.lato(fontSize: 18)),
      ],
    ),
  );
}
