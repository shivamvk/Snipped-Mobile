import 'package:flutter/material.dart';

class AddressBottomSheet extends StatefulWidget{

  @override
  _AddressBottomSheetState createState() => _AddressBottomSheetState();
}

bool _pinCodeError = false;
bool _flatError = false;
bool _colonyError = false;
bool _cityError = false;

final _pinCodeController = new TextEditingController();
final _flatController = new TextEditingController();
final _colonyController = new TextEditingController();
final _cityController = new TextEditingController();

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
                    "Proceed to payment",
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