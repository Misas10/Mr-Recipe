import 'package:MrRecipe/pages/app.dart';
import 'package:MrRecipe/pages/navigation/recipeDetails.dart';
import 'package:MrRecipe/services/auth.dart';
import 'package:MrRecipe/widgets/no_user_buttons.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:page_transition/page_transition.dart';
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
  String pass;
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if (widget.user != null) {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.user.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        pass = documentSnapshot.data()['password'];
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: customAppBar("Conta"),
      backgroundColor: BgColor,
      body: Container(
        width: double.infinity,
        padding: appHorizontalPadding(),
        child:
            widget.user == null ? noUserLogged() : _buildUserProfile(context),
        // _buildItemSetting("Definições", Icons.settings),
        // _buildItemSetting("Receitas criadas", Icons.receipt),
        // _buildItemSetting("Sobre", Icons.info),
        // widget.user != null
        //     ? _buildItemSetting("Logout", Icons.logout, isLoggedIn: true)
      ),
    );
  }

  Widget noUserLogged() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width / 1.22),
          child: IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              PageTransition(
                child: SettingsItem(item: "Definições", user: widget.user),
                type: PageTransitionType.rightToLeft,
              ),
            ),
          ),
        ),
        NoUserButtons(),
      ],
    );
  }

  Column _buildUserProfile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        Container(
          child: Column(
            children: [
              CircleAvatar(
                minRadius: 40,
                backgroundColor: Colors.lightBlue,
                child: Text(
                  widget.user.displayName == null ||
                          widget.user.displayName == ""
                      ? "N"
                      : "${widget.user.displayName[0].inCaps}",
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.user.displayName == null || widget.user.displayName == ""
                    ? "Nome de Exemplo"
                    : "${widget.user.displayName.inCaps}",
                style:
                    simpleTextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        Center(
          child: Text("Email: ${widget.user.email}",
              style: simpleTextStyle(fontSize: 18)),
        ),
        SizedBox(height: 30),
        _buildItemSetting("Definições", Icons.settings),
        _buildItemSetting("Receitas criadas", Icons.receipt),
        _buildItemSetting("Sobre", Icons.info),
        _buildItemSetting("Logout", Icons.logout, isLoggedIn: true)
      ],
    );
  }

  _buildItemSetting(String label, IconData iconData,
      {bool isLoggedIn = false}) {
    return GestureDetector(
      onTap: () async {
        if (isLoggedIn) {
          bool isConfirmed = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirmar"),
                content: Text("Tem a certeza que quer sair da sua conta?"),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        "Sair",
                        style: TextStyle(color: Colors.red),
                      )),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Cancelar"),
                  ),
                ],
              );
            },
          );
          if (isConfirmed == true) {
            context.read<AuthService>().signOut().then(
                  (value) => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => App()),
                    (route) => false
                  ),
                );
          }
        }

        Navigator.push(
          context,
          PageTransition(
            child: SettingsItem(item: label, user: widget.user, pass: pass),
            type: PageTransitionType.rightToLeft,
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              isLoggedIn ? Icon(iconData, color: Colors.red) : Icon(iconData),
              SizedBox(width: 10),
              isLoggedIn
                  ? Text(label,
                      style: TextStyle(fontSize: 20, color: Colors.red))
                  : Text(label, style: TextStyle(fontSize: 20)),
              Spacer(),
              isLoggedIn ? Container() : Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsItem extends StatefulWidget {
  final User user;
  final String item;
  final String pass;

  const SettingsItem(
      {Key key, @required this.item, @required this.user, this.pass})
      : super(key: key);

  @override
  _SettingsItemState createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  List<String> createdRecipe = [];
  final recipes = FirebaseFirestore.instance.collection("Recipes");

  @override
  void initState() {
    getRecipes();
    super.initState();
  }

  getRecipes() async {
    if (widget.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.user.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        List receitas = documentSnapshot.data()['receitas_criadas'];

        debugPrint(receitas.toString());
        if (receitas != null) {
          setState(() {
            receitas.forEach((element) => createdRecipe.add(element));
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.item) {
      case "Definições":
        return buildDefaultPage(widget.item, child: definicoes());
        break;

      case "Receitas criadas":
        return buildDefaultPage(widget.item, child: receitasCriadas());
        break;

      case "Sobre":
        return buildDefaultPage(widget.item, child: sobre());
        break;

      default:
        return Container();
    }
  }

  Widget buildDefaultPage(String title, {@required Widget child}) {
    return Scaffold(
      backgroundColor: BgColor,
      appBar: customAppBar(title),
      body: Container(
        padding: appHorizontalPadding(),
        child: child,
      ),
    );
  }

  Widget definicoes() {
    if (widget.user != null) {
      return Container(
        padding: const EdgeInsets.only(top: 10),
        width: double.infinity,
        child: TextButton(
            child: Text(
              "Apagar conta",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            style: TextButton.styleFrom(minimumSize: Size(100, 1)),
            onPressed: () async {
              bool isconfirmed = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirmar"),
                    content: Text("Tem a certeza que quer apagar a sua conta?"),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            "Apagar conta",
                            style: TextStyle(color: Colors.red),
                          )),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Cancelar"),
                      ),
                    ],
                  );
                },
              );
              if (isconfirmed == true) {
                context
                    .read<AuthService>()
                    .deleteAccount(widget.pass)
                    .then((_) => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => App()),
                          (route) => false,
                        ));
              }
            }),
      );
    }
    return Container();
  }

  Widget receitasCriadas() {
    if (createdRecipe.isNotEmpty) {
      return StreamBuilder<QuerySnapshot>(
          stream: recipes.where("id", whereIn: createdRecipe).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            // if(snapshot.hasError)

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(PrimaryColor),
                ),
              );
            } else if (!snapshot.hasData) {
              return Container(
                child: Text("Não tem receitas criadas"),
              );
            } else {
              return new ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data.docs[index];
                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      key: Key(data['nome_receita']),
                      background: new Container(
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        child: Card(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            child: Text(
                              data['nome_receita'],
                              style: TextStyle(fontSize: 17),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          PageTransition(
                            child: RecipeDetails(
                                recipeName: data['nome_receita'],
                                ingredientes: data['ingredientes'],
                                image: data['img_url'],
                                id: data['id'],
                                calories: data['calorias'],
                                recipeUids: data['utilizadores_que_deram_like'],
                                preparation: data['preparação'],
                                categories: data['categorias']),
                            type: PageTransitionType.rightToLeft,
                          ),
                        ),
                      ),
                      onDismissed: (_) {},
                      confirmDismiss: (direction) async => await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirmar"),
                            content: Text(
                                "Tem a certeza que quer apagar este item?: ${data['nome_receita']}"),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("APAGAR")),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("CANCELAR"),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  });
            }
          });
    } else
      return null;
  }

  Widget sobre() {
    return Text(
        "O Mr. Recipe é uma aplicação para a Prova de Aptidão Profissional");
  }
}
