import 'dart:io';

import 'package:MrRecipe/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateRecipe extends StatefulWidget {
  @override
  _CreateRecipeState createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  File imageFile;
  final picker = ImagePicker();
  final TextEditingController controller = TextEditingController();

  _openGallery() async {
    var picture = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      imageFile = File(picture.path);
    });
    // Navigator.of(context).pop();
  }

  _openCamera() async {
    var picture = await picker.getImage(source: ImageSource.camera);
    setState(() {
      imageFile = File(picture.path);
    });
    // Navigator.of(context).pop();
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
                onPressed: () => _openGallery(),
              ),
              SimpleDialogOption(
                child: const Text("Câmara"),
                onPressed: () => _openCamera(),
              )
            ],
          );
        });
  }

  Text simpleCreateRecipeText(String text) {
    return Text(
      text,
      style: simpleTextStyle(fontWeight: FontWeight.bold, fontSize: 17),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        child: Container(
          color: Colors.white,
          padding: appHorizontalPadding(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "Crie já a sua receita",
                    style: titleTextStyle(fontSize: 25),
                  ),
                ),
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
                simpleCreateRecipeText("Tipo de porção"),
                const SizedBox(height: 10),
                simpleCreateRecipeText("Dificuldade"),
                const SizedBox(height: 10),
                simpleCreateRecipeText("Tempo de Preparação"),
                const SizedBox(height: 10),
                simpleCreateRecipeText("Ingredientes"),
                const SizedBox(height: 10),
                simpleCreateRecipeText("Passos de preparação")
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
}
