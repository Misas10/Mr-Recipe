import 'package:MrRecipe/pages/navigation/create_recipes.dart';
import 'package:MrRecipe/pages/navigation/favorites.dart';
import 'package:MrRecipe/pages/navigation/home_screen.dart';
import 'package:MrRecipe/pages/navigation/settings.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  final User user;
  final bool fromMain;

  const App({Key key, this.user, this.fromMain = false}) : super(key: key);
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int currentIndex = 0;
  List<Widget> _pages = [];

  void initState() {
    widget.fromMain
        ? _pages.add(HomePage(
            user: widget.user,
            fromMain: true,
          ))
        : _pages.add(HomePage(user: widget.user));
    _pages.add(CreateRecipe());
    _pages.add(Favorites(user: widget.user));
    _pages.add(Settings(user: widget.user));

    super.initState();
  }

  void _selectTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: PrimaryColor,
        unselectedItemColor: Colors.black87,
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        onTap: (int index) => _selectTab(index),
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.red,
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Criar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Conta')
        ],
        type: BottomNavigationBarType.fixed,
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
