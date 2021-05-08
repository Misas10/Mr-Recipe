import 'package:MrRecipe/models/category_model.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isFirstTime", false);
  }

  bool get wantKeepAlive => true;

  Future<void> getRecipes() async {
    recipes = FirebaseFirestore.instance.collection('Recipes');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: PrimaryColor,
        // toolbarHeight: 40,
        title: Text(
          "Mr. Recipe",
          style: titleTextStyle(fontSize: 25),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              iconSize: 28,
              onPressed: () => showSearch(context: context, delegate: Search()))
        ],
      ),
      body: Container(
        padding: appHorizontalPadding(),
        color: BgColor,
        child: ListView(
            // controller: _scrollController,
            physics: BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 30),
              Container(
                child: Text(
                  "O que vai desejar hoje?",
                  style: titleTextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text("Categorias", style: titleTextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Container(
                height: 80,
                // color: Colors.black,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _categoriesCard.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        child: FoodCard(
                          categoryName: _categoriesCard[index].categoryName,
                          categoryIcon: _categoriesCard[index].categoryIcon,
                        ),
                        onTap: () {
                          var name = _categoriesCard[index].categoryName;
                          debugPrint(name);
                          showSearch(
                              context: context,
                              delegate: Search(),
                              query: name);
                        });
                  },
                ),
              ),
              const SizedBox(height: 22),
              Text("Receitas em destaque", style: titleTextStyle(fontSize: 25)),
              const SizedBox(height: 12),
              Container(
                  // mostra os dados de uma certa collection
                  // neste caso a 'Recipes'
                  // height: 100,
                  width: 100,
                  child: buildRecipesStream(widget.user)),
              const SizedBox(height: 20)
            ]),
      ),
    );
  }

// Mostra as receitas em perquenos quadrados
  buildRecipesStream(User user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: StreamBuilder<QuerySnapshot>(
        stream: recipes.snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Erro');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                padding: EdgeInsets.only(top: 15),
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(PrimaryColor),
                ),
              ),
            );
          } else {
            return buildRecipes(snapshot, user: user);
          }
        },
      ),
    );
  }

  static ListView buildRecipes(AsyncSnapshot<QuerySnapshot> snapshot,
      {User user}) {
    return new ListView.separated(
      separatorBuilder: (BuildContext context, int index) => Divider(
        color: Colors.transparent,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: snapshot.data.docs.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        var recipes = snapshot.data.docs;

        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                PageTransition(
                    child: RecipeDetails(
                      recipeName: recipes[index]['nome_receita'],
                      ingredientes: recipes[index]['ingredientes'],
                      image: recipes[index]['img_url'],
                      calories: recipes[index]['calorias'],
                      id: recipes[index]['id'],
                      recipeUids: recipes[index]['utilizadores_que_deram_like'],
                      user: user,
                      categories: recipes[index]["categorias"],
                      preparation: recipes[index]["preparação"],
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
                          recipes[index]['img_url'],
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text("${recipes[index]['nome_receita']}",
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
  int maxHistory = 6;
  List<String> recentCategoriesSearch = [];

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

    debugPrint(savedSearch.toString());
  }

  _clearSearch(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> savedList = prefs.getStringList("recentSearch");
    savedList.remove(value);

    prefs.setStringList("recentSearch", savedList);
    recentCategoriesSearch = prefs.getStringList("recentSearch");
  }

  _buildHistory() {
    final suggestionList = query.isEmpty
        ? recentCategoriesSearch
        : allCategories
            .where((element) => element.toLowerCase().startsWith(query))
            .toList();

    ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          query = suggestionList[index];
          showResults(context);
        },
        title: Text(suggestionList[index]),
      ),
    );
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
    if (query.isNotEmpty) {
      _addHistory(value: query);
      var recipes = FirebaseFirestore.instance
          .collection("Recipes")
          .where("categorias", arrayContains: query.toLowerCase());

      return StreamBuilder<QuerySnapshot>(
          stream: recipes.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.data.size == 0) {
              debugPrint("Não tem dados");
              if (query.isNotEmpty) {
                return const Center(
                    child: Text("Não foi possível encontrar o que procura"));
              } else {
                return Container();
              }
            }
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: ListView(
                children: [
                  SizedBox(height: 20),
                  _HomePageState.buildRecipes(snapshot),
                  SizedBox(height: 20),
                ],
              ),
            );
          });
    }
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _addHistory();
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Text(
            "Histórico",
            style: simpleTextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: ListView.builder(
              // separatorBuilder: (context, index) => const Divider(
              //   color: Colors.transparent,
              //   // height: 5,
              // ),
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
      );
    });
  }
}
