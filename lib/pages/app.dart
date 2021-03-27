import 'package:MrRecipe/pages/navigation/tab_navigator.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with AutomaticKeepAliveClientMixin {
  User user;
  int currentIndex = 0;
  String currentPage = "Page1";
  List<String> pageKeys = ["Page1", "Page2", "Page3", "Page4"];
  Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "Page1": GlobalKey<NavigatorState>(),
    "Page2": GlobalKey<NavigatorState>(),
    "Page3": GlobalKey<NavigatorState>(),
    "Page4": GlobalKey<NavigatorState>(),
  };
  bool get wantKeepAlive => true;

  void initState() {
    super.initState();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  void _selectTab(String tabItem, int index) {
    if (tabItem == currentPage) {
      _navigatorKeys[tabItem].currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        currentPage = pageKeys[index];
        currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        final isFirstRoutInCurrentTab =
            !await _navigatorKeys[currentPage].currentState.maybePop();
        if (isFirstRoutInCurrentTab) {
          if (currentPage != "Page1") _selectTab("Page1", 1);
          return false;
        }
        return isFirstRoutInCurrentTab;
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildOffstageNavigator("Page1"),
            _buildOffstageNavigator("Page2"),
            _buildOffstageNavigator("Page3"),
            _buildOffstageNavigator("Page4"),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: PrimaryColor,
          unselectedItemColor: Colors.black,
          backgroundColor: Colors.white,
          currentIndex: currentIndex,
          onTap: (int index) => _selectTab(pageKeys[index], index),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Pesquisa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined), label: 'Conta')
          ],
          type: BottomNavigationBarType.fixed,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
      offstage: currentPage != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem],
        tabItem: tabItem,
        user: user,
      ),
    );
  }
}
