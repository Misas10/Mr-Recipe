import 'package:MrRecipe/pages/navigation/favorites.dart';
import 'package:MrRecipe/pages/navigation/home_screen.dart';
import 'package:MrRecipe/pages/navigation/search.dart';
import 'package:MrRecipe/pages/navigation/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;

  const TabNavigator({Key key, this.navigatorKey, this.tabItem})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
    Widget child;

    if (tabItem == "Page1")
      child = HomePage(user: user);
    else if (tabItem == "Page2")
      child = Search(user: user);
    else if (tabItem == "Page3")
      child = Favorites(user: user);
    else if (tabItem == "Page4") child = Settings(user: user);

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}
