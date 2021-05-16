import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:MrRecipe/pages/app.dart';
import 'package:MrRecipe/widgets/widget.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import '../models/onboarding_screen_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  ImageProvider logo =
      AssetImage("assets/images/splash_screen_images/healthy_recipe-min.jpg");
  int currentIndex = 0;
  bool isLoading = false;
  PageController _pageViewController;
  Image image1;
  Image image2;
  Image image3;

  @override
  void initState() {
    _pageViewController = PageController(initialPage: 0);
    setValue();
    super.initState();
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
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
    debugPrint(onboardingModels[1].image);
    return Scaffold(
      backgroundColor: BgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageViewController,
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
                      children: [
                        image(i),
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
                              fontSize: 18,
                              color: Colors.black54,
                              // fontWeight: FontWeight.bold,
                            ),
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
            !isLoading
                ? Container(
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
                          setState(() {
                            isLoading = true;
                          });
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => App(
                                        fromMain: true,
                                      )));
                        }
                        _pageViewController.nextPage(
                          duration: Duration(milliseconds: 100),
                          curve: Curves.bounceIn,
                        );
                      },
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: PrimaryColor,
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                    ),
                  )
                : CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(PrimaryColor),
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

  // loadImage(String imageString) {
  //   Uint8List image = Base64Decoder().convert(imageString);
  //   return Container(
  //     child: Image.memory(
  //       image,
  //       fit: BoxFit.cover,
  //     ),
  //   );
  // }

  // Image backgroundImage;

  // Future<void> loadImage(ImageProvider provider) {
  //   final config = ImageConfiguration(
  //     bundle: rootBundle,
  //     devicePixelRatio: 1,
  //     platform: defaultTargetPlatform,
  //   );
  //   final Completer<void> completer = Completer();
  //   final ImageStream stream = provider.resolve(config);

  //   ImageStreamListener listener;

  //   listener = ImageStreamListener((ImageInfo image, bool sync) {
  //     debugPrint("Image ${image.debugLabel} finished loading");
  //     completer.complete();
  //     stream.removeListener(listener);
  //   }, onError: (dynamic exception, StackTrace stackTrace) {
  //     completer.complete();
  //     stream.removeListener(listener);
  //     FlutterError.reportError(FlutterErrorDetails(
  //       context: ErrorDescription('image failed to load'),
  //       library: 'image resource service',
  //       exception: exception,
  //       stack: stackTrace,
  //       silent: true,
  //     ));
  //   });

  //   stream.addListener(listener);
  //   return completer.future;
  // }

  Widget image(int i) {
    final double height = MediaQuery.of(context).size.height / 2.5;
    switch (i) {
      case 0:
        return SvgPicture.asset(
          onboardingModels[i].image,
          height: height,
        );
        break;
      case 1:
        return SvgPicture.asset(
          onboardingModels[i].image,
          height: height,
        );
        break;
      case 2:
        return Image.asset(
          onboardingModels[i].image,
          height: height,
        );
        break;
      default:
        return null;
    }
  }
}
