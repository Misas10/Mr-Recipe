import 'dart:io';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CreateRecipe extends StatefulWidget {
  @override
  _CreateRecipeState createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  CollectionReference imgRef;
  firebase_storage.Reference ref;
  File imageFile;
  final picker = ImagePicker();
  bool uploading = false;
  double val = 0;
  final TextEditingController controller = TextEditingController();
  final formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    imgRef = FirebaseFirestore.instance.collection("ImageURLs");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Crie já a sua receita",
          style: titleTextStyle(fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        child: Container(
          padding: appHorizontalPadding(),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                FormBuilder(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      buildTextField(context, controller, "Nome da receita"),
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
                      simpleCreateRecipeText("Porção"),
                      const SizedBox(height: 10),
                      simpleCreateRecipeText("Dificuldade", isRequired: true),
                      FormBuilderChoiceChip(
                        alignment: WrapAlignment.spaceEvenly,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        name: "choice_chip",
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
                      simpleCreateRecipeText("Tempo de Preparação"),
                      const SizedBox(height: 10),
                      simpleCreateRecipeText("Ingredientes", isRequired: true),
                      const SizedBox(height: 10),
                      simpleCreateRecipeText("Passos de preparação"),
                      const SizedBox(height: 10),
                      simpleCreateRecipeText("Tipo de prato"),
                      const SizedBox(height: 10),
                      simpleCreateRecipeText("Cozinha"),
                      const SizedBox(height: 10),
                      simpleCreateRecipeText("Notas do Chef"),
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
                uploading
                    ? Center(
                        child: Column(
                        children: [
                          Container(
                            child: Text(
                              "Criando a receita...",
                              style: simpleTextStyle(),
                            ),
                          ),
                          CircularProgressIndicator(
                            value: val,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(PrimaryColor),
                          )
                        ],
                      ))
                    : Container(),
              ],
            ),
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
    var picture = await picker.getImage(
        source: ImageSource.gallery);
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
    // debugPrint("${data.toString()}");

    await ref.putFile(imageFile).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        imgRef.add({"url": value});
        i++;
      });
    });
  }
}
