class FoodCategory {
  String categoryName, categoryIcon;

  FoodCategory({this.categoryIcon, this.categoryName});
}

final categories = [
  FoodCategory(categoryName: "Carne", categoryIcon: "assets/icons/meat.png"),
  FoodCategory(categoryName: "Peixe", categoryIcon: "assets/icons/fish.png"),
  FoodCategory(
      categoryName: "Sobremesas", categoryIcon: "assets/icons/cupcake.png"),
  FoodCategory(categoryName: "Vegan", categoryIcon: "assets/icons/vegan.png"),
  FoodCategory(categoryName: "Sushi", categoryIcon: "assets/icons/sushi.png"),
  FoodCategory(categoryName: "Ver Mais", categoryIcon: null)
];
