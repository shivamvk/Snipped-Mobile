import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/redirect_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

//The splashScreen for the app with only logo and a loader
//at the bottom. This screen calls the signupScreen for now.

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    //to give the status bar defind
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Color(0xff073748)
      )
    );

    return new MaterialApp(
      title: "Snipped",
      theme: new ThemeData(
        primaryColor: new Color(0xffff073848),
        primaryColorDark: new Color(0xff073848),
      ),
      debugShowCheckedModeBanner: false,
      home: new SplashScreen(
        seconds: 4,
        image: Image.asset(
          "images/brandlogowhite.png",
        ),
        photoSize: 100,
        title: new Text(""),
        backgroundColor: Color(0xff073848),
        loaderColor: Color(0xffff7100),
        styleTextUnderTheLoader: new TextStyle(
          color: Color(0xff073848)
        ),
        navigateAfterSeconds: new RedirectScreen()
      ),
    );
  }
}
