class Recipe {
  String img;
  String author;
  String name;
  int calories;
  int quantity;
  List<String> ingredients = [];
  int time;
  bool favorite = false;

  Recipe({this.author, this.name, this.calories, this.quantity, this.ingredients, this.time, this.favorite, this.img});
}