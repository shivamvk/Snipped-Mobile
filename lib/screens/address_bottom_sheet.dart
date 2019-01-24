import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class AddressBottomSheet extends StatefulWidget{

  final int totalValue;

  AddressBottomSheet(this.totalValue);

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

String _proceedBtnText;

final FlutterLocalNotificationsPlugin localNotificationsPlugin = new FlutterLocalNotificationsPlugin();


class _AddressBottomSheetState extends State<AddressBottomSheet>{

  _validateInputs(){
    String pincode = _pinCodeController.text;
    String flat = _flatController.text;
    String colony = _colonyController.text;
    String city = _cityController.text;

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

    _showNotification();

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
    _proceedBtnText = "Place your order ( ₹ " + widget.totalValue.toString() + " )";
    var initializationSettingsAndroid = new AndroidInitializationSettings('brandlogoscissors');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    localNotificationsPlugin.initialize(initializationSettings);
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
                setState(() {
                  _pinCodeError = false;
                });
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
              decoration: InputDecoration(
                labelText: "City",
                labelStyle: new TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w300
                ),
                errorText: _cityError? "This field is required!" : null
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
                labelText: "Apoointment date",
                labelStyle: new TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
                errorText: _dateError? "Advanced booking of only 2 days allowed!" : null
              ),
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
                errorText: _timeError? "Time needs to be between 11:00 and 19:00!" : null
              ),
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
                  child: Text(
                    _proceedBtnText,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400
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