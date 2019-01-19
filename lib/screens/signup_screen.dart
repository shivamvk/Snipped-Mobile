import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';

//The signupScreen for the app.

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

final _nameController = new TextEditingController();
final _emailController = new TextEditingController();

bool _showEmailError = false;
bool _showNameError = false;
bool _isLoading = false;

class _SignupScreenState extends State<SignupScreen> {

  String _phone;

  @override
  void initState() {
    getPhonePreferences()
      .then(updatePhone);
    super.initState();
  }

  void updatePhone(phone){
    setState(() {
      _phone = phone;
    });
  }

  void _validateInputs(){
    String email = _emailController.text;
    String name = _nameController.text;

    if(name.isEmpty){
      _setNameError(true);
      return ;
    }

    if(email.isEmpty){
      _setEmailError(true);
      return;
    }

    if(!validateEmail(email)){
      _setEmailError(true);
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    savePreferences(name, email);
    signup(email, name, _phone);
  }

  Future<void> signup(email, name, phone) async{
    String url =
        "http://13.251.185.41:8080/Snipped-0.0.1-SNAPSHOT/user";
    Map<String, String> map = {
      "name" : name,
      "email" : email,
      "phone" : phone
    };
    final data = await http.post(url, body: map);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen())
    );
  }

  void _setEmailError(bool b){
    setState(() {
      _showEmailError = b;
    });
  }

  void _setNameError(bool  b){
    setState(() {
      _showNameError = b;
    });
  }

  Future<String> getPhonePreferences() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString("userPhone") ?? "";
  }

  Future<bool> savePreferences(String name, String email) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userName", name);
    prefs.setString("userEmail", email);
    return prefs.commit();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: new Color(0xff073848),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32.0, 48.0, 32.0, 32.0),
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 0.0),
                child: new Center(
                  child: new Text(
                    "Seems like you are new to",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                    ),
                  ),
                ),
              ),
              new Image.asset(
                "images/brandlogowhite.png",
                width: 500,
                height: 150,
              ),
              new TextField(
                decoration: new InputDecoration(
                  labelText: "What do your friends call you?",
                  labelStyle: new TextStyle(
                    color: Colors.white,
                  ),
                  errorText: _showNameError? "Please enter a valid name" : null
                ),
                keyboardType: TextInputType.text,
                cursorColor: new Color(0xffff7100),
                controller: _nameController,
                onChanged: (value) => _setNameError(false),
              ),
              new TextField(
                decoration: new InputDecoration(
                    labelText: "What is your cool email?",
                    labelStyle: new TextStyle(
                      color: Colors.white,
                    ),
                    errorText:
                    _showEmailError ? "Please enter a valid email" : null),
                keyboardType: TextInputType.emailAddress,
                cursorColor: new Color(0xffff7100),
                controller: _emailController,
                onChanged: (value) => _setEmailError(false),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: new RaisedButton(
                  onPressed: _validateInputs,
                  color: Colors.white,
                  textColor: new Color(0xffff7100),
                  shape: new RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _isLoading? new CircularProgressIndicator() : new Text(
                      "Proceed",
                      style: new TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
      )
    );
  }

  bool validateEmail(String value) {
    if (RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
      return true;
    } else {
      return false;
    }
  }
}
