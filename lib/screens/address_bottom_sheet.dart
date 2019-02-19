import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:snipped/models/Address.dart';

import 'order_placed_screen.dart';
import 'package:snipped/models/Order.dart';

class AddressBottomSheet extends StatefulWidget{

  final int totalValue;
  final List<String> cartList;
  final String couponCode;
  final List<Address> addresses;

  AddressBottomSheet(this.totalValue, this.cartList, this.couponCode, this.addresses);

  @override
  _AddressBottomSheetState createState() => _AddressBottomSheetState();
}

bool _dateError = false;
bool _timeError = false;
bool _addressError = false;

final _dateController = new TextEditingController();
final _timeController = new TextEditingController();
final _remarksController = new TextEditingController();

var _date;
var _time;

String _dateErrorText = "This field is required!";
String _timeErrorText = "This field is required!";
String _proceedBtnText;

bool _isRefreshing = false;

String _name;
String _email;
String _phone;
String _cart;

Address _selectedAddress;

final FlutterLocalNotificationsPlugin localNotificationsPlugin = new FlutterLocalNotificationsPlugin();

class _AddressBottomSheetState extends State<AddressBottomSheet>{

  _validateInputs(){
    String date = _dateController.text;
    String time = _timeController.text;
    String remarks = _remarksController.text;

    if(_selectedAddress == null){
      setState(() {
        _addressError = true;
      });
      return;
    }

    String pincode = _selectedAddress.pincode;
    String flat = _selectedAddress.flat;
    String colony = _selectedAddress.colony;
    String city = _selectedAddress.city;

    if(date.isEmpty){
      setState(() {
        _dateError = true;
        _dateErrorText = "This field is required!";
      });
      return;
    }

    if(time.isEmpty){
      setState(() {
        _timeError = true;
        _timeErrorText = "This field is required!";
      });
      return;
    }

    if(!_validateDate()){
      return;
    }

    if(!_validateTime()){
      return;
    }

    if(remarks.isEmpty){
      remarks = "none";
    }

    setState(() {
      _isRefreshing = true;
    });

    _placeOrder(flat, colony, city, pincode, remarks)
      .then((value){
        _sendEmail(_email, value)
            .then((bool){
          _clearCart();
          _showNotification();
          setState(() {
            _isRefreshing = false;
          });
          FirebaseMessaging firebaseMessaging = FirebaseMessaging();
          firebaseMessaging.subscribeToTopic(value);
          getFirebaseNotificationsSubscription()
            .then((subs){
              String string = subs + value + ",";
              saveFirebaseNotificationsSubscription(string);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OrderPlacedScreen(
                    widget.totalValue,
                    widget.cartList,
                    value,
                    _date,
                    _time,
                    pincode,
                    flat,
                    colony,
                    city
                )
                )
              );
          });
        });
      });
  }

  Future<String> _placeOrder(flat, colony, city, pincode, remarks) async{
    var date = DateTime.now();
    var dateFormatter = DateFormat("dd-MM-yyyy");
    String formattedDate = dateFormatter.format(date);
    var timeFormatter = DateFormat("HH:mm");
    String formattedTime = timeFormatter.format(date);
    Map<String, String> map = {
      "phone" : _phone,
      "services" : _cart,
      "amount" : widget.totalValue.toString(),
      "address" : _name + ", " + flat + ", " + colony + ", " + city + ". Pincode: " + pincode + ". Phone: " + _phone,
      "date" : formattedDate,
      "time" : formattedTime,
      "appointmentDate" : _date.day.toString() + "-" + _date.month.toString() + "-" + _date.year.toString(),
      "appointmentTime" : _time.hour.toString() + ":" + _time.minute.toString(),
      "status" : "Pending",
      "remarks" : remarks,
      "coupon" : (widget.couponCode.isEmpty)? "----" : widget.couponCode
    };

    String url = "http://3.0.235.136:8080/Snipped-0.0.1-SNAPSHOT/order";
    var data = await http.post(url, body: map);

    Response response = Response.fromJson(json.decode(data.body));
    return response.orders[0].id;

  }

  Future<String> getFirebaseNotificationsSubscription() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("subscription") ?? "";
  }

  Future<bool> saveFirebaseNotificationsSubscription(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();;
    prefs.setString("subscription", value);
    return prefs.commit();
  }

  Future<String> getEmailPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userEmail") ?? "";
  }

  Future<String> getNamePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userName") ?? "";
  }

  Future<String> getPhonePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userPhone") ?? "";
  }

  Future<String> getCartPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("cart") ?? "";
  }
  
  Future<bool> _sendEmail(value, orderid) async{
    String url = "http://3.0.235.136:8080/Snipped-0.0.1-SNAPSHOT/mail/order_placed";
    Map<String, String> map = {
      "email" : value,
      "orderId" : orderid
    };
    var data = await http.post(url, body: map);
    return true;
  }

  _clearCart(){
    savePreferences("");
  }

  Future<bool> savePreferences(cart) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();;
    prefs.setString("cart", cart);
    return prefs.commit();
  }

  bool _validateTime(){
    if(_time.hour < 12){
      setState(() {
        _timeError = true;
        _timeErrorText = "We currently don't service before 12 a.m!";
      });
      return false;
    }
    if(_time.hour == 17){
      if(_time.minute != 0){
        setState(() {
          _timeError = true;
          _timeErrorText = "We currently don't service after 5 p.m!";
        });
        return false;
      }
    }
    if(_time.hour > 17){
      setState(() {
        _timeError = true;
        _timeErrorText = "We currently don't service after 5 p.m!";
      });
      return false;
    }
    var currentdate = DateTime.now();
    if(currentdate.day == _date.day && currentdate.month == _date.month && currentdate.year == _date.year){
      if(currentdate.hour > _time.hour){
        setState(() {
          _timeError = true;
          _timeErrorText = "We wish we could've served you in the past!";
        });
        return false;
      }
    }
    return true;
  }

  bool _validateDate(){
    var currentDate = DateTime.now();
    var tommorow = currentDate.add(Duration(days: 1));
    if(currentDate.day == _date.day && currentDate.month == _date.month && currentDate.year == _date.year){
      setState(() {
        _dateError = true;
        _dateErrorText = "You can't book for the same day! We need atleast a day to be ready.";
      });
      return false;
    }
    if(_date.isBefore(currentDate)){
      setState(() {
        _dateError = true;
        _dateErrorText = "We wish we could've served you in the past!";
      });
      return false;
    }
    if(_date.day == tommorow.day && _date.month == tommorow.month && _date.year == tommorow.year){
      if(currentDate.hour > 17){
        setState(() {
          _dateError = true;
          _dateErrorText = "Bookings for next day need to booked atleast before 5:00 p.m!";
        });
        return false;
      }
    }
    if(_date.day.toString() == "9" && _date.month.toString() == "2" && _date.year.toString() == "2019"
    || _date.day.toString() == "16" && _date.month.toString() == "2" && _date.year.toString() == "2019"
    || _date.day.toString() == "23" && _date.month.toString() == "2" && _date.year.toString() == "2019"
    || _date.day.toString() == "24" && _date.month.toString() == "2" && _date.year.toString() == "2019"
    || _date.day.toString() == "25" && _date.month.toString() == "2" && _date.year.toString() == "2019"
    || _date.day.toString() == "26" && _date.month.toString() == "2" && _date.year.toString() == "2019"){
      return true;
    } else{
      setState(() {
        _dateError = true;
        _dateErrorText = "We're currently taking orders for 9, 16, 23, 24, 25 and 26th of Feb";
      });
      return false;
    }
  }

  _showNotification() async{
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '0', 'Micellaneous', 'General notifications',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await localNotificationsPlugin.show(
        0, "Thanks for ordering!",
        "Your order has been placed succesfully." , platformChannelSpecifics);
  }

  @override
  void initState() {
    _proceedBtnText = "Confirm your order ( ₹ " + widget.totalValue.toString() + " )";
    var initializationSettingsAndroid = new AndroidInitializationSettings('brandlogonotification');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    localNotificationsPlugin.initialize(initializationSettings);

    _addressError = false;
    _dateError = false;
    _timeError = false;

    getEmailPreferences()
      .then((value){
        setState(() {
          _email = value;
        });
    });

    getNamePreferences()
      .then((value){
        _name = value;
    });

    getPhonePreferences()
      .then((value){
        _phone = value;
    });

    getCartPreferences()
      .then((value){
        _cart = value;
    });

    _selectedAddress = null;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(
              Icons.remove,
              size: 40.0,
            ),
            Text(
              "Please select an address!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 8.0)),
            (widget.addresses.length >= 1)
                ?
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAddress = widget.addresses[0];
                  _addressError = false;
                });
              },
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: (_selectedAddress == widget.addresses[0])?
                      Border.all(color: Color(0xffff7100), width: 2.0)
                      :Border.all(color: Colors.black, width: 1.0)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.addresses[0].flat + ", " + widget.addresses[0].colony,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Roboto"
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 4.0)),
                        Text(
                          widget.addresses[0].city + ", "+ "Pincode : " + widget.addresses[0].pincode,
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Roboto"
                          ),
                        ),
                      ],
                    ),
                  )
              ),
            )
                :
            new Container(),
            Padding(padding: EdgeInsets.only(top: 8.0)),
            (widget.addresses.length >= 2)
                ?
            GestureDetector(
              onTap: (){
                setState(() {
                  _selectedAddress = widget.addresses[1];
                  _addressError = false;
                });
              },
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: (_selectedAddress == widget.addresses[1])?
                      Border.all(color: Color(0xffff7100), width: 2.0)
                          :Border.all(color: Colors.black, width: 1.0)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.addresses[1].flat + ", " + widget.addresses[1].colony,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Roboto"
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 4.0)),
                        Text(
                          widget.addresses[1].city + ", "+ "Pincode : " + widget.addresses[1].pincode,
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Roboto"
                          ),
                        ),
                      ],
                    ),
                  )
              ),
            )
                :
            new Container(),
            Padding(padding: EdgeInsets.only(top: 8.0)),
            (widget.addresses.length >= 3)
                ?
            GestureDetector(
              onTap: (){
                setState(() {
                  _selectedAddress = widget.addresses[2];
                  _addressError = false;
                });
              },
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: (_selectedAddress == widget.addresses[2])?
                      Border.all(color: Color(0xffff7100), width: 2.0)
                          :Border.all(color: Colors.black, width: 1.0)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.addresses[2].flat + ", " + widget.addresses[2].colony,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Roboto"
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 4.0)),
                        Text(
                          widget.addresses[2].city + ", "+ "Pincode : " + widget.addresses[2].pincode,
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Roboto"
                          ),
                        ),
                      ],
                    ),
                  )
              ),
            )
                :
            new Container(),
            (_addressError)?new Text(
              "Please select an address!",
              style: TextStyle(
                color: Colors.red,
              ),
            ) : new Container(),
            DateTimePickerFormField(
              format: DateFormat("dd-MM-yyyy"),
              inputType: InputType.date,
              editable: false,
              decoration: InputDecoration(
                labelText: "Appointment date",
                labelStyle: new TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
                errorText: _dateError? _dateErrorText : null
              ),
              onChanged: (value){
                setState(() {
                  _dateError = false;
                });
                _date = value;
              },
              controller: _dateController,
            ),
            DateTimePickerFormField(
              format: DateFormat("HH:mm"),
              inputType: InputType.time,
              editable: false,
              decoration: InputDecoration(
                labelText: "Appointment time",
                labelStyle: new TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
                errorText: _timeError? _timeErrorText : null
              ),
              onChanged: (value){
                setState(() {
                  _timeError = false;
                });
                _time = value;
              },
              controller: _timeController,
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: "Any special instructions(Optional)",
                  labelStyle: new TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w300
                  ),
              ),
              keyboardType: TextInputType.text,
              cursorColor: new Color(0xffff7100),
              style: new TextStyle(
                  color: Colors.black
              ),
              controller: _remarksController,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: RaisedButton(
                onPressed: (){
                  _validateInputs();
                },
                color: Color(0xffff073848),
                textColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _isRefreshing?
                  new CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(Color(0xffff7100))
                  ) :
                  Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      _proceedBtnText,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}