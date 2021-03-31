import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

// adiciona receitas novas a base de dados
Future<void> addRecipe(
    {String name,
    String author,
    int calories,
    String imgUrl,
    int quantity,
    List ingredients,
    int time,
    List usersFavorites}) {
  var id = firestore.collection("Recipes").doc().id;
  final docRef = FirebaseFirestore.instance
      .collection('Recipes')
      .doc(id)
      .set({
        "id": id,
        "nome_receita": name,
        "autor": author,
        "calorias": calories,
        "img_url": imgUrl,
        "quantidade": quantity,
        "ingredientes": ingredients,
        "tempo_total": time,
        "utilizadores_que_deram_likes": [],
      })
      .then((value) => debugPrint("Receita adicionada id: $id"))
      .catchError((error) => "Falha ao adicionar a Receita: $error");

  return docRef;
}


// adiciona clientes novos a base de dados
Future<void> addUsers(String name, String email, String pass) async {
  var user = FirebaseAuth.instance.currentUser;
  user.updateProfile(displayName: name);
  await user.reload();
  user = FirebaseAuth.instance.currentUser;
  return firestore
      .collection("Users")
      .doc(user.uid)
      .set({'nome': name, 'email': email, 'password': pass})
      .then((value) => debugPrint("User adicionado: ${user.displayName}"))
      .catchError((error) => debugPrint("Falha ao adicionar o User: $error"));
}

// adiciona categorias a base de dados
Future<void> addCategories(String categoryName, String categoryIcon) {
  return firestore
      .collection("Categories")
      .add({'nome': categoryName, 'Icon': categoryIcon})
      .then((value) => debugPrint("Categoria adicionada!"))
      .catchError(
          (error) => debugPrint('Falha ao adicionar a receita: $error'));
}

// adiciona utilizadores que deram 'likes' nas receitas
Future<void> addFavorites(String uid) {
  String favoritesRef = firestore.collection("Favoritos").doc().id;
  return firestore
      .collection('Favoritos')
      .add({
        "id": favoritesRef,
        "uids": uid,
      })
      .then((value) => debugPrint("Utilizador deu like"))
      .catchError((error) => debugPrint("Falha ao dar o like"));
}
