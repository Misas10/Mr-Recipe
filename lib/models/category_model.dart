class FoodCategory {
  String categoryName, categoryIcon;

  FoodCategory({this.categoryIcon, this.categoryName});
}

final categoriesCard = [
  FoodCategory(categoryName: "Carne", categoryIcon: "assets/icons/meat.png"),
  FoodCategory(categoryName: "Peixe", categoryIcon: "assets/icons/fish.png"),
  FoodCategory(
      categoryName: "Sobremesa", categoryIcon: "assets/icons/cupcake.png"),
  FoodCategory(categoryName: "Vegan", categoryIcon: "assets/icons/vegan.png"),
  FoodCategory(categoryName: "Sushi", categoryIcon: "assets/icons/sushi.png"),
  FoodCategory(categoryName: "Ver Mais", categoryIcon: null)
];

final allCategories = ["Carne", "Peixe", "Sobremesa", "Vegan", "Sushi"];
