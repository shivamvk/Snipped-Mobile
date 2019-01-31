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

import 'order_placed_screen.dart';
import 'package:snipped/models/Order.dart';

class AddressBottomSheet extends StatefulWidget{

  final int totalValue;
  final List<String> cartList;
  final String couponCode;

  AddressBottomSheet(this.totalValue, this.cartList, this.couponCode);

  @override
  _AddressBottomSheetState createState() => _AddressBottomSheetState();
}

bool _pinCodeError = false;
bool _flatError = false;
bool _colonyError = false;
bool _cityError = false;
bool _dateError = false;
bool _timeError = false;

final _pinCodeController = new TextEditingController();
final _flatController = new TextEditingController();
final _colonyController = new TextEditingController();
final _cityController = new TextEditingController();
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

final FlutterLocalNotificationsPlugin localNotificationsPlugin = new FlutterLocalNotificationsPlugin();

class _AddressBottomSheetState extends State<AddressBottomSheet>{

  _validateInputs(){
    String pincode = _pinCodeController.text;
    String flat = _flatController.text;
    String colony = _colonyController.text;
    String city = _cityController.text;
    String date = _dateController.text;
    String time = _timeController.text;
    String remarks = _remarksController.text;

    if(pincode.isEmpty){
      setState(() {
        _pinCodeError = true;
      });
      return;
    }

    if(pincode.length != 6){
      setState(() {
        _pinCodeError = true;
      });
      return;
    }

    if(flat.isEmpty){
      setState(() {
        _flatError = true;
      });
      return;
    }

    if(colony.isEmpty){
      setState(() {
        _colonyError = true;
      });
      return;
    }

    if(city.isEmpty){
      setState(() {
        _cityError = true;
      });
      return;
    }

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
    if(_date.day.toString() == "9")

    return true;
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

    _cityController.text = "Lucknow";

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
              "Please enter your address to proceed!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
            ),
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