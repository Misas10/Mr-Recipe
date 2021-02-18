import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin{
  final _formKey = GlobalKey<FormState>();
  

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {

    super.build(context);

    return GestureDetector(
      // appBar: AppBar(
        // title: TextField(
        //   decoration: InputDecoration(
        //     icon: Icon(Icons.search),
        //   ),
        // ),
        // centerTitle: true,
        // actions: [
        //   Column(
        //     children: [
        //       Container(
        //         child: ButtonBar(),
        //       )
        //     ],
        //   )
        // ],
      // ),

      child: Scaffold(
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 80),//,
          child: Column( 
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(children: [
                  searchInput()
                ],),
              ),
            ],
          ),
        ),
      ),
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          // FocusScopeNode currentFocus = FocusScope.of(context);
          // if(!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null){
          //   currentFocus.focusedChild.unfocus();
          // }
        }
    );
  }

  TextFormField searchInput() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: Colors.grey,),
        hintText: "Pesquisar",
        border: OutlineInputBorder(),
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1.0)
        ),
      ),
    );
  }

}
