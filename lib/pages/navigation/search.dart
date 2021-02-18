import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin{

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {

    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            icon: Icon(Icons.search),
          ),
        ),
        centerTitle: true,
        actions: [
          Column(
            children: [
              Container(
                child: ButtonBar(),
              )
            ],
          )
        ],
      ),
      body: Center(child: Text("Hello")),
    );
  }
}
