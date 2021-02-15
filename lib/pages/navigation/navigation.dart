import 'package:MrRecipe/pages/navigation/homePage.dart';
import 'package:MrRecipe/pages/navigation/search.dart';
import 'package:MrRecipe/pages/navigation/settings.dart';
import 'package:MrRecipe/pages/user_account/login.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  void _onItemTap(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  List <Widget> _pageOptions = <Widget>[
    HomePage(),
    Search(),
    Login(),
    Settings(),
  ]; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _pageOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Busca"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Definições")
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: primarycolor(),
        currentIndex: _selectedIndex,
        onTap: _onItemTap,
      ),
    );
  }
}
