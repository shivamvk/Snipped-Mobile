import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_screen.dart';
import 'package:snipped/models/Service.dart';
import 'address_bottom_sheet.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

List<String> _cartList = new List();
String _cartPrefString;
String _proceedBtnText = "";
final _couponController = new TextEditingController();
int _total = 0;

Future<String> getCartPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("cart") ?? "";
}

class _CartScreenState extends State<CartScreen> {

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  VoidCallback _showPersBottomSheetCallback;

  @override
  void initState() {
    getCartPreferences().then((value) {
      setState(() {
        _cartPrefString = value;
        _cartList.clear();
        List<String> list = value.split(",");
        for (int i = 0; i < list.length; i++) {
          if (list[i].length > 1) {
            _cartList.add(list[i]);
          }
        }
      });
    });

    _showPersBottomSheetCallback = _showAddressBottomSheet;

    super.initState();
  }

  void _showAddressBottomSheet() {
    setState(() {
      _showPersBottomSheetCallback = null;
    });

    _scaffoldKey.currentState
      .showBottomSheet(
        (context){
          return new Container(
            color: Colors.grey[300],
            height: MediaQuery.of(context).size.height * 0.75,
            child: new AddressBottomSheet(_total),
          );
        }
    ) .closed
      .whenComplete((){
        if(mounted){
          setState(() {
            _showPersBottomSheetCallback = _showAddressBottomSheet;
          });
        }
      });
  }

  Future<List<Service>> _getCartItemsById() async {
    String url =
        "http://13.251.185.41:8080/Snipped-0.0.1-SNAPSHOT/service/id/" +
            _cartPrefString;
    var data = await http.get(url);

    Response response = Response.fromJson(json.decode(data.body));

    List<Service> list = response.services;
    int total = 0;
    for (int i = 0; i < list.length; i++) {
      total += list[i].price;
    }
    setState(() {
      _total = total;
      _proceedBtnText = "Proceed (Total : ₹ " + total.toString() + ")";
    });
    list.add(Service());
    list.add(Service());
    return list;
  }

  _updateProceedBtnText(_snapshot){
    int total = 0;
    for(int i=0; i<_snapshot.length - 1; i++){
      if(_cartList.contains(_snapshot[i].id)){
        total +=_snapshot[i].price;
      }
    }
    setState(() {
      _total = total;
      _proceedBtnText = "Proceed (Total : ₹ " + total.toString() + ")";
    });
  }

  _updateCartPreferences(){
    String string = "";
    for(int i=0; i<_cartList.length; i++){
      string += _cartList[i] + ",";
    }
    savePreferences(string)
      .then((bool){
        setState(() {
          _cartPrefString = string;
        });
    });
  }

  Future<bool> savePreferences(cart) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("cart", cart);
    return prefs.commit();
  }

  _validateCouponCode(){
    String string = _couponController.text.toLowerCase();
    if(string == "new50"){
      int total = _total;
      if(total/2 <= 100){
        total = total - (total/2).toInt();
      } else{
        total = total - 100;
      }
      setState(() {
        _total = total;
        _proceedBtnText = "Proceed (Total : ₹ " + total.toString() + ")";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        },
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text("Cart"),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                color: Colors.white,
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                },
              ),
            ),
            body: (_cartList.isEmpty)
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset("images/emptycart.png"),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            "You don't have any items in your cart right now",
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ))
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 0.0, right: 0.0, bottom: 0.0),
                      child: FutureBuilder(
                        future: _getCartItemsById(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              itemCount: _cartList.length + 2,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == _cartList.length + 1) {
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 24.0, 8.0, 16.0),
                                    child: RaisedButton(
                                      elevation: 10.0,
                                      color: Color(0xff073848),
                                      textColor: Colors.white,
                                      onPressed: _showAddressBottomSheet,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 12.0, bottom: 12.0),
                                        child: Text(
                                          _proceedBtnText,
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ),
                                  );
                                } else if(index == _cartList.length){
                                  return Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: "Have a coupon code?",
                                        border: OutlineInputBorder(),
                                        suffix: GestureDetector(
                                          onTap: () => _validateCouponCode(),
                                          child: Icon(
                                            Icons.send,
                                            color: Colors.green,
                                          ),
                                        )
                                      ),
                                      cursorColor: Color(0xffff7100),
                                      textCapitalization: TextCapitalization.characters,
                                      controller: _couponController,
                                    ),
                                  );
                                }
                                if(_cartList.contains(snapshot.data[index].id)){
                                  return Column(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(bottom: 4.0, left: 8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  snapshot.data[index].name,
                                                  style: TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                      FontWeight.w300),
                                                ),
                                                Text(
                                                  snapshot
                                                      .data[index].subcategory,
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                      FontWeight.w200),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          right: 4.0),
                                                      child: Text(
                                                        "₹" +
                                                            " " +
                                                            snapshot.data[index]
                                                                .price
                                                                .toString(),
                                                        style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                            FontWeight
                                                                .w400),
                                                        textAlign:
                                                        TextAlign.right,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.delete),
                                                      color: Colors.red,
                                                      onPressed: () {
                                                        setState(() {
                                                          _cartList.remove(
                                                            snapshot.data[index].id
                                                          );
                                                          _updateProceedBtnText(
                                                            snapshot.data,
                                                          );
                                                          _updateCartPreferences();
                                                        });
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      new Divider()
                                    ],
                                  );
                                }
                              },
                            );
                          } else if (snapshot.hasError) {
                            return new Center(
                              child: new Text('Error: ${snapshot.error}'),
                            );
                          }
                          return new CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Color(0xffff7100)
                              )
                          );
                        },
                      ),
                    ),
                  )
        )
    );
  }
}
