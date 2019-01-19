import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
//The homeScreen for the app.

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name;
  String _email;
  String _phone;

  @override
  void initState() {
    getNamePreferences().then((value) {
      setState(() {
        _name = value;
      });
    });

    getPhonePreferences().then((value) {
      setState(() {
        _phone = value;
      });
    });

    getEmailPreferences().then((value) {
      setState(() {
        _email = value;
      });
    });
    super.initState();
  }

  Future<bool> savePreferences(name, email, phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userName", name);
    prefs.setString("userEmail", email);
    prefs.setString("userPhone", phone);
    return prefs.commit();
  }

  Future<String> getNamePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userName") ?? "";
  }

  Future<String> getPhonePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userPhone") ?? "";
  }

  Future<String> getEmailPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userEmail") ?? "";
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
    savePreferences("", "", "");
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
          children: <Widget>[
            new Text(_name),
            new RaisedButton(
              onPressed: _logout,
              child: new Text("Log out"),
            )
          ],
      ),
        )),
    );
  }
}
