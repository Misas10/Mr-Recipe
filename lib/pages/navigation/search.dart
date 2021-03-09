import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: GestureDetector(
        child: Scaffold(
          backgroundColor: BgColor,
          body: Container(
            padding: appHorizontalPadding(),
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Column(
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [searchInput()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // TIRA O FOCO DO INPUT 'Pesquisar'
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      ),
    );
  }

  TextFormField searchInput() {
    return TextFormField(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 0),
        prefixIcon: Icon(
          Icons.search,
          color: Colors.grey,
        ),
        hintText: "Pesquisar",
        border: OutlineInputBorder(),
        filled: true,
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 1.0)),
      ),
    );
  }
}
