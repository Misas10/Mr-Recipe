import 'package:MrRecipe/pages/navigation/favorites.dart';
import 'package:MrRecipe/pages/navigation/home_screen.dart';
import 'package:MrRecipe/pages/navigation/search.dart';
import 'package:MrRecipe/pages/navigation/settings.dart';
import 'package:flutter/material.dart';

class TabNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;
  final user;

  const TabNavigator({Key key, this.navigatorKey, this.tabItem, this.user})
      : super(key: key);

  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  @override
  Widget build(BuildContext context) {
    Widget child;

    if (widget.tabItem == "Page1")
      child = HomePage(user: widget.user);
    else if (widget.tabItem == "Page2")
      child = Search(user: widget.user);
    else if (widget.tabItem == "Page3")
      child = Favorites(user: widget.user);
    else if (widget.tabItem == "Page4") child = Settings(user: widget.user);

    return Navigator(
      key: widget.navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}
