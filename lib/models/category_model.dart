class FoodCategory {
  String categoryName, categoryIcon;

  FoodCategory({this.categoryIcon, this.categoryName});
}

final categories = [
  FoodCategory(categoryName: "Carne", categoryIcon: "assets/icons/Lock.svg"),
  FoodCategory(categoryName: "Peixe", categoryIcon: "assets/icons/Lock.svg"),
  FoodCategory(
      categoryName: "Sobremesas", categoryIcon: "assets/icons/Lock.svg"),
  FoodCategory(categoryName: "Vegan", categoryIcon: "assets/icons/Lock.svg"),
  FoodCategory(categoryName: "Sushi", categoryIcon: "assets/icons/Lock.svg"),
  FoodCategory(categoryName: "Ver Mais", categoryIcon: null)
];
