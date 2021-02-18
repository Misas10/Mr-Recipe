import 'package:firebase_database/firebase_database.dart';

final databaseReference = FirebaseDatabase.instance.reference();

// ADICIONAR DADOS DAS RECEITAS
DatabaseReference saveRestaurants(String name, String img, String morada,
  String prodName, String prodImg, double prodPrice) {
  var id = databaseReference.child('Receitas').push();
  id.set({

    //TODO: MUDAR 
    "nome": name,
    "img": img,
    "morada": morada,
    "produtos": {"Nome_prod": prodName, "img_prod": prodImg, "preço": prodPrice}
  });
  print("DADOS ENVIADOS PARA A BASE DE DADOS");
  return id;
}

// ADICIONAR DADOS DOS CLIENTES
DatabaseReference saveUsers(String email, String pass) {
  var id = databaseReference.child('Users').push();
  id.set({"email": email, "password": pass});
  
  print("DADOS ENVIADOS PARA A BASE DE DADOS");
  return id;
}
