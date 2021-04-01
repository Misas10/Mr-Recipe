import 'package:MrRecipe/models/filter_chip_model.dart';
import 'package:MrRecipe/pages/navigation/favorites.dart';
import 'package:MrRecipe/widgets/filter_chips.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';

class Search extends StatefulWidget {
  final User user;

  const Search({Key key, this.user});
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  // bool _selected = false;
  List<FilterChipData> filterChips = FilterChips.all;
  double spacing = 8;

  bool get wantKeepAlive => true;

  Widget buildFilterChips() => Wrap(
      runSpacing: spacing,
      spacing: spacing,
      children: filterChips
          .map(
            (filterChip) => FilterChip(
              label: Text(filterChip.label),
              onSelected: (isSelected) {
                setState(() {
                  filterChips = filterChips.map((otherChip) {
                    return filterChip == otherChip
                        ? otherChip.copy(isSelected: isSelected)
                        : otherChip;
                  }).toList();
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (builder) => Favorites()));
                });
              },
              selected: filterChip.isSelected,
              selectedColor: filterChip.color.withOpacity(.25),
              
            ),
          )
          .toList());
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: GestureDetector(
        child: Container(
          color: BgColor,
          padding: appHorizontalPadding(),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Form(
              key: _formKey,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchInput(),
                  const SizedBox(height: 10),
                  GestureDetector(
                    child: buildFilterChips(),
                  )
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
