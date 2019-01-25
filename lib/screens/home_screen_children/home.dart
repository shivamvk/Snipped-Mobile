import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipped/screens/home_screen.dart';

//imports for childService;
import 'package:snipped/models/Service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:snipped/screens/cart_screen.dart';

class ChildHome extends StatefulWidget{

  @override
  _ChildHomeState createState() => _ChildHomeState();
}

String _serviceName = "";

class _ChildHomeState extends State<ChildHome>{

  _openServicesPage(value){
    _showGenderDialog(value);
  }

  _showGenderDialog(value){
    AlertDialog _genderDialog = new AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      contentPadding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Please select a gender!",
                style: TextStyle(
                  color: Colors.black,

                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Divider(
              color: Colors.grey,
              height: 4.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () => savePreferences("male", value),
                  child: new Image.asset(
                    "images/bluemale.png",
                    width: 100,
                    height: 100,
                  ),
                ),
                GestureDetector(
                  onTap: () => savePreferences("female", value),
                  child: new Image.asset(
                    "images/pinkfemale.png",
                    width: 100,
                    height: 100,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) => _genderDialog
    );
  }

  Future<String> getGenderPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userGender") ?? "";
  }

  Future<bool> savePreferences(gender, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userGender", gender);
    Navigator.pop(context);
    setState(() {
      _serviceName = value;
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChildServices()));
    return prefs.commit();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: new Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new SizedBox(
                height: MediaQuery.of(context).size.height * 0.30,
                width: MediaQuery.of(context).size.width,
                child: new Carousel(
                  images: [
                    new NetworkImage('https://res.cloudinary.com/cdnsnipped/image/upload/v1547966865/app_slider_1.jpg'),
                    new NetworkImage('https://res.cloudinary.com/cdnsnipped/image/upload/v1547966872/app_slider_2.jpg'),
                    new NetworkImage('https://res.cloudinary.com/cdnsnipped/image/upload/v1547966865/app_slider_1.jpg'),
                    new NetworkImage('https://res.cloudinary.com/cdnsnipped/image/upload/v1547966872/app_slider_2.jpg'),
                    new NetworkImage('https://res.cloudinary.com/cdnsnipped/image/upload/v1547966865/app_slider_1.jpg'),
                  ],
                  dotSize: 0,
                  dotBgColor: Colors.white.withOpacity(0.0),
                  autoplayDuration: Duration(seconds: 6),
                  animationCurve: Curves.fastOutSlowIn,
                  borderRadius: true,
                )
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Text(
              "Categories",
              style: new TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700
              ),
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5.0,
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap:() => _openServicesPage("Hair"),
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.43,
                            child: Center(
                                child: new Image.asset(
                                  "images/hair.jpg",
                                )
                            )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Text("Hair"),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5.0,
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => _openServicesPage("Beauty"),
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.43,
                            child: Center(
                                child: new Image.asset(
                                  "images/facial.jpg",
                                )
                            )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Text("Beauty"),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5.0,
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => _openServicesPage("Makeup"),
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.43,
                            child: Center(
                                child: new Image.asset(
                                    "images/makeup.jpg"
                                )
                            )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Text("Make up"),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5.0,
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () =>_openServicesPage("Others"),
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.43,
                            child: Center(
                                child: new Image.asset(
                                    "images/facial.jpg"
                                )
                            ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Text("Others"),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

}

//above this line is the childhome class
//and below this is childservice class

class ChildServices extends StatefulWidget{
  
  @override
  _ChildServicesState createState() => _ChildServicesState();
}

Icon _iconAddToCart = new Icon(
  Icons.add_circle_outline,
);
Text _textAddToCart = Text(
  "Add to cart",
  style: TextStyle(
    fontSize: 12.0,
  ),
);
Icon _iconAddedToCart = new Icon(
  Icons.check_circle,
  color: Colors.green,
);
Text _textAddedToCart = Text(
  "Added to cart",
  style: TextStyle(

    fontSize: 12.0,
    color: Colors.green
  ),
);

List<String> cart = new List();
String _cartPrefString = "";

Future<Response> _getServicesList() async{
  String url =
      "http://3.0.235.136:8080/Snipped-0.0.1-SNAPSHOT/service/" + _serviceName.toLowerCase();

  var data = await http.get(url);

  return Response.fromJson(json.decode(data.body));
}

//value is the id of the service to be removed
//flag=0 means remove the service
//flag=1 means add the service
_updateCartSharedPref(value, flag){
  _cartPrefString = "";
  for(int i=0; i<cart.length; i++){
    _cartPrefString = _cartPrefString + cart[i] + ",";
  }
  saveCartPreferences(_cartPrefString);
}

Future<bool> saveCartPreferences(value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("cart", value);
  return prefs.commit();
}

Future<String> getCartPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("cart") ?? "";
}

class _ChildServicesState extends State<ChildServices>{

  @override
  void initState() {
    getCartPreferences()
      .then((value){
        cart = value.split(",");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      },
      child: Scaffold(
        appBar: AppBar(
          title: new Text(_serviceName + " Services"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
            },
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 13,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Center(
                        child: FutureBuilder(
                          future: _getServicesList(),
                          builder: (BuildContext context, AsyncSnapshot snapshot){
                            if(snapshot.hasData){
                              return new ListView.builder(
                                itemCount: snapshot.data.services.length,
                                itemBuilder: (BuildContext context, int index){
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 4.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    snapshot.data.services[index].name,
                                                    style: TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight: FontWeight.w300
                                                    ),
                                                  ),
                                                  Text(
                                                    snapshot.data.services[index].subcategory,
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight: FontWeight.w200
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  GestureDetector(
                                                      onTap: (){
                                                        setState(() {
                                                          if(cart.contains(snapshot.data.services[index].id)){
                                                            cart.remove(snapshot.data.services[index].id);
                                                            //0 means remove this id from cart shared prefs
                                                            _updateCartSharedPref(snapshot.data.services[index].id, 0);
                                                          } else {
                                                            cart.add(snapshot.data.services[index].id);
                                                            //1 means add this id to cart shared prefs
                                                            _updateCartSharedPref(snapshot.data.services[index].id, 1);
                                                          }
                                                        });
                                                      },
                                                      child: Row(
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: const EdgeInsets.only(right: 4.0),
                                                            child: Text(
                                                              "₹" + " "  + snapshot.data.services[index].price.toString(),
                                                              style: TextStyle(
                                                                  fontSize: 14.0,
                                                                  fontWeight: FontWeight.w400
                                                              ),
                                                              textAlign: TextAlign.right,
                                                            ),
                                                          ),
                                                          (cart.contains(snapshot.data.services[index].id))?
                                                          _iconAddedToCart : _iconAddToCart,
                                                        ],
                                                      )
                                                  ),
                                                  (cart.contains(snapshot.data.services[index].id))?
                                                  _textAddedToCart : _textAddToCart
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        new Divider()
                                      ],
                                    ),
                                  );
                                },
                              );
                            } else if(snapshot.hasError){
                              return new Center(
                                child: new Text('Error: ${snapshot.error}'),
                              );
                            }
                            return new CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(Color(0xffff7100))
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              onPressed: (){
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomeScreen()),
                                );
                              },
                              elevation: 5.0,
                              color: Color(0xff205161),
                              textColor: Colors.white,
                              child: Text(
                                "See more services",
                                style: TextStyle(
                                    fontSize: 16.0
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: RaisedButton(
                              onPressed: (){
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => CartScreen()),
                                );
                              },
                              elevation: 5.0,
                              color: Color(0xff073848),
                              textColor: Colors.white,
                              child: Text(
                                "Go to cart",
                                style: TextStyle(
                                    fontSize: 16.0
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                  )
                ],
              ),
            )
        ),
      ),
    );
  }
}

/*

 */

/*
FutureBuilder(
              future: _getServicesList(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.hasData){
                  return new ListView.builder(
                    itemCount: snapshot.data.services.length,
                    itemBuilder: (BuildContext context, int index){
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      snapshot.data.services[index].name,
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w300
                                      ),
                                    ),
                                    Text(
                                      snapshot.data.services[index].subcategory,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w200
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          if(cart.contains(snapshot.data.services[index].id)){
                                            cart.remove(snapshot.data.services[index].id);
                                            //0 means remove this id from cart shared prefs
                                            _updateCartSharedPref(snapshot.data.services[index].id, 0);
                                          } else {
                                            cart.add(snapshot.data.services[index].id);
                                            //1 means add this id to cart shared prefs
                                            _updateCartSharedPref(snapshot.data.services[index].id, 1);
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(right: 4.0),
                                            child: Text(
                                              "₹" + " "  + snapshot.data.services[index].price.toString(),
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          (cart.contains(snapshot.data.services[index].id))?
                                            _iconAddedToCart : _iconAddToCart,
                                        ],
                                      )
                                    ),
                                    (cart.contains(snapshot.data.services[index].id))?
                                    _textAddedToCart : _textAddToCart
                                  ],
                                )
                              ],
                            ),
                          ),
                          new Divider()
                        ],
                      );
                    },
                  );
                } else if(snapshot.hasError){
                  return new Center(
                    child: new Text('Error: ${snapshot.error}'),
                  );
                }
                return new CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Color(0xffff7100))
                );
              },
            ),
 */
