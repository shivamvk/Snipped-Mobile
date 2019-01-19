import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'home_screen.dart';

class RedirectScreen extends StatefulWidget{

  @override
  _RedirectScreenState createState() => _RedirectScreenState();
}

class _RedirectScreenState extends State<RedirectScreen>{

  @override
  void initState() {
    getNamePreferences().then((value) {
      if(value.isEmpty){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen())
        );
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen())
        );
      }
    });
    super.initState();
  }

  Future<String> getNamePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userName") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: new Color(0xffff073848),
    );
  }

}