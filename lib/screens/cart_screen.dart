import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:progress_hud/progress_hud.dart';
import 'package:snipped/transitions/slide_ltr.dart';

import 'home_screen.dart';
import 'package:snipped/models/Service.dart';
import 'address_bottom_sheet.dart';
import 'package:snipped/models/Order.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

List<String> _cartList = new List();
List<String> _showDetailsList = new List();
String _cartPrefString;
String _proceedBtnText = "";
final _couponController = new TextEditingController();
int _total = 0;
int _discount = 0;
bool _couponError = false;
String _couponErrorText = "";

ProgressHUD _progressHUD;
bool _loading = false;
List<Order> _orders;

class _CartScreenState extends State<CartScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  VoidCallback _showPersBottomSheetCallback;

  @override
  void initState() {
    _loading = false;

    _progressHUD = new ProgressHUD(
      backgroundColor: Colors.black12,
      color: Color(0xffff7100),
      containerColor: Color(0xff073848),
      borderRadius: 5.0,
    );

    _couponError = false;
    _couponErrorText = "";
    _couponController.text = "";
    _discount = 0;

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

    getPhonePreferences().then((value) {
      _getOrdersList(value).then((orders) {
        _orders = orders;
      });
    });

    _showPersBottomSheetCallback = _showAddressBottomSheet;

    super.initState();
  }

  Future<String> getCartPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("cart") ?? "";
  }

  Future<String> getPhonePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userPhone") ?? "";
  }

  void _showAddressBottomSheet() {
    setState(() {
      _showPersBottomSheetCallback = null;
    });

    _scaffoldKey.currentState
        .showBottomSheet((context) {
          return new Container(
            color: Colors.grey[300],
            height: MediaQuery.of(context).size.height * 0.75,
            child: new AddressBottomSheet(
                _total, _cartList, _couponController.text),
          );
        })
        .closed
        .whenComplete(() {
          if (mounted) {
            setState(() {
              _showPersBottomSheetCallback = _showAddressBottomSheet;
            });
          }
        });
  }

  Future<List<Service>> _getCartItemsById() async {
    String url = "http://3.0.235.136:8080/Snipped-0.0.1-SNAPSHOT/service/id/" +
        _cartPrefString;
    var data = await http.get(url);

    ServiceResponse response = ServiceResponse.fromJson(json.decode(data.body));

    List<Service> list = response.services;
    int total = 0;
    for (int i = 0; i < list.length; i++) {
      total += list[i].price;
    }

    list.add(Service());
    list.add(Service());

    setState(() {
      _total = total - _discount;
      _proceedBtnText = "Proceed (Total : ₹ " + _total.toString() + ")";
    });
    return list;
  }

  _updateProceedBtnText(_snapshot) {
    int total = 0;
    for (int i = 0; i < _snapshot.length - 1; i++) {
      if (_cartList.contains(_snapshot[i].id)) {
        total += _snapshot[i].price;
      }
    }
    setState(() {
      _total = total - _discount;
      _proceedBtnText = "Proceed (Total : ₹ " + _total.toString() + ")";
    });
  }

  _updateCartPreferences() {
    String string = "";
    for (int i = 0; i < _cartList.length; i++) {
      string += _cartList[i] + ",";
    }
    savePreferences(string).then((bool) {
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

  _validateCouponCode() {
    String string = _couponController.text.toLowerCase();
    if (_orders.length != 0 && string == "new15") {
      setState(() {
        _couponError = true;
        _couponErrorText = "This coupon is valid only on first order!";
      });
      return;
    }
    if (string == "new15") {
      setState(() {
        _couponError = true;
        _couponErrorText = "Coupon applied successfully!";
      });
      if ((15.0 * (_total / 100)) <= 100) {
        setState(() {
          _discount = (15.0 * (_total / 100)).toInt();
        });
      } else {
        setState(() {
          _discount = 100;
        });
      }
    } else {
      _couponError = true;
      _couponErrorText = "Invalid coupon!";
    }
  }

  Future<List<Order>> _getOrdersList(_phone) async {
    String url =
        "http://3.0.235.136:8080/Snipped-0.0.1-SNAPSHOT/order/" + _phone;
    var data = await http.get(url);

    Response response = Response.fromJson(json.decode(data.body));
    return response.orders;
  }

  _showDeleteConfirmationDialog(value, list) {
    AlertDialog _deleteDialog = new AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      contentPadding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      title: Text("Are you sure you want to remove this item from your cart?"),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        FlatButton(
          onPressed: () {
            setState(() {
              _cartList.remove(value);
              _updateProceedBtnText(list);
              _updateCartPreferences();
            });
            Navigator.pop(context);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => CartScreen()));
          },
          child: Text("Yeah"),
        )
      ],
    );

    showDialog(
        context: context, builder: (BuildContext context) => _deleteDialog);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pushReplacement(context, SlideLTR(widget: HomeScreen()));
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            key: _scaffoldKey,
            appBar: AppBar(
              elevation: 0.0,
              title: Text("Cart"),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                color: Colors.black,
                onPressed: () {
                  Navigator.pushReplacement(
                      context, SlideLTR(widget: HomeScreen()));
                },
              ),
            ),
            body: (_cartList.isEmpty)
                ? SingleChildScrollView(
                    child: Center(
                        child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 32.0),
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
                    )),
                  )
                : (_loading)
                    ? _progressHUD
                    : Center(
                        child: FutureBuilder(
                          future: _getCartItemsById(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                itemCount: _cartList.length + 2,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == _cartList.length) {
                                    return Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextField(
                                        onChanged: (value) {
                                          _couponError = false;
                                          _couponErrorText = "";
                                        },
                                        enabled: (_couponErrorText ==
                                                "Coupon applied successfully!")
                                            ? false
                                            : true,
                                        decoration: InputDecoration(
                                            labelText: "Have a coupon code?",
                                            border: OutlineInputBorder(),
                                            focusedBorder: UnderlineInputBorder(),
                                            errorText: _couponError
                                                ? _couponErrorText
                                                : null,
                                            errorStyle: TextStyle(
                                                color: Color(0xff073848)),
                                            suffix: (_discount == 0)
                                                ? GestureDetector(
                                                    onTap: () =>
                                                        _validateCouponCode(),
                                                    child: Icon(
                                                      Icons.send,
                                                      color: Colors.green,
                                                    ),
                                                  )
                                                : new Container(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          _discount = 0;
                                                          _couponController
                                                              .text = "";
                                                          _couponError = true;
                                                          _couponErrorText =
                                                              "Coupon removed successfully!";
                                                        });
                                                      },
                                                      child: Icon(
                                                        Icons.clear,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  )),
                                        cursorColor: Color(0xffff7100),
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        controller: _couponController,
                                      ),
                                    );
                                  }
                                  if (index == _cartList.length + 1) {
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 24.0, 8.0, 16.0),
                                      child: RaisedButton(
                                        elevation: 0.0,
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
                                  }
                                  if (_cartList
                                      .contains(snapshot.data[index].id)) {
                                    return Dismissible(
                                      key: Key(snapshot.data[index].id),
                                      background: Container(
                                        color: Colors.red,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Icon(Icons.delete_sweep, size: 40.0,),
                                              Icon(Icons.delete_sweep, size: 40.0,)
                                            ],
                                          ),
                                        )
                                      ),
                                      onDismissed: (direction){
                                        _cartList.remove(snapshot.data[index].id);
                                        _updateProceedBtnText(snapshot.data);
                                        _updateCartPreferences();
                                        Navigator.pushReplacement(
                                            context, MaterialPageRoute(builder: (context) => CartScreen()));
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4.0, bottom: 4.0, left: 8.0),
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
                                                      snapshot.data[index]
                                                          .subcategory,
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.w200),
                                                    ),
                                                    Padding(
                                                        padding: EdgeInsets.only(
                                                            top: 4.0)),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.50,
                                                      child: Text(
                                                        snapshot.data[index]
                                                            .description,
                                                        style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w300),
                                                      ),
                                                    )
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
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 4.0),
                                                          child: Text(
                                                            "₹" +
                                                                " " +
                                                                snapshot
                                                                    .data[index]
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
                                                          icon:
                                                              Icon(Icons.delete),
                                                          color: Colors.red,
                                                          onPressed: () {
                                                            _showDeleteConfirmationDialog(
                                                                snapshot
                                                                    .data[index]
                                                                    .id,
                                                                snapshot.data);
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
                                      ),
                                    );
                                  }
                                },
                              );
                            } else if (snapshot.hasError) {
                              return new Center(
                                child: new Text('Error: ${snapshot.error}'),
                              );
                            }
                            return Center(
                              child: new CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Color(0xffff7100))),
                            );
                          },
                        ),
                      )));
  }
}
