class OnboardingScreenModel {
  String title;
  String body;
  String image;

  OnboardingScreenModel({this.title, this.body, this.image});
}

List<OnboardingScreenModel> onboardingModels = [
  OnboardingScreenModel(
    title: "Crie receitas",
    body:
        "Crie e partilhe as suas receitas saborosas com o resto do mundo e receba o feedback em tempo real.",
    image: "assets/images/splash_screen_images/chef_cooking.svg",
  ),
  //
  OnboardingScreenModel(
    title: "Fácil e saudável",
    body:
        "Encontre milhares de receitas fáceis e saudáveis para que possa salvar tempo e aproveitar melhor a comida.",
    image: "assets/images/splash_screen_images/food_image.svg",
  ),
  //
  OnboardingScreenModel(
    title: "Guarde as suas favoritas",
    body: "Salve as suas receitas favoritas e compartilhe com os seus amigos.",
    image: "assets/images/splash_screen_images/share.jpg",
  ),
];
