import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:MrRecipe/services/firestorage.dart';
import 'package:MrRecipe/widgets/no_user_buttons.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:localstorage/localstorage.dart';
import 'build_list.dart';
import '../../database/database.dart';

class CreateRecipe extends StatefulWidget {
  @override
  _CreateRecipeState createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  final LocalStorage storage = new LocalStorage("saved_recipe");
  Map<String, dynamic> localRecipe = {};
  User user = FirebaseAuth.instance.currentUser;

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

  // CRREATE SCREEN VARIABLES
  Duration initialTimer;
  String time;
  String dificultyOption = "";

  // KEYS VARIABLES
  final formKey = new GlobalKey<FormBuilderState>();
  final ingredientsFormKey = new GlobalKey<FormBuilderState>();
  final stepsFormKey = new GlobalKey<FormBuilderState>();

  // CONTROLLERS
  final TextEditingController controller = TextEditingController();
  TextEditingController recipeNameController = new TextEditingController();
  TextEditingController dificultyController = new TextEditingController();
  TextEditingController chefNotesController = new TextEditingController();
  TextEditingController kitchenTypeController = new TextEditingController();
  TextEditingController plateTypeController = new TextEditingController();
  TextEditingController portionController = new TextEditingController();

  // ANIMATED CONTAINER VARIABLES
  double animatedContainerXOffset = 0;
  double animatedContainerYOffset = 0;
  int _page = 0;
  List localRecipeSteps = [
    "Separe as gemas das claras.",
    "Bata as gemas com o açúcar até a mistura ficar esbranquiçada.",
    "Adicione o queijo Mascarpone e misture bem.",
    "Bata as claras em castelo e junte-as lentamente ao preparado anterior.",
    "Misture o café frio e o Marsala numa taça e embeba os palitos de La Reine.",
    "Coloque metade dos palitos no fundo de uma taça (do tipo que se usa para gratinar), cubra-os com metade do preparado feito com os ovos, coloque o resto dos palitos e cubra tudo com o que sobra do preparado.",
    "Deixe repousar no frigorífico durante pelo menos 3 horas (o ideal é deixar repousar 12 horas).",
    "Antes de servir, polvilhe o Tiramisu com o cacau em pó usando uma peneira."
  ];
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
    "Entrada",
    "Prato principal"
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
    // removeRecipeFromLocalStorage();
    getRecipeFromLocalStorage();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  // ADICIONA A TABELA LOCAL PARA O FIRESTORE
  // E DEPOIS ADICIONA O ID PARA O
  addToFirestore() async {
    await storage.ready;
    var id = firestore.collection("Users").doc().id;
    debugPrint(localRecipe.toString());
    addRecipe(
      id: id,
      name: localRecipe['nome_receita'],
      author: user.displayName,
      imgUrl: "assets/images/tiramissu.jpg",
      portion: localRecipe['porção'],
      ingredients: localRecipeIngredients,
      time: 2,
      preparation: localRecipeSteps,
      categories: [localRecipe['nome_receita']],
      dificulty: localRecipe['dificuldade'],
      chefNotes: localRecipe['notas_do_chef'],
    ).then((value) {
      firestore.collection("Users").doc(user.uid).update({
        "receitas_criadas": FieldValue.arrayUnion([id])
      });
    });
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

      // ADICIONAR TODOS OS DADOS DA DB PARA AS VARIÁVEIS
      recipeNameController.text = localRecipe['nome_receita'] ?? '';
      chefNotesController.text = localRecipe['notas_chef'] ?? '';
      portionController.text = localRecipe['porção'] ?? '';
      // bakeTimeController = localRecipe['tempo_cozer/tempo_assar'] ?? '';
      // stepsController.text = localRecipe[''] ?? '';
      // imageFile.path;

      try {
        List tipoDeCozinha = localRecipe['tipo_de_cozinha'];
        kitchenTypeController.text = tipoDeCozinha.join(", ");
      } catch (e) {
        kitchenTypeController.text = '';
        debugPrint(e.toString());
      }

      try {
        List tipoDePrato = localRecipe['tipo_de_prato'];
        plateTypeController.text = tipoDePrato.join(", ");
      } catch (e) {
        plateTypeController.text = '';
        debugPrint(e.toString());
      }

      localRecipeIngredients = localRecipe['ingredientes'] ?? [];
      // localRecipeSteps = localRecipe['preparação'] ?? [];

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
    // recebe a quantidade de porção selecionada
    String nPortion;
    String nPortionText = "pessoas(s)";

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
                      onSelectedItemChanged: (int index) {
                        setState(() {
                          nPortion = (++index).toString();
                          portionController.text = "$nPortion $nPortionText";
                        });
                      },
                      children: List<Widget>.generate(99, (index) {
                        return Center(child: Text((++index).toString()));
                      }),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                        itemExtent: itemExtent,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            switch (index) {
                              case 0:
                                nPortionText = "pessoa(s)";
                                portionController.text =
                                    "$nPortion $nPortionText";
                                break;

                              case 1:
                                nPortionText = "pedaço(s)";
                                portionController.text =
                                    "$nPortion $nPortionText";
                                break;

                              case 2:
                                nPortionText = "fatia(s)";
                                portionController.text =
                                    "$nPortion $nPortionText";
                                break;
                            }
                          });
                        },
                        children: const <Widget>[
                          Center(child: Text("pessoa(s)")),
                          Center(child: Text("pedaço(s)")),
                          Center(child: Text("fatia(s)"))
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

  // Obtem uma imagem e carrega para o ecrã
  Future<Widget> _getImage(BuildContext context, String imageName) async {
    Image image;
    // Carrega uma imagem
    await FireStorageService.loadImage(context, imageName).then((value) {
      // Define algumas propriedades da imagem
      image = Image.network(value.toString(), fit: BoxFit.cover);
    });
    return image;
  }

  @override
  Widget build(BuildContext context) {
    localRecipe.remove("preparação");
    addRecipeToLocalStorage(localRecipe);

    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    bottomSheetHeight = MediaQuery.of(context).size.height / 2.8;

    if (_page == 0) {
      animatedContainerYOffset = height;
    } else {
      animatedContainerYOffset = 0;
    }

    if (user == null) {
      return Scaffold(
        appBar: customAppBar("Crie já a sua receita"),
        backgroundColor: BgColor,
        body: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.width / 2),
          child: NoUserButtons(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: BgColor,
      appBar: customAppBar("Crie já a sua receita"),
      body: GestureDetector(
        child: Container(
          padding: appHorizontalPadding(),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: FormBuilder(
                  key: formKey,
                  initialValue: {
                    "dificuldade": localRecipe['dificuldade'] ?? '',
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      FormBuilderTextField(
                        controller: recipeNameController,
                        name: "nome_receita",
                        decoration: _inputTextDecoration("Título da Receita *"),
                        validator: (_) =>
                            requiredField(recipeNameController.text),
                      ),
                      const SizedBox(height: 10),
                      simpleCreateRecipeText("Adicione uma foto da receita"),
                      const SizedBox(height: 5),
                      GestureDetector(
                        child: Container(
                            color: localRecipe["imgUrl"] == null
                                ? Colors.grey
                                : Colors.white,
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            child: localRecipe["imgUrl"] == null
                                ? Center(
                                    child: Icon(Icons.add),
                                  )
                                : Image.asset(
                                    "assets/images/tiramissu.jpg",
                                    fit: BoxFit.fitWidth,
                                  )
                            // FutureBuilder(
                            //     future: _getImage(context,
                            //         "Images/image_picker4722318118759654671.jpg"),
                            //     builder: (constex, snapshot) {
                            //       if (snapshot.connectionState ==
                            //           ConnectionState.done) {
                            //         return Container(
                            //           child: snapshot.data,
                            //         );
                            //       }

                            //       return Container();
                            //     },
                            //   ),
                            ),
                        onTap: () => _showChoiceDialog(context),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        child: simpleCreateRecipeText("Porção"),
                      ),
                      TextFormField(
                        readOnly: true,
                        controller: portionController,
                        onTap: () => portionPicker(),
                      ),
                      const SizedBox(height: 10),
                      simpleCreateRecipeText("Dificuldade", isRequired: true),
                      FormBuilderChoiceChip(
                        key: Key(localRecipe['dificuldade'] ?? ''),
                        alignment: WrapAlignment.spaceEvenly,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        name: "dificuldade",
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        options: [
                          FormBuilderFieldOption(
                            value: "Fácil",
                          ),
                          FormBuilderFieldOption(
                            value: "Média",
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
                              // key: Key(time),
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
                        controller: plateTypeController,
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
                        controller: kitchenTypeController,
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
                        valueTransformer: (value) => debugPrint(value),
                        controller: chefNotesController,
                        maxLength: 500,
                        minLines: 3,
                        maxLines: 5,
                        name: "notas_do_chef",
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () {
                                if (formKey.currentState.validate()) {
                                  formKey.currentState.save();
                                  setState(() {
                                    uploading = true;
                                    localRecipe = {
                                      "nome_receita": recipeNameController.text,
                                      "notas_do_chef": chefNotesController.text,
                                      "porção": portionController.text,
                                      'dificuldade': formKey
                                          .currentState.value["dificuldade"],
                                    };
                                  });
                                  uploadImage()
                                      .then((value) => addToFirestore());
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
                                setState(() {
                                  formKey.currentState.save();
                                  debugPrint(
                                      formKey.currentState.value.toString());
                                  localRecipe.addAll({
                                    "nome_receita": recipeNameController.text,
                                    "notas_do_chef": chefNotesController.text,
                                    "porção": portionController.text,
                                    'dificuldade': formKey
                                        .currentState.value["dificuldade"],
                                    "imgUrl": localRecipe['imgUrl'] ?? '',
                                  });
                                });
                                addRecipeToLocalStorage(localRecipe);
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
      style: simpleTextStyle(fontWeight: FontWeight.bold),
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
    );
  }

  final double maxHeight = 1024, maxWidht = 1024;

  _openGallery(BuildContext context) async {
    var picture = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      imageFile = File(picture.path);
      localRecipe["imgUrl"] = "assets/images/tiramissu.jpg";
    });
    addRecipeToLocalStorage(localRecipe);
    Navigator.of(context, rootNavigator: true).pop();
  }

  _openCamera() async {
    var picture = await picker.getImage(
        source: ImageSource.camera, maxHeight: 700, maxWidth: 1024);
    setState(() {
      imageFile = File(picture.path);

      localRecipe["imgUrl"] = "assets/images/tiramissu.jpg";
    });
    addRecipeToLocalStorage(localRecipe);
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
    try {
      ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("Images/${Path.basename(imageFile.path)}");
      setState(() {
        localRecipe["imgUrl"] = "assets/images/tiramissu.jpg";
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    // imgRef
    //     .where("url", isEqualTo: ref.getDownloadURL().toString())
    //     .get()
    //     .then((QuerySnapshot qurySnapshot) {
    //   qurySnapshot.docs.forEach((doc) {
    //     data.add(doc.data());
    //   });
    // });
    // debugdebugPrint("${data.toString()}");
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
          animatedContainerXOffset,
          animatedContainerYOffset,
          1,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 50,
                child: Row(
                  children: [
                    TextButton(
                      child: const Text(
                        "sair",
                        style: TextStyle(fontSize: 17, color: Colors.black),
                      ),
                      onPressed: () => setState(() {
                        _page = 0;
                      }),
                    ),
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
                            ingredientsFormKey.currentState.save();
                            var value = ingredientsFormKey.currentState.value;
                            String nome = value['nome'];
                            String quantidade = value['quantidade'];
                            String unidade = value['unidade'];
                            debugPrint(value.toString());
                            if (nome.isNotEmpty || unidade.isEmpty) {
                              setState(() {
                                localRecipeIngredients
                                    .add("$quantidade$unidade $nome");
                                localRecipe["ingredientes"] =
                                    localRecipeIngredients;
                              });
                              debugPrint(localRecipeIngredients.toString());
                              addRecipeToLocalStorage(localRecipe);
                            }
                            // addRecipeToLocalStorage(localRecipe);
                            debugPrint(value.toString());
                          } else if (_page == 2) {
                            stepsFormKey.currentState.save();
                            var value =
                                stepsFormKey.currentState.value["preparação"];
                            if (value.toString().isNotEmpty) {
                              setState(() {
                                localRecipeSteps.add(value);
                                // debugPrint(localRecipeSteps.toString());
                                localRecipe['preparação'] = localRecipeSteps;
                              });
                              addRecipeToLocalStorage(localRecipe);
                            }
                            debugPrint(
                              stepsFormKey.currentState.value.toString(),
                            );
                          }
                        }),
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
            validator: RequiredValidator(errorText: "Campo obrigatório *"),
            name: "nome",
            decoration: _inputTextDecoration("Ingrediente"),
          ),
          SizedBox(height: 20),
          Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: FormBuilderTextField(
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
                  validator:
                      RequiredValidator(errorText: "Campo obrigatório *"),
                  readOnly: true,
                  name: "unidade",
                  decoration: _inputTextDecoration("Unidade"),
                  onTap: () => bottomSheet(context, child: unitField()),
                ),
              )
            ],
          ),
          const Divider(height: 60),
          localRecipeIngredients == null
              ? Container()
              : ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: localRecipeIngredients.length,
                  shrinkWrap: true,
                  itemBuilder: (context, int index) {
                    return new Center(
                      child: _customDismissible(
                        index: index,
                        child: Card(
                          child: Container(
                            width: double.infinity,
                            padding: padding,
                            child: Text(
                              "${localRecipeIngredients[index]}",
                              style: textStyle,
                            ),
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            FormBuilderTextField(
              validator: RequiredValidator(errorText: "Campo obrigatório *"),
              name: "preparação",
              decoration: _inputTextDecoration("Passos"),
            ),
            const Divider(height: 60),
            localRecipeSteps.isEmpty
                ? Container()
                : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: localRecipeSteps.length,
                    itemBuilder: (context, index) => _customDismissible(
                      index: index,
                      child: Card(
                        child: Container(
                          padding: padding,
                          width: double.infinity,
                          child: Text(
                            localRecipeSteps[index],
                            style: textStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Dismissible _customDismissible(
      {@required Widget child, @required int index}) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async => await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirmar"),
            content: Text("Tem a certeza que quer apagar o item?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child:
                    const Text("APAGAR", style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("CANCELAR"),
              ),
            ],
          );
        },
      ),
      onDismissed: (direction) {
        if (_page == 1) {
          setState(() {
            localRecipeIngredients.removeAt(index);
          });
          final Map<String, dynamic> formatedMap = {
            "ingredientes": localRecipeIngredients
          };
          addRecipeToLocalStorage(formatedMap);
          debugPrint(localRecipeIngredients.toString());
        } else if (_page == 2) {
          setState(() {
            localRecipeSteps.removeAt(index);
          });
          final Map<String, dynamic> formatedMap = {
            "preparação": localRecipeSteps
          };
          addRecipeToLocalStorage(formatedMap);
          debugPrint(localRecipeIngredients.toString());
        }
      },
      child: child,
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

  // TRATAMENTO DE ERROS
  String requiredField(String value) {
    if (value.isEmpty || value == null) return "Campo obrigatório";
    return null;
  }
}
