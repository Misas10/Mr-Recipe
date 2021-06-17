import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../models/recipe_model.dart';

class HttpService {
  final String recipeUrls = "https://misas10.github.io/data/test.json";

  Future<List<Recipe>> getRecipe() async {
    Response res = await get(Uri.parse(recipeUrls));

    if(res.statusCode == 200) {
      debugPrint("Sucesso!!");
      List<dynamic> body = jsonDecode(res.body);

      List<Recipe> recipes = body.map((dynamic item) => Recipe.toJson(item)).toList();

      return recipes;
    } else {
      throw "Não foi possível buscar as receitas";
    }
    
  }

  Future deletePost(int id) async {
    Response res = await delete(Uri.parse("$recipeUrls/$id"));

    if(res.statusCode == 200){
      debugPrint("APAGADO");
    } else {
      throw "Não foi possível apagar a receita";
    }
  }
}
