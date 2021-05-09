import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:localstorage/localstorage.dart';
import 'build_list.dart';

class CreateRecipe extends StatefulWidget {
  @override
  _CreateRecipeState createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  final LocalStorage storage = new LocalStorage("saved_recipe");
  Map<String, dynamic> localRecipe = {};

  final double itemExtent = 50;
  double bottomSheetHeight;
  List localRecipeIngredients = [];

  // UPLOADING IMAGE VARIABLES
  CollectionReference imgRef;
  firebase_storage.Reference ref;
  File imageFile;
  final picker = ImagePicker();
  bool uploading = false;
  double val = 0;

  double width;
  double height;

  // CONTROLLERS AND KEYS VARIABLES
  final TextEditingController controller = TextEditingController();
  final formKey = GlobalKey<FormBuilderState>();
  final ingredientsFormKey = GlobalKey<FormBuilderState>();
  final stepsFormKey = GlobalKey<FormBuilderState>();

  // CRREATE SCREEN VARIABLES
  Duration initialTimer;
  String time;
  String kitchenType = "";
  String plateType = "";
  String chefNotes = "";
  String dificulty = "";
  String recipeName = "";

  // ANIMATED CONTAINER VARIABLES
  double animatedContainerXOffset = 0;
  double animatedContainerYOffset = 0;
  int _page = 0;
  List localRecipeSteps = [];
  String selectedUnit;
  String ingredientTextKey;
  String quantityTextKey;
  String stepsTextKey;

  List<String> _tipoDePrato = [
    "Pequeno-almoço",
    "Almoço",
    "Jantar",
    "Sobremesa",
    "Bebida",
    "Petiscos",
  ];
  List<String> _tipoDeCozinha = [
    "Portuguesa",
    "Africana",
    "Italiana",
    "Americana",
    "Francesa",
    "Indiana",
  ];

  List<String> _listaDeUnidade = [
    "",
    "g",
    "kg",
    "ml",
    "l",
    "fatia(s)",
  ];

  @override
  void initState() {
    super.initState();
    imgRef = FirebaseFirestore.instance.collection("ImageURLs");
    getRecipeFromLocalStorage();
  }

  //
  // Salva os dados da receita, não terminada, localmente
  //
  void addRecipeToLocalStorage(Map recipeData) async {
    debugPrint("Adding to LocalStorage...");
    await storage.ready;

    localRecipe.addAll(recipeData);
    final recipe = json.encode(localRecipe);

    debugPrint(localRecipe.toString());
    storage.setItem('localRecipe', recipe);
  }

  //
  // Recebe os dados da receita Salvada
  //
  void getRecipeFromLocalStorage() async {
    await storage.ready;

    debugPrint("Getting to LocalStorage...");

    if (storage.getItem('localRecipe') != null) {
      setState(() {
        localRecipe = json.decode(storage.getItem('localRecipe'));
      });

      try {
        List tipoDeCozinha = localRecipe['tipo_de_cozinha'] ?? '';
        kitchenType = tipoDeCozinha.join(", ") ?? "";
      } catch (e) {
        debugPrint(e.toString());
        kitchenType = localRecipe['tipo_de_cozinha'];
      }

      try {
        List tipoDePrato = localRecipe["tipo_de_prato"] ?? [];
        plateType = tipoDePrato.join(", ") ?? "";
      } catch (e) {
        plateType = localRecipe['tipo_de_prato'];
      }

      localRecipeIngredients = localRecipe["ingredientes"] ?? [];
      localRecipeSteps = localRecipe['preparação'] ?? [];

      setState(() {
        time = localRecipe["tempo_de_preparacao"];
        recipeName = localRecipe["nome_receita"];
        chefNotes = localRecipe['notas_do_chef'];
        dificulty = localRecipe['dificuldade'];
      });

      debugPrint(localRecipe.toString());
    }
  }

  //
  // Apaga os dados da receita
  //
  void removeRecipeFromLocalStorage() async {
    await storage.ready;

    debugPrint("Removing from LocalStorage...");
    if (localRecipe != null) storage.deleteItem('localRecipe');
  }

  Future<String> initialValue(String key) async {
    await storage.ready;
    // getRecipeFromLocalStorage();

    if (localRecipe != null) {
      if (localRecipe.containsKey(key)) {
        if (localRecipe[key] == null) return "";
        return localRecipe[key];
      }
    }
    debugPrint("ERRO: A key '$key' não existe");
    return null;
  }

  //
  // CRIA UM 'SELECTOR' PARA O TIPO DE PORÇÃO
  //
  portionPicker() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(13), topLeft: Radius.circular(13)),
        ),
        builder: (context) => Container(
              height: bottomSheetHeight,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                        itemExtent: itemExtent,
                        onSelectedItemChanged: (int index) {},
                        children: List<Widget>.generate(99, (index) {
                          return Center(child: Text((++index).toString()));
                        })),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                        itemExtent: itemExtent,
                        onSelectedItemChanged: (int index) {},
                        children: const <Widget>[
                          Center(child: Text("pessoa(s)")),
                          Center(child: Text("pedaço(s)"))
                        ]),
                  ),
                ],
              ),
            ));
  }

  //
  //  CRIA UM 'SELECTOR' DO TEMPO EM HORAS E MINUTOS
  //
  Widget timerPicker() {
    return CupertinoTimerPicker(
        // initialTimerDuration: Duration(minutes: 1),
        mode: CupertinoTimerPickerMode.hm,
        onTimerDurationChanged: (Duration changedTimer) {
          setState(() {
            initialTimer = changedTimer;
            time = changedTimer.inHours.toString() +
                'hrs ' +
                (changedTimer.inMinutes % 60).toString() +
                'min';
          });
        });
  }

  Future<void> bottomSheet(BuildContext context,
      {Widget child, double height}) {
    return showModalBottomSheet(
      enableDrag: false,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(13),
          topLeft: Radius.circular(13),
        ),
      ),
      backgroundColor: Colors.white,
      context: context,
      builder: (context) => Stack(
        children: [
          Container(
            height: height == null ? bottomSheetHeight : height,
            child: child,
          ),
        ],
      ),
    );
  }

  void _returnData(List list, String name, var storage) async {
    // must use await
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuildList(
          list: list,
          name: name,
          storage: storage,
        ),
      ),
    ).then((value) => getRecipeFromLocalStorage());
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    bottomSheetHeight = MediaQuery.of(context).size.height / 2.8;

    if (_page == 0) {
      animatedContainerYOffset = height;
    } else {
      animatedContainerYOffset = 0;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar("Crie já a sua receita"),
      body: GestureDetector(
        child: Container(
          padding: appHorizontalPadding(),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: FormBuilder(
                  initialValue: {
                    "nome_receita": recipeName,
                    "dificuldade": dificulty,
                    "notas_do_chef": chefNotes,
                    "tipo_de_cozinha": kitchenType,
                    "tipo_de_prato": (plateType + ''),
                  },
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      FormBuilderTextField(
                        // initialValue: recipeName,
                        name: "nome_receita",
                        decoration: _inputTextDecoration("Título da Receita *"),
                      ),
                      const SizedBox(height: 10),
                      simpleCreateRecipeText("Adicione uma foto da receita"),
                      const SizedBox(height: 5),
                      GestureDetector(
                        child: Container(
                          color: Colors.grey,
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          child: imageFile == null
                              ? Center(
                                  child: Icon(Icons.add),
                                )
                              : Image.file(imageFile),
                        ),
                        onTap: () => _showChoiceDialog(context),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        child: simpleCreateRecipeText("Porção"),
                        onTap: () => portionPicker(),
                      ),
                      const SizedBox(height: 10),
                      simpleCreateRecipeText("Dificuldade", isRequired: true),
                      FormBuilderChoiceChip(
                        alignment: WrapAlignment.spaceEvenly,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        name: "dificuldade",
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        options: [
                          FormBuilderFieldOption(
                            value: "Fácil",
                          ),
                          FormBuilderFieldOption(
                            value: "Médio",
                          ),
                          FormBuilderFieldOption(
                            value: "Difícil",
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          simpleCreateRecipeText("Tempo de Preparação"),
                          Container(
                            width: 100,
                            child: FormBuilderField(
                              initialValue: time,
                              name: "tempo_de_preparacao",
                              builder: (FormFieldState<dynamic> field) {
                                return GestureDetector(
                                    child: Text(
                                      time ?? '0 min',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    onTap: () {
                                      bottomSheet(context, child: timerPicker())
                                          .whenComplete(
                                              () => field.didChange(time));
                                    });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      //
                      // INGREDIENTES
                      GestureDetector(
                        child: simpleCreateRecipeText("Ingredientes",
                            isRequired: true),
                        onTap: () => setState(() {
                          _page = 1;
                        }),
                      ),
                      //
                      const SizedBox(height: 10),
                      GestureDetector(
                        child: simpleCreateRecipeText("Passos de preparação"),
                        onTap: () => setState(() {
                          _page = 2;
                        }),
                      ),
                      const SizedBox(height: 10),
                      //
                      // TIPO DE PRATO
                      simpleCreateRecipeText("Tipo de prato"),
                      FormBuilderTextField(
                        key: Key(plateType),
                        name: "tipo_de_prato",
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Ex: almoço",
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        onTap: () =>
                            _returnData(_tipoDePrato, "tipo_de_prato", storage),
                      ),
                      //
                      const SizedBox(height: 10),
                      simpleCreateRecipeText("Cozinha"),
                      FormBuilderTextField(
                        name: "tipo_de_cozinha",
                        key: Key(kitchenType),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Ex: portuguesa",
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        onTap: () => _returnData(
                            _tipoDeCozinha, "tipo_de_cozinha", storage),
                      ),
                      const SizedBox(height: 10),
                      simpleCreateRecipeText("Notas do Chef"),
                      const SizedBox(height: 5),
                      FormBuilderTextField(
                        name: "notas_do_chef",
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () {
                                if (formKey.currentState.validate()) {
                                  setState(() {
                                    uploading = true;
                                  });
                                  uploadImage();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: PrimaryColor,
                                      content: Text("Receita Criada"),
                                    ),
                                  );
                                }
                              },
                              child: Text("CRIAR")),
                          // Spacer(),
                          TextButton(
                              onPressed: () {
                                formKey.currentState.save();
                                final formData = formKey.currentState.value;
                                debugPrint(formData.toString());
                                // removeRecipeFromLocalStorage();
                                addRecipeToLocalStorage(formData);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: PrimaryColor,
                                    content: Text("Receita Salva"),
                                  ),
                                );
                              },
                              child: Text("SALVAR"))
                        ],
                      ),
                    ],
                  ),
                ),
                // uploading
                //     ? Center(
                //         child: Column(
                //         children: [
                //           Container(
                //             child: Text(
                //               "Criando a receita...",
                //               style: simpleTextStyle(),
                //             ),
                //           ),
                //           CircularProgressIndicator(
                //             value: val,
                //             valueColor:
                //                 AlwaysStoppedAnimation<Color>(PrimaryColor),
                //           )
                //         ],
                //       ))
                //     : Container(),
              ),
              buildAnimatedContainer(),
            ],
          ),
        ),
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      ),
    );
  }

  buildTextField(
      var context, TextEditingController controller, String labelText) {
    return TextFormField(
      // keyboardType: TextInputType,
      style: simpleTextStyle(fontWeight: FontWeight.bold),
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
    );
  }

  _openGallery(BuildContext context) async {
    var picture = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      imageFile = File(picture.path);
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  _openCamera() async {
    var picture = await picker.getImage(source: ImageSource.camera);
    setState(() {
      imageFile = File(picture.path);
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text("Escolha"),
            children: [
              SimpleDialogOption(
                child: const Text("Galeria"),
                onPressed: () => _openGallery(context),
              ),
              SimpleDialogOption(
                child: const Text("Câmara"),
                onPressed: () => _openCamera(),
              )
            ],
          );
        });
  }

  simpleCreateRecipeText(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: simpleTextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          isRequired
              ? TextSpan(text: " *", style: TextStyle(color: Colors.red))
              : TextSpan(text: ""),
        ],
      ),
    );
  }

  Future uploadImage() async {
    int i = 1;
    setState(() {
      val = i / imageFile.toString().length;
    });
    ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child("Images/${Path.basename(imageFile.path)}");

    // imgRef
    //     .where("url", isEqualTo: ref.getDownloadURL().toString())
    //     .get()
    //     .then((QuerySnapshot qurySnapshot) {
    //   qurySnapshot.docs.forEach((doc) {
    //     data.add(doc.data());
    //   });
    // });
    // debugdebugPrint("${data.toString()}");

    await ref.putFile(imageFile).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        imgRef.add({"url": value});
        i++;
      });
    });
  }

  final textStyle = const TextStyle(fontSize: 18);
  final padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 20);
  buildAnimatedContainer() {
    return GestureDetector(
      child: AnimatedContainer(
        height: height,
        color: BgColor,
        duration: Duration(milliseconds: 400),
        transform: Matrix4.translationValues(
            animatedContainerXOffset, animatedContainerYOffset, 1),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 50,
                child: Row(
                  children: [
                    // const SizedBox(width: 8),
                    TextButton(
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(fontSize: 17, color: Colors.black),
                        ),
                        onPressed: () => setState(() {
                              _page = 0;
                            })),
                    const Spacer(),
                    Text(
                      _page == 1 ? "Ingredientes" : "Preparação",
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(),
                      child: const Text(
                        "Salvar",
                        style: TextStyle(fontSize: 17, color: PrimaryColor),
                      ),
                      onPressed: () {
                        if (_page == 1) {
                          if (ingredientsFormKey.currentState.validate()) {
                            ingredientsFormKey.currentState.save();
                            final formData =
                                ingredientsFormKey.currentState.value;
                            setState(() {
                              localRecipeIngredients.add(formData);
                              selectedUnit = "";
                              quantityTextKey = "";
                              ingredientTextKey = "";
                            });
                            final Map<String, dynamic> formatedIngredients = {
                              "ingredientes": localRecipeIngredients
                            };
                            debugPrint(formatedIngredients.toString());
                            // addRecipeToLocalStorage(formatedIngredients);
                          }
                        } else if (_page == 2) {
                          if (stepsFormKey.currentState.validate()) {
                            stepsFormKey.currentState.save();
                            final formData = stepsFormKey.currentState.value;
                            setState(() {
                              localRecipeSteps.add(formData["preparação"]);
                              stepsTextKey = "";
                            });
                            final Map<String, dynamic> formatedSteps = {
                              "preparação": localRecipeSteps,
                            };
                            addRecipeToLocalStorage(formatedSteps);
                            debugPrint(formatedSteps.toString());
                          }
                        }
                      },
                    ),
                    // const SizedBox(width: 8)
                  ],
                ),
              ),
              const Divider(),
              _page == 1
                  ? buildAddIngredientsScreen()
                  : _page == 2
                      ? buildAddStepsScreen()
                      : Container(),
            ],
          ),
        ),
      ),
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
    );
  }

  FormBuilder buildAddIngredientsScreen() {
    return FormBuilder(
      initialValue: {
        "unidade": selectedUnit,
        "nome": ingredientTextKey,
        "quantidade": quantityTextKey,
      },
      key: ingredientsFormKey,
      child: Column(
        children: [
          FormBuilderTextField(
            key: Key(ingredientTextKey),
            name: "nome",
            decoration: _inputTextDecoration("Ingrediente"),
          ),
          SizedBox(height: 20),
          Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: FormBuilderTextField(
                  key: Key(quantityTextKey),
                  keyboardType: TextInputType.number,
                  name: "quantidade",
                  decoration: _inputTextDecoration("Quantidade"),
                ),
              ),
              const Spacer(),
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: FormBuilderTextField(
                  key: Key(selectedUnit),
                  readOnly: true,
                  name: "unidade",
                  decoration: _inputTextDecoration("Unidade"),
                  onTap: () => bottomSheet(context, child: unitField()),
                ),
              )
            ],
          ),
          // const SizedBox(height: 20),
          const Divider(height: 60),
          localRecipeIngredients == null
              ? Container()
              : ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: localRecipeIngredients.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return new Center(
                      child: Card(
                        child: Container(
                          padding: padding,
                          child: Row(
                            children: [
                              Text(
                                "${localRecipeIngredients[index]['quantidade']} ",
                                style: textStyle,
                              ),
                              Text(
                                  "${localRecipeIngredients[index]['unidade']}",
                                  style: textStyle),
                              const SizedBox(width: 40),
                              Text("${localRecipeIngredients[index]['nome']}",
                                  style: textStyle),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
        ],
      ),
    );
  }

  FormBuilder buildAddStepsScreen() {
    return FormBuilder(
      key: stepsFormKey,
      child: Column(
        children: [
          FormBuilderTextField(
            key: Key(stepsTextKey),
            name: "preparação",
            decoration: _inputTextDecoration("Passos"),
          ),
          const Divider(height: 60),
          localRecipeSteps.isEmpty
              ? Container()
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: localRecipeSteps.length,
                  itemBuilder: (context, index) => Center(
                    child: Card(
                      child: Container(
                        padding: padding,
                        child: Row(
                          children: [
                            Text(
                              localRecipeSteps[index],
                              style: textStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  _inputTextDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 25),
      floatingLabelBehavior: FloatingLabelBehavior.always,
    );
  }

  unitField() {
    return CupertinoPicker(
      itemExtent: itemExtent,
      onSelectedItemChanged: (index) {
        debugPrint(index.toString());
        setState(() {
          selectedUnit = _listaDeUnidade[index];
        });
      },
      children: List.generate(
        _listaDeUnidade.length,
        (index) => Center(child: Text(_listaDeUnidade[index])),
      ),
    );
  }
}
