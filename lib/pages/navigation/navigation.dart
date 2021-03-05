import 'package:MrRecipe/pages/navigation/favorites.dart';
import 'package:MrRecipe/pages/navigation/home_screen.dart';
import 'package:MrRecipe/pages/navigation/search.dart';
import 'package:MrRecipe/pages/navigation/settings.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with TickerProviderStateMixin {
  TabController _tabController;

  List<Tab> _tabs = <Tab>[
    Tab(icon: Icon(Icons.home), text: "Home"),
    Tab(icon: Icon(Icons.search), text: "Busca"),
    Tab(icon: Icon(Icons.favorite_border_outlined), text: "Favoritos"),
    Tab(icon: Icon(Icons.settings), text: "Definições")
  ];

  List<Widget> _pageOptions = <Widget>[
    Padding(padding: appHorizontalPadding(), child: HomePage()),
    Padding(padding: appHorizontalPadding(), child: Search()),
    Padding(padding: appHorizontalPadding(), child: Favorites()),
    Padding(padding: appHorizontalPadding(), child: Settings()),
  ];

  @override
  void initState() {
    // _tabs = getTabs(_startingTabCount);
    _tabController = getTabController();
    super.initState();
  }

  TabController getTabController() {
    return TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(controller: _tabController, children: _pageOptions),
      bottomNavigationBar: TabBar(
          isScrollable: false,
          labelPadding: EdgeInsets.zero,
          controller: _tabController,
          tabs: _tabs),
      // unselectedItemColor: Colors.grey,
      // selectedItemColor: primarycolor(),
      // currentIndex: _selectedIndex,  // onTap: _onItemTap,
    );
  }
}
