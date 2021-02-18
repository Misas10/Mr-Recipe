class FoodCategory {
  String categoryName, categoryIcon;

  FoodCategory({this.categoryIcon, this.categoryName});
}

final categories = [
  FoodCategory(categoryName: "Carne", categoryIcon: "assets/images/frutas.png"),
  FoodCategory(categoryName: "Peixe", categoryIcon: "assets/images/frutas.png"),
  FoodCategory(
      categoryName: "Sobremesas", categoryIcon: "assets/images/frutas.png"),
  FoodCategory(categoryName: "Vegan", categoryIcon: "assets/images/frutas.png"),
  FoodCategory(categoryName: "Sushi", categoryIcon: "assets/images/frutas.png"),
  FoodCategory(categoryName: "Ver Mais", categoryIcon: null)
];
