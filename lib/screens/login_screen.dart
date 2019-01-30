import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

import 'signup_screen.dart';
import 'home_screen.dart';
import 'package:snipped/models/User.dart';

class LoginScreen extends StatefulWidget{

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

String _verificationId;

final _phoneController = new TextEditingController();
final _otpController = new TextEditingController();

bool _isLoading = false;
bool _phoneNumberEntered = false;
bool _phoneNumberError = false;
bool _otpError = false;

String _buttonText = "Request OTP";

class _LoginScreenState extends State<LoginScreen>{

  @override
  void initState() {
    _isLoading = false;
    _phoneNumberEntered = false;
    _buttonText = "Request OTP";
    super.initState();
  }

  void _validatePhoneNumber() {
    _updateRefreshing(true);
    String phone = _phoneController.text;
    if(phone.length != 10){
      _setPhoneError(true);
      _updateRefreshing(false);
      return;
    }
    _verifyPhone(phone);
  }

  void _verifyOTP(){
    String value = _otpController.text;
    if(value.toString().length != 6){
      _setOtpError(true);
      return;
    }
    _updateRefreshing(true);
    signIn(value);
  }

  void _updateRefreshing(bool b){
    setState(() {
      _isLoading = b;
    });
  }

  void _setPhoneError(bool b){
    setState(() {
      _phoneNumberError = b;
    });
  }

  void _setOtpError(bool b){
    setState(() {
      _otpError = b;
    });
  }

  Future<bool> savePreferences(String phone, String name, String email) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userPhone", phone);
    prefs.setString("userName", name);
    prefs.setString("userEmail", email);
    return prefs.commit();
  }

  Future<void> checkIfUserAlreadyExists(phone) async{
    final data = await http.get("http://3.0.235.136:8080/Snipped-0.0.1-SNAPSHOT/number_exists?phone=" + phone);

    //snapshot.data == "true" means user already exists
    //and hence proceed to the homeScreen
    //else proceed to the signupScreen to
    //register user in the database
    if(data.body == "true"){
      getUserDetails(phone);
    } else {
      savePreferences(phone, "", "");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignupScreen())
      );
    }

  }

  Future<void> getUserDetails(phone) async{
    String url = "http://3.0.235.136:8080/Snipped-0.0.1-SNAPSHOT/user/" + phone;
    var data = await http.get(url);
    var jsonData = json.decode(data.body);
    Response response =  Response.fromJson(jsonData);
    savePreferences(phone, response.users[0].name, response.users[0].email);
    /*setState(() {
      _updateRefreshing(false);
    });
    getNamePreferences()
      .then((value) {
        _buttonText = value;
    });*/
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen())
    );
  }

  Future<String> getNamePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userName") ?? "";
  }

  void _verificationDone(phone){
    checkIfUserAlreadyExists(phone);
  }

  signIn(value){
    FirebaseAuth.instance.signInWithPhoneNumber(
      verificationId: _verificationId,
      smsCode: value
    ).then((user){
      _verificationDone(_phoneController.text);
    }).catchError((e){
      _updateRefreshing(false);
      _setOtpError(true);
    });
  }

  Future<void> _verifyPhone(phone) async{

    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout = (String verId){
      _verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]){
      _verificationId = verId;
      setState(() {
        _phoneNumberEntered = true;
        _isLoading = false;
        _buttonText = "Submit OTP";
      });
    };

    final PhoneVerificationCompleted verificationCompleted = (FirebaseUser user){
      _verificationDone(phone);
    };

    final PhoneVerificationFailed verificationFailed = (AuthException e) {
      setState(() {
        _updateRefreshing(false);
        _buttonText = e.toString();
      });
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91" + phone,
      codeAutoRetrievalTimeout: autoRetrievalTimeout,
      codeSent: smsCodeSent,
      timeout: const Duration(seconds: 1),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Color(0xff073848),
      body: SingleChildScrollView(
        child: new Center(
          child: new Padding(
            padding: EdgeInsets.all(8.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Image.asset(
                  "images/brandlogowhite.png",
                  width: 600,
                  height: 200,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: new TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    style: new TextStyle(
                        color: Colors.white
                    ),
                    enabled: (_phoneNumberEntered)? false : true,
                    onChanged: (value) =>_setPhoneError(false),
                    decoration: new InputDecoration(
                        labelText: "Enter your phone number",
                        labelStyle: new TextStyle(
                          color: Colors.white,
                        ),
                        errorText: _phoneNumberError? "Enter a valid number" : null,
                        icon: new Icon(
                          Icons.call,
                          color: new Color(0xffff7100),
                        )
                    ),
                  ),
                ),
                _phoneNumberEntered? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: new TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    style: new TextStyle(
                      color: Colors.white
                    ),
                    decoration: new InputDecoration(
                      labelText: "Enter OTP",
                      labelStyle: new TextStyle(
                        color: Colors.white
                      ),
                      errorText: _otpError? "Enter a valid otp" : null,
                      icon: new Icon(
                        Icons.vpn_key,
                        color: new Color(0xffff7100),
                      )
                    ),
                    onChanged: (value) => _setOtpError(false),
                  ),
                ) : new Container(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 32.0),
                  child: new RaisedButton(
                    onPressed: _phoneNumberEntered? _verifyOTP : _validatePhoneNumber,
                    color: Colors.white,
                    textColor: new Color(0xffff7100),
                    shape: new RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _isLoading ? new CircularProgressIndicator() : new Text(
                        _buttonText,
                        style: new TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}