import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

// adiciona receitas novas a base de dados
Future<void> addRecipe(
    {String name,
    String imgUrl,
    String author,
    bool favorito = false,
    int quantity,
    int calories,
    int tempo,
    List<String> ingredients}) {
  return firestore
      .collection('Recipes')
      .add({
        "nome_receita": name,
        "autor": author,
        "calorias": calories,
        "img_url": imgUrl,
        "quantidade": quantity,
        "ingredientes": ingredients,
        "tempo_total": tempo,
        "IsFavotiro": favorito
      })
      .then((value) => "Receita adicionada")
      .catchError((error) => "Falha ao adicionar a Receita: $error");
}

// adiciona clientes novos a base de dados
Future<void> addUsers(String email, String pass) {
  return firestore
      .collection("Users")
      .add({'email': email, 'password': pass})
      .then((value) => debugPrint("User adicionado"))
      .catchError((error) => debugPrint("Falha ao adicionar o User: $error"));
}

// adiciona categorias a base de dados
Future<void> addCategories(String categoryName, String categoryIcon) {
  return firestore
      .collection("Categories")
      .add({'nome': categoryName, 'Icon': categoryIcon})
      .then((value) => debugPrint("Categoria adicionada!"))
      .catchError((error) => debugPrint('Falha ao adicionar a receita: $error'));
}
