import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildHome extends StatefulWidget{

  @override
  _ChildHomeState createState() => _ChildHomeState();
}

String _serviceName = "";

class _ChildHomeState extends State<ChildHome>{

  _openServicesPage(value){
    getGenderPreferences()
        .then((gender){
          if(gender.isEmpty){
            _showGenderDialog();
          } else{
            setState(() {
              _serviceName = value;
            });
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChildServices()));
          }
        });
  }

  _showGenderDialog(){
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
                  onTap: () => savePreferences("male"),
                  child: new Image.asset(
                    "images/bluemale.png",
                    width: 100,
                    height: 100,
                  ),
                ),
                GestureDetector(
                  onTap: () => savePreferences("female"),
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

  Future<bool> savePreferences(gender) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userGender", gender);
    Navigator.pop(context);
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

Icon _icon = new Icon(Icons.add_circle_outline);
String _cartText = "Add to cart";

class _ChildServicesState extends State<ChildServices>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text(_serviceName + " Services"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0),
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Feathers",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w300
                      ),
                    ),
                    Text(
                      "Hair cutting",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w200
                      ),
                    ),
                  ],
                ),
                Text(
                  "200 ₹",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400
                  ),
                ),
                Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                           _icon = Icon(
                             Icons.check_circle,
                             color: Colors.green,
                           );
                           _cartText = "Added";
                        });
                      },
                      child: _icon),
                    Text(
                      _cartText,
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                )
              ],
            ),
            new Divider(),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Multi Layers",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w300
                      ),
                    ),
                    Text(
                      "Hair cutting",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w200
                      ),
                    ),
                  ],
                ),
                Text(
                  "250 ₹",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400
                  ),
                ),
                Column(
                  children: <Widget>[
                    _icon,
                    Text(
                      _cartText,
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                )
              ],
            ),
            new Divider(),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Steps",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w300
                      ),
                    ),
                    Text(
                      "Hair cutting",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w200
                      ),
                    ),
                  ],
                ),
                Text(
                  "200 ₹",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400
                  ),
                ),
                Column(
                  children: <Widget>[
                    Icon(Icons.add_circle_outline),
                    Text(
                      "Add to cart",
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                )
              ],
            ),
            new Divider(),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Normal",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w300
                      ),
                    ),
                    Text(
                      "Waxing",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w200
                      ),
                    ),
                  ],
                ),
                Text(
                  "150 ₹",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400
                  ),
                ),
                Column(
                  children: <Widget>[
                    Icon(Icons.add_circle_outline),
                    Text(
                      "Add to cart",
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        )
      ),
    );
  }
}