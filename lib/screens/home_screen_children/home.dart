import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildHome extends StatefulWidget{

  @override
  _ChildHomeState createState() => _ChildHomeState();
}

bool _genderPreferenceGiven = false;
String _genderText = "Proceed";

class _ChildHomeState extends State<ChildHome>{

  _openServicesPage(value){
    getGenderPreferences()
        .then((gender){
          if(gender.isEmpty){
            _showGenderDialog();
          } else{

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
                new Icon(
                  Icons.arrow_forward_ios,
                  size: 100,
                  color: Colors.blue,
                ),
                new Icon(
                  Icons.arrow_back_ios,
                  size: 100,
                  color: Colors.pinkAccent,
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
                        onTap:() => _openServicesPage("hair"),
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
                        onTap: () => _openServicesPage("beauty"),
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
                        onTap: () => _openServicesPage("makeup"),
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
                        onTap: () =>_openServicesPage("others"),
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