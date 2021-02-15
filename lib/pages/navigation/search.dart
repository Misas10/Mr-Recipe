import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
