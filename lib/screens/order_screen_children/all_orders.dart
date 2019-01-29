import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:snipped/models/Order.dart';

class AllOrders extends StatefulWidget {
  @override
  _AllOrdersState createState() => _AllOrdersState();
}

String _phone;
List<Order> _orders;
DateTime _date;
String strDate;

class _AllOrdersState extends State<AllOrders> {
  @override
  void initState() {
    getPhonePreferences().then((value) {
      _phone = value;
    });
    _date = DateTime.now();
    strDate = _date.day.toString() + "-" + _date.month.toString() + "-" + _date.year.toString();
    super.initState();
  }

  Future<String> getPhonePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userPhone") ?? "";
  }

  Future<List<Order>> _getAllOrders() async {
    print("url called 2 is ${(_phone)}");
    String url =
        "http://3.0.235.136:8080/Snipped-0.0.1-SNAPSHOT/order/" + _phone;
    var data = await http.get(url);
    Response response = Response.fromJson(json.decode(data.body));
    return response.orders;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: _getAllOrders(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  height: MediaQuery.of(context).size.height * 0.40,
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.90,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Order id: "),
                              Text(snapshot.data[index].id)
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.90,
                          height: 50.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  Text("Confirmed")
                                ],
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.10,
                                height: 2.0,
                                color: Colors.grey[200],
                                margin: EdgeInsets.only(left: 8.0, right: 8.0),
                              ),
                              (strDate == snapshot.data[index].appointmentDate)?
                              Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  Text("Processed")
                                ],
                              )
                              : Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.watch_later,
                                  ),
                                  Text("Processing")
                                ],
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.10,
                                height: 2.0,
                                color: Colors.grey[200],
                                margin: EdgeInsets.only(left: 8.0, right: 8.0),
                              ),
                              (snapshot.data[index].status == "Completed")?
                              Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  Text("Completed")
                                ],
                              )
                                  : new Container() ,
                              (snapshot.data[index].status == "Pending")?
                              Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.watch_later,
                                  ),
                                  Text("Completed")
                                ],
                              )
                                  : new Container() ,
                              (snapshot.data[index].status == "Cancelled")?
                              Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                  Text("Cancelled")
                                ],
                              )
                                  : new Container() ,
                            ],
                          )
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Color(0xffff7100)),
            );
          }
        },
      ),
    );
  }
}
