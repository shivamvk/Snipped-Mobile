import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipped/transitions/slide_rtl.dart';
import 'orders_screen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'login_screen.dart';
import 'home_screen_children/home.dart';
import 'home_screen_children/faq.dart';
import 'cart_screen.dart';
import 'package:snipped/models/Order.dart';
//The homeScreen for the app.

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

String _name;
String _email;
String _phone;
List<String> _cartList = new List();

bool _isConnectedToInternet;

var _currentIndex = 0;

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
final FlutterLocalNotificationsPlugin localNotificationsPlugin = new FlutterLocalNotificationsPlugin();

final List<Widget> _drawerChildren = [
  new Container(
    color: Colors.white,
    child: new ChildHome(),
  ),
  new Container(
    color: Colors.white,
    child: new ChildFaq(),
  ),
];

String _notificationTitle;
String _notificationText;

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {

    var initializationSettingsAndroid = new AndroidInitializationSettings('brandlogonotification');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    localNotificationsPlugin.initialize(initializationSettings);

    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.subscribeToTopic("offers");
    _firebaseMessaging.subscribeToTopic("miscellaneous");

    _firebaseMessaging.configure(
      onMessage: (notification){
        setState(() {
          print("on message called ${(notification)}");
          _notificationTitle = notification['notification']['title'];
          _notificationText = notification['notification']['body'];
        });
        _showNotification();
      }
    );

    getNamePreferences().then((value) {
      setState(() {
        _name = value;
      });
    });

    getPhonePreferences().then((value) {
      setState(() {
        _phone = value;
      });
      getOrdersList()
          .then((value){
        subscribeToTopics(value);
      });
    });

    getEmailPreferences().then((value) {
      setState(() {
        _email = value;
      });
    });

    getCartPreferences().then((value){
      setState(() {
        _cartList.clear();
        List<String> list = value.split(",");
        for(int i=0; i<list.length; i++){
          if(list[i].length > 1){
            _cartList.add(list[i]);
          }
        }
      });
    });

    _isConnected();
    super.initState();
  }

  subscribeToTopics(List<Order> value){
    String string = "";
    for(int i=0; i<value.length; i++){
      _firebaseMessaging.subscribeToTopic(value[i].id);
      string = string + value[i].id + ",";
    }
    saveFirebaseNotificationsSubscription(string)
      .then((value){
        return value;
    });
  }

  Future<bool> saveFirebaseNotificationsSubscription(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();;
    prefs.setString("subscription", value);
    return prefs.commit();
  }

  Future<List<Order>> getOrdersList() async{
    print("url called is ${(_phone)}");
    var data = await http.get("http://3.0.235.136:8080/Snipped-0.0.1-SNAPSHOT/order/" + _phone);
    Response response = Response.fromJson(json.decode(data.body));
    return response.orders;
  }

  _showNotification() async{
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '0', 'Micellaneous', 'General notifications',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await localNotificationsPlugin.show(
        0, _notificationTitle,
        _notificationText , platformChannelSpecifics);
  }

  Future<void> _isConnected() async {
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

  Future<bool> savePreferences(name, email, phone, cart) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userName", name);
    prefs.setString("userEmail", email);
    prefs.setString("userPhone", phone);
    prefs.setString("cart", cart);
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

  Future<String> getCartPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("cart") ?? "";
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
    savePreferences("", "", "", "");
    getFirebaseNotificationsSubscription()
      .then((value){
        unsubscribe(value);
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  unsubscribe(value){
    List<String> list = value.toString().split(",");
    for(int i=0; i<list.length; i++){
      if(list[i].length > 1){
        _firebaseMessaging.unsubscribeFromTopic(list[i]);
      }
    }
  }

  Future<String> getFirebaseNotificationsSubscription() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("subscription") ?? "";
  }

  void _onDrawerTapped(value) {
    Navigator.pop(context);
    switch (value) {
      case "home":
        setState(() {
          _currentIndex = 0;
        });
        break;
      case "orders":
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OrdersScreen()),
          );
        break;
      case "faq":
        setState(() {
          _currentIndex = 1;
        });
        break;
      case "logout":
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return new AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                title: Text("Are you sure you want to log out?"),
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
            });
          break;
      case "privacy":
        const url = "https://shivamvk.github.io/privacy_policy.html";
        launch(url);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: new Image.asset(
            "images/brandlogoappbar.png",
            width: 100,
            height: 40,
          ),
        ),
        actions: <Widget>[
          new Padding(
            padding: const EdgeInsets.all(10.0),
            child: new Container(
                height: 150.0,
                width: 30.0,
                child: new Stack(
                  children: <Widget>[
                    new IconButton(
                      icon: new Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      ),
                      onPressed: (){
                        Navigator.pushReplacement(
                          context,
                          SlideRTL(widget: CartScreen())
                        );
                      }
                    ),
                (_cartList.isEmpty)
                        ? new Container()
                        : new Positioned(
                            child: new Stack(
                            children: <Widget>[
                              new Icon(Icons.brightness_1,
                                  size: 20.0, color: Color(0xffff7100)),
                              new Positioned(
                                  top: 4.0,
                                  right: 5.0,
                                  child: new Center(
                                    child: new Text(
                                      _cartList.length.toString(),
                                      style: new TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )),
                            ],
                          )),
                  ],
                )),
          )
        ],
      ),
      drawer: new Drawer(
        child: new ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text((_name == null) ? "Account name" : _name),
              accountEmail:
                  new Text((_email == null) ? "Account email" : _email),
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
                onTap: () => _onDrawerTapped("orders")),
            new Divider(),
            new ListTile(
              title: new Text("Help and support"),
              trailing: new Icon(Icons.arrow_forward_ios),
              onTap: () => _onDrawerTapped("faq"),
            ),
            new ListTile(
              title: new Text("Log out"),
              trailing: new Icon(Icons.arrow_forward_ios),
              onTap: () => _onDrawerTapped("logout"),
            ),
            new Divider(),
            new ListTile(
              title: new Text("Privacy Policy"),
              trailing: new Icon(Icons.arrow_forward_ios),
              onTap: () => _onDrawerTapped("privacy"),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 0.0, 32.0),
              child: new Text("V 1.1.3"),
            )
          ],
        ),
      ),
      body: _isConnectedToInternet
          ? _drawerChildren[_currentIndex]
          : new Column(
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
