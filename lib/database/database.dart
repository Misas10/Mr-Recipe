import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

// Adiciona receitas novas a base de dados
Future addRecipe({
  @required String name,
  @required String author,
  @required String imgUrl,
  @required String portion,
  @required List ingredients,
  @required int time,
  @required List<dynamic> preparation,
  @required List<dynamic> categories,
  @required String dificulty,
  String chefNotes,
  var id,
}) {
  // recebe ou cria um id
  var recipeId = id ?? firestore.collection("Recipes").doc().id;
  // Adiciona todos os dados recebidos á base de dados
  final docRef = FirebaseFirestore.instance
      .collection('Recipes')
      .doc(recipeId)
      .set({
        "id": recipeId,
        "autor": author,
        "nome_receita": name,
        "dificuldade": dificulty,
        "tempo_total": time,
        "img_url": imgUrl,
        "porção": portion,
        "ingredientes": ingredients,
        "categorias": categories,
        "preparação": preparation,
        "utilizadores_que_deram_like": [],
        "notas_chef": chefNotes ?? ''
      })
      // Caso os dados sejam inseridos com sucesso
      .then((value) => debugPrint("Receita adicionada id: $id"))
      // Caso haja algum erro durante a inserção dos dados
      .catchError((error) => "Falha ao adicionar a Receita: $error");

  return docRef;
}

// Adiciona novos utilizadores a base de dados
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
