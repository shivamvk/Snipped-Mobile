import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'login_screen.dart';
import 'home_screen_children/home.dart';
import 'home_screen_children/orders.dart';
//The homeScreen for the app.

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

String _name;
String _email;
String _phone;

bool _isConnectedToInternet;

var _currentIndex = 0;

final List<Widget> _drawerChildren = [
  new Container(
    color: Colors.white,
    child: new ChildHome(),
  ),
  new Container(
    color: Colors.white,
    child: new ChildOrders(),
  )
];

class _HomeScreenState extends State<HomeScreen> {

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

    _isConnected();
    super.initState();
  }

  Future<void> _isConnected() async{
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      setState(() {
        _isConnectedToInternet = true;
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        _isConnectedToInternet = true;
      });
    } else if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnectedToInternet = false;
      });
    }
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

  void _onDrawerTapped(value){
    Navigator.pop(context);
    switch(value){
      case "home": setState(() {
          _currentIndex = 0;
        });
        break;
      case "orders": setState(() {
          _currentIndex = 1;
        });
        break;
      case "logout": showDialog(
          context: context,
          builder: (BuildContext context){
            return new AlertDialog(
              content: new Text(
                  'Are you sure you want to log out?'
              ),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: new Text('Cancel'),
                ),
                new FlatButton(
                  onPressed: () {
                    _logout();
                  },
                  child: new Text('Yes'),
                )
              ],
            );
          }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text("Snipped"),
        centerTitle: true,
      ),
      drawer: new Drawer(
        child: new ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text((_name == null)? "Account name" : _name),
              accountEmail: new Text((_email == null)? "Account email" : _email),
              currentAccountPicture: new CircleAvatar(
                backgroundColor: Colors.white,
                child: new Text((_name == null) ? "hey" : _name[0]),
              ),
            ),
            new ListTile(
              title: new Text("Home"),
              trailing: new Icon(Icons.arrow_forward_ios),
              onTap: () => _onDrawerTapped("home"),
            ),
            new ListTile(
              title: new Text("My Orders"),
              trailing: new Icon(Icons.arrow_forward_ios),
              onTap: () => _onDrawerTapped("orders")
            ),
            new Divider(),
            new ListTile(
              title: new Text("About us"),
              trailing: new Icon(Icons.arrow_forward_ios),
              onTap: () => _onDrawerTapped("about"),
            ),
            new ListTile(
              title: new Text("Contact us"),
              trailing: new Icon(Icons.arrow_forward_ios),
              onTap: () => _onDrawerTapped("contact"),
            ),
            new Divider(),
            new ListTile(
              title: new Text("Settings"),
              trailing: new Icon(Icons.arrow_forward_ios),
              onTap: () => _onDrawerTapped("settings")
            ),
            new ListTile(
              title: new Text("Log out"),
              trailing: new Icon(Icons.arrow_forward_ios),
              onTap: () => _onDrawerTapped("logout"),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 0.0, 0.0),
              child: new Text("v1.0"),
            )
          ],
        ),
      ),
      body: _isConnectedToInternet? _drawerChildren[_currentIndex] : new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Text(
              "Seems like you are low on network! Please connect to internet and try again!",
              textAlign: TextAlign.center,
            ),
          ),
          new RaisedButton(
            onPressed: _isConnected,
            color: Color(0xffff073848),
            textColor: Colors.white,
            elevation: 5.0,
            child: new Text("Try again"),
          )
        ],
      ),
    );
  }
}
