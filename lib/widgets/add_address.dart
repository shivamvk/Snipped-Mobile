import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:snipped/screens/cart_screen.dart';
import 'package:snipped/screens/home_screen.dart';
import 'package:snipped/screens/home_screen_children/account.dart';
import 'dart:async';
import 'dart:convert';

import 'package:snipped/transitions/slide_ltr.dart';


class AddAddressBottomSheet extends StatefulWidget{

  final String phone;
  final String calledfrom;

  AddAddressBottomSheet({
    this.phone,
    this.calledfrom
  });

  @override
  _AddAddressBottomSheetState createState() => _AddAddressBottomSheetState();
}

class _AddAddressBottomSheetState extends State<AddAddressBottomSheet>{

  final _pinCodeController = TextEditingController();
  final _flatController = TextEditingController();
  final _cityController = TextEditingController();
  final _colonyController = TextEditingController();

  bool _pinCodeError = false;
  bool _flatError = false;
  bool _cityError = false;
  bool _colonyError = false;

  bool _maxError = false;

  bool _isRefreshing = false;

  _validateInputs() {
    String pincode = _pinCodeController.text;
    String flat = _flatController.text;
    String colony = _colonyController.text;
    String city = _cityController.text;

    if (pincode.isEmpty) {
      setState(() {
        _pinCodeError = true;
      });
      return;
    }

    if (pincode.length != 6) {
      setState(() {
        _pinCodeError = true;
      });
      return;
    }

    if (flat.isEmpty) {
      setState(() {
        _flatError = true;
      });
      return;
    }

    if (colony.isEmpty) {
      setState(() {
        _colonyError = true;
      });
      return;
    }

    if (city.isEmpty) {
      setState(() {
        _cityError = true;
      });
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    saveAddress(pincode, flat, colony, city)
      .then((value){
        if(value == "error"){
          setState(() {
            _isRefreshing = false;
            _maxError = true;
          });
        } else {
          Navigator.pushReplacement(
              context,
              SlideLTR(widget: (widget.calledfrom == "cart")? CartScreen() : HomeScreen())
          );
        }
    });

  }

  Future<String> saveAddress(pincode, flat, colony, city) async {
    String url = "http://3.0.235.136:8080/Snipped-0.0.1-SNAPSHOT/address";
    Map<String,String> map = {
      "user" : widget.phone,
      "pincode" : pincode,
      "flat" : flat,
      "colony" : colony,
      "city" : city
    };
    var data = await http.post(url, body: map);
    return data.body;
  }

  @override
  void initState() {
    _cityController.text = "Lucknow";
    _isRefreshing = false;
    _maxError = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        Navigator.pushReplacement(
            context,
            SlideLTR(widget: (widget.calledfrom == "cart")? CartScreen() : HomeScreen())
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Add Address"),
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.black,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                  SlideLTR(widget: (widget.calledfrom == "cart")? CartScreen() : HomeScreen())
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                      labelText: "6 Digits(0-9) Pin Code",
                      labelStyle: new TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300
                      ),
                      errorText: _pinCodeError? "Enter a valid pin code" : null
                  ),
                  keyboardType: TextInputType.number,
                  cursorColor: new Color(0xffff7100),
                  style: new TextStyle(
                    color: Colors.black,
                  ),
                  controller: _pinCodeController,
                  onChanged: (value){
                    if(value.length != 6){
                      setState(() {
                        _pinCodeError = true;
                      });
                    } else if(value.length == 6) {
                      setState(() {
                        _pinCodeError = false;
                      });
                    }
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: "Flat / House no. / Floor/ Building",
                      labelStyle: new TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300
                      ),
                      errorText: _flatError? "This field is required!" : null
                  ),
                  keyboardType: TextInputType.text,
                  cursorColor: new Color(0xffff7100),
                  style: new TextStyle(
                      color: Colors.black
                  ),
                  controller: _flatController,
                  onChanged: (value){
                    setState(() {
                      _flatError = false;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: "Colony / Street / Locality",
                      labelStyle: new TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300
                      ),
                      errorText: _colonyError? "This field is required!" : null
                  ),
                  keyboardType: TextInputType.text,
                  cursorColor: new Color(0xffff7100),
                  style: new TextStyle(
                      color: Colors.black
                  ),
                  controller: _colonyController,
                  onChanged: (value){
                    setState(() {
                      _colonyError = false;
                    });
                  },
                ),
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                      labelText: "City",
                      labelStyle: new TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300
                      ),
                      errorText: "Currently we serve only in Lucknow!",
                      errorStyle: TextStyle(
                          color: Color(0xffff7100)
                      )
                  ),
                  keyboardType: TextInputType.text,
                  cursorColor: new Color(0xffff7100),
                  style: new TextStyle(
                      color: Colors.black
                  ),
                  controller: _cityController,
                  onChanged: (value){
                    setState(() {
                      _cityError = false;
                    });
                  },
                ),
                Padding(padding: EdgeInsets.only(top: 16.0)),
                OutlineButton(
                  onPressed: (){
                    _validateInputs();
                  },
                  borderSide: BorderSide(color: Color(0xff073848), width: 2.0),
                  highlightedBorderColor: Color(0xffff7100),
                  highlightColor: Color(0xffff7100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: (_isRefreshing)?
                        new CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xffff7100))
                        )
                        :
                        Text(
                          "SAVE ADDRESS",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 16.0)),
          (_maxError)?
                Text(
                  "You can save a maximum of 3 addresses. Delete an existing address to add new.",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Roboto",
                      color: Color(0xffff7100)
                  ),
                )
              :
                new Container()
              ],
            ),
          ),
        ),
      ),
    );
  }

}