import 'dart:convert';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:localstorage/localstorage.dart';

class BuildList extends StatefulWidget {
  @required
  final List list;
  final String name;
  final LocalStorage storage;

  const BuildList({Key key, this.list, this.name, this.storage})
      : super(key: key);
  @override
  _BuildListState createState() => _BuildListState();
}

class _BuildListState extends State<BuildList> {
  final formKey = GlobalKey<FormBuilderState>();

  Map<String, dynamic> localRecipe = {};
  List initialValueList;
  String initialValue;
  String result;

  @override
  void initState() {
    getRecipeFromLocalStorage();
    super.initState();
  }

  // String initialValue(String key) {
  //   if (localRecipe.containsKey(key)) {
  //     if (localRecipe[key] == null) return "";
  //     return localRecipe[key];
  //   }
  //   debugPrint("ERRO: A key '$key' não existe");
  //   return null;
  // }

//
// Salva os dados da receita, não terminada, localmente
//
  void addRecipeToLocalStorage(Map recipeData) async {
    debugPrint("Adding to LocalStorage...");
    await widget.storage.ready;
    localRecipe.addAll(recipeData);

    final recipe = json.encode(localRecipe);
    widget.storage.setItem('localRecipe', recipe);
    debugPrint(localRecipe.toString());
  }

//
// Recebe os dados da receita Salvada
//
  void getRecipeFromLocalStorage() async {
    await widget.storage.ready;
    debugPrint("Getting to LocalStorage Build List...");

    try {
      setState(() {
        localRecipe = json.decode(widget.storage.getItem('localRecipe'));
      });
    } catch (e) {
      debugPrint(e.toString());
    }
    // debugPrint(localRecipe.toString());
  }

  // Future getList() async {
  //   await widget.storage.ready;
  //   setState(() {
  //     initialValue = localRecipe["tipo_de_cozinha"];
  //   });
  // }

  // returnFormField(Map formData) {
  //   initialValueList = formData[widget.name];
  //   initialValue = initialValueList.join(", ");
  //   setState(() {
  //     result = initialValue;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: BgColor,
        body: Column(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  height: 50,
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      TextButton(
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(fontSize: 17, color: Colors.black),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        widget.name == "tipo_de_cozinha"
                            ? "Tipo de cozinha"
                            : "Tipo de Prato",
                        style: const TextStyle(fontSize: 19),
                      ),
                      const Spacer(),
                      TextButton(
                        style: TextButton.styleFrom(),
                        child: const Text(
                          "Salvar",
                          style: TextStyle(fontSize: 17, color: PrimaryColor),
                        ),
                        onPressed: () {
                          formKey.currentState.save();
                          final formData = formKey.currentState.value;
                          addRecipeToLocalStorage(formData);
                        },
                      ),
                      const SizedBox(width: 12)
                    ],
                  ),
                ),
                const Divider(),
                FormBuilder(
                  key: formKey,
                  child: FormBuilderCheckboxGroup(
                      orientation: OptionsOrientation.vertical,
                      activeColor: PrimaryColor,
                      name: widget.name,
                      options: List.generate(
                        widget.list.length,
                        (index) => new FormBuilderFieldOption(
                          value: widget.list[index],
                          child: Text(
                            widget.list[index],
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      )
                      // onChanged: (List<dynamic> list) {
                      //   debugPrint(list.toString());
                      // },
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
