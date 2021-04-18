import 'package:MrRecipe/pages/app.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import '../models/onboarding_screen_model.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentIndex = 0;
  PageController _pageViewoController;
  Image image1;
  Image image2;
  Image image3;

  @override
  void initState() {
    _pageViewoController = PageController(initialPage: 0);
    setValue();
    image1 = Image.asset(onboardingModels[0].image);
    image2 = Image.asset(onboardingModels[1].image);
    image3 = Image.asset(onboardingModels[2].image);
    super.initState();
  }

  @override
  void dispose() {
    _pageViewoController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    precacheImage(image1.image, context);
    super.didChangeDependencies();
  }

  void setValue() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    debugPrint(connectivityResult.toString());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
    }
  }

  @override
  Widget build(BuildContext context) {
    // ImageProvider logo = AssetImage("assets/images/starter-image.jpg");
    return Scaffold(
      backgroundColor: BgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageViewoController,
                itemCount: onboardingModels.length,
                onPageChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (_, i) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        image2,
                        Text(
                          onboardingModels[i].title,
                          style: titleTextStyle(fontSize: 35),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          child: Text(
                            onboardingModels[i].body,
                            style: simpleTextStyle(
                                fontSize: 18, color: Colors.grey),
                            textAlign: TextAlign.justify,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingModels.length,
                  (index) => buildDots(index, context),
                ),
              ),
            ),
            Container(
              height: 60,
              margin: const EdgeInsets.only(
                  left: 40, right: 40, top: 30, bottom: 30),
              width: double.infinity,
              child: TextButton(
                child: Text(
                  currentIndex != onboardingModels.length - 1
                      ? "Continue"
                      : "Começar",
                ),
                onPressed: () {
                  if (currentIndex == onboardingModels.length - 1) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => App()));
                  }
                  _pageViewoController.nextPage(
                      duration: Duration(milliseconds: 100),
                      curve: Curves.bounceIn);
                },
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: PrimaryColor,
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
            )
          ],
        ),
      ),
    );
  }

  Container buildDots(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 25 : 10,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index ? PrimaryColor : Colors.grey,
      ),
    );
  }
}
