import 'dart:async';

import 'package:MrRecipe/models/category_model.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/Category_food_card.dart';
import 'package:MrRecipe/pages/navigation/recipeDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../models/category_model.dart';

class HomePage extends StatefulWidget {
  final User user;
  final bool fromMain;

  HomePage({Key key, this.user, this.fromMain}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  CollectionReference recipes;
  List<FoodCategory> _categoriesCard = categoriesCard;
  // List _allCategories = allCategories;
  ScrollController _scrollController = new ScrollController();
  Set<String> searchQuery = {};
  StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    if (widget.fromMain != null) {
      _isFirstTime();
    }
    getRecipes();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {}
    });

    FirebaseFirestore.instance
        .collection("Recipes")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        List categories = doc.data()['categorias'];
        setState(() {
          categories.forEach(
              (element) => searchQuery.add(element.toString().toLowerCase()));
        });
        debugPrint(searchQuery.toString());
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    subscription.cancel();
    super.dispose();
  }

  // Verifica a conexão à internet do smartphone
  getInternetConnection() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      debugPrint(result.toString());
      if (result == ConnectivityResult.none) {
        // Texto para quando não ouver conexão à internet
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Ooops!'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text("Vôce não tem uma conexão à internet."),
                      Text(
                          "Para uma melhor experiência estabeleça uma conexão.")
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, result),
                    child: Text("Ok"),
                  )
                ],
              );
            });
      }
    });
  }

  _isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isFirstTime", false);
  }

  bool get wantKeepAlive => true;

  Future<void> getRecipes() async {
    recipes = FirebaseFirestore.instance.collection('Recipes');
  }

  Future<void> refresh() async {
    await buildRecipesStream(widget.user);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    getInternetConnection();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: PrimaryColor,
        // toolbarHeight: 40,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo_without_text.png", height: 32.5),
            SizedBox(width: 10),
            Text(
              "Mr. Recipe",
              style: titleTextStyle(fontSize: 25),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              iconSize: 28,
              onPressed: () => showSearch(
                    context: context,
                    delegate: Search(data: searchQuery.toList()),
                  ))
        ],
      ),
      body: Container(
        padding: appHorizontalPadding(),
        color: BgColor,
        child: RefreshIndicator(
          color: PrimaryColor,
          child: ListView(physics: BouncingScrollPhysics(), children: [
            // const SizedBox(height: 30),
            // Container(
            //   child: Text(
            //     "O que vai desejar hoje?",
            //     style: titleTextStyle(
            //       fontSize: 30,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 22),
            Text("Categorias", style: titleTextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Container(
              height: 80,
              // CATEGORIAS
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _categoriesCard.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      // Os Cartãoes das categorias
                      child: FoodCard(
                        categoryName: _categoriesCard[index].categoryName,
                        categoryIcon: _categoriesCard[index].categoryIcon,
                      ),
                      onTap: () {
                        var name = _categoriesCard[index].categoryName;
                        debugPrint(name);
                        showSearch(
                          context: context,
                          delegate: Search(data: searchQuery.toList()),
                          query: name,
                        );
                      });
                },
              ),
            ),
            const SizedBox(height: 22),
            Text("Receitas em destaque", style: titleTextStyle(fontSize: 25)),
            const SizedBox(height: 12),
            buildRecipesStream(widget.user),
            const SizedBox(height: 20)
          ]),
          onRefresh: refresh,
        ),
      ),
    );
  }

// Mostra as receitas em pequenos quadrados
  buildRecipesStream(User user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: FutureBuilder<QuerySnapshot>(
        future: recipes.get(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Erro');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                padding: const EdgeInsets.only(top: 15),
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(PrimaryColor),
                ),
              ),
            );
          } else {
            return new ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children:
                    snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                  return Column(
                    children: [
                      buildRecipes(documentSnapshot.data()),
                      const SizedBox(height: 15)
                    ],
                  );
                }).toList());
          }
        },
      ),
    );
  }

  static ListView buildRecipes(Map data) {
    return new ListView.separated(
      separatorBuilder: (BuildContext context, int index) => Divider(
        color: Colors.transparent,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                PageTransition(
                    child: RecipeDetails(
                      recipeName: data['nome_receita'],
                      ingredientes: data['ingredientes'],
                      image: data['img_url'],
                      calories: data['calorias'],
                      id: data['id'],
                      recipeUids: data['utilizadores_que_deram_like'],
                      categories: data["categorias"],
                      preparation: data["preparação"],
                      portion: data['porção'],
                    ),
                    type: PageTransitionType.rightToLeft));
          },
          child: Container(
            padding:
                const EdgeInsets.only(bottom: 10, top: 5, right: 5, left: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                const BoxShadow(
                    color: Colors.grey, spreadRadius: 1, blurRadius: 2),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 1.2 / 1, // width : ecrã

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: ClipRRect(
                        child: Image.asset(
                          data['img_url'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text("${data['nome_receita']}",
                        style: simpleTextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// barra de pesquisa
class Search extends SearchDelegate<String> {
  final List data;
  int maxHistory = 6;
  List<String> recentCategoriesSearch = [];
  List searchQuery = [];

  Search({@required this.data});

  // MUDA O HINT TEXT
  @override
  String get searchFieldLabel => "Pesquisar";

  // CUSTOMIZA O SEARCH
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      primaryColor: PrimaryColor,
      hintColor: Colors.white,
      textTheme: TextTheme(
        headline6: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  // CRIA UM HISTÓRIO PARA O UTILIZADOR
  // DE TODAS AS RECEITAS PESQUISADAS
  // ONDE OS ITEMS PODEM SER APAGAS
  _addHistory({String value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    if (prefs.getStringList("recentSearch") == null) {
      prefs.setStringList("recentSearch", recentCategoriesSearch);
    }

    List<String> savedSearch = prefs.getStringList("recentSearch");

    if (value != null) {
      if (savedSearch.length >= maxHistory) {
        savedSearch.removeLast();
      }
      if (!savedSearch.contains(value)) savedSearch.insert(0, value);

      prefs.setStringList("recentSearch", savedSearch);
    }

    recentCategoriesSearch = prefs.getStringList("recentSearch");
    // debugPrint(savedSearch.toString());
  }

  _clearSearch(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> savedList = prefs.getStringList("recentSearch");
    savedList.remove(value);

    prefs.setStringList("recentSearch", savedList);
    recentCategoriesSearch = prefs.getStringList("recentSearch");
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context, {String categorie}) {
    var recipes = FirebaseFirestore.instance
        .collection("Recipes")
        .where("categorias", arrayContains: query.toLowerCase());

    if (query.isNotEmpty) {
      _addHistory(value: query);

      return FutureBuilder<QuerySnapshot>(
          future: recipes.get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: EdgeInsets.symmetric(
                    vertical: 100,
                    horizontal: MediaQuery.of(context).size.width / 2.2),
                child: const CircularProgressIndicator(),
              );
            }

            if (snapshot.hasData && snapshot.data.docs.isEmpty) {
              debugPrint("Não tem dados");
              return Stack(
                children: [
                  SvgPicture.asset("assets/images/no_recipe_found.svg"),
                  Positioned(
                    left: MediaQuery.of(context).size.width / 6,
                    right: MediaQuery.of(context).size.width / 6,
                    top: MediaQuery.of(context).size.height / 2,
                    child: const Text(
                      "Não foi possível encontrar o que procura.",
                      style: TextStyle(fontSize: 17),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            return Container(
              padding: appHorizontalPadding(),
              child: new ListView(
                  shrinkWrap: true,
                  children: snapshot.data.docs
                      .map((DocumentSnapshot documentSnapshot) {
                    return Column(
                      children: [
                        const SizedBox(height: 15),
                        _HomePageState.buildRecipes(documentSnapshot.data()),
                        // const SizedBox(height: 15)
                      ],
                    );
                  }).toList()),
            );
          });
    }
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _addHistory();
    // recipes.where(field)
    // Cria um stateful widget com um setState
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        List keys = data
            .where((element) => element.startsWith(query.toLowerCase()))
            .toList();
        return query.isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    "Histórico",
                    style: simpleTextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: recentCategoriesSearch.length,
                      itemBuilder: (context, index) {
                        // Items do Histórico
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _clearSearch(recentCategoriesSearch[index]);
                                  });
                                }),
                            GestureDetector(
                              child: Text(
                                recentCategoriesSearch[index] ?? "",
                                style: simpleTextStyle(fontSize: 18),
                              ),
                              onTap: () {
                                query = recentCategoriesSearch[index];
                                showResults(context);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              )
            // SUGESTÃO QUANDO O USER ESCREVE ALGO
            : ListView.builder(
                itemCount: keys.length,
                itemBuilder: (context, index) {
                  return new GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        keys[index],
                        style: TextStyle(
                          fontSize: 18,
                          color: PrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      query = keys[index];
                      showResults(context);
                    },
                  );
                });
      },
    );
  }
}
