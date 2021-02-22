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
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 80),//,
          child: Column( 
            
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
          // TIRA O FOCO DO INPUT 'Pesquisar'
          FocusScope.of(context).requestFocus(new FocusNode());
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
