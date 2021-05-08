import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

class LocalRecipe {
  static LocalStorage _storage = new LocalStorage("local_recipe");
  static final localRecipe =
      json.decode(_storage.getItem("localRecipe")) ?? null;

  // LocalRecipe({});

  static void addRecipeToLocalStorage(Map recipeData) async {
    await _storage.ready;

    debugPrint("Adding to LocalStorage...");
    debugPrint(recipeData.toString());
    final localRecipe = json.encode(recipeData);
    _storage.setItem("localRecipe", localRecipe);
  }

  static getRecipeFromLocalStorage() async {
    await _storage.ready;

    debugPrint("Getting to LocalStorage...");
    return localRecipe ?? null;
  }

  static removeRecipeFromLocalStorage() async {
    await _storage.ready;

    debugPrint("Removing from LocalStorage...");
    if (localRecipe != null) _storage.deleteItem("localRecipe");
  }
}
