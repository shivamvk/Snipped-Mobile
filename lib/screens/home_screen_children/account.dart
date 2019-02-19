import 'package:flutter/material.dart';
import 'package:snipped/models/Address.dart';
import 'package:snipped/screens/home_screen.dart';
import 'package:snipped/transitions/slide_rtl.dart';
import 'package:snipped/widgets/add_address.dart';
import 'package:http/http.dart' as  http;
import 'dart:convert';

class ChildAccount extends StatefulWidget{

  final String name;
  final String email;
  final String phone;

  ChildAccount({
    this.name,
    this.email,
    this.phone
  });


  @override
  _ChildAccountState createState() => _ChildAccountState();
}

class _ChildAccountState extends State<ChildAccount>{

  bool _isLoading = true;
  List<Address> addresses = new List();

  @override
  void initState() {
    _isLoading = true;
    loadAddresses()
      .then((list){
        setState(() {
          addresses = list;
          _isLoading = false;
        });
    });
    super.initState();
  }

  Future<List<Address>> loadAddresses() async {
    String url = "http://3.0.235.136:8080/Snipped-0.0.1-SNAPSHOT/address/" + widget.phone;
    var data = await http.get(url);
    return AddressResponse.fromJson(json.decode(data.body)).addresses;
  }

  Future<bool> _deleteAddress(value) async {
    String url = "http://3.0.235.136:8080/Snipped-0.0.1-SNAPSHOT/address/" + value;
    var data = await http.delete(url);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return (_isLoading)?
    Center(
      child: new CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xffff7100))
      ),
    )
    :
    SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new CircleAvatar(
                backgroundColor: Color(0xffff7100),
                minRadius: 50.0,
                child: new Text(
                  (widget.name == null) ? "hey" : widget.name[0],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 32.0)),
              Text(
                "Name",
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w300
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 8.0)),
              Text(
                widget.name,
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w500
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 4.0)),
              Divider(),
              Padding(padding: EdgeInsets.only(top: 4.0)),
              Text(
                "Email",
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w300
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 8.0)),
              Text(
                widget.email,
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w500
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 4.0)),
              Divider(),
              Padding(padding: EdgeInsets.only(top: 4.0)),
              Text(
                "Phone",
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w300
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 8.0)),
              Text(
                widget.phone,
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w500
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 4.0)),
              Divider(),
              Padding(padding: EdgeInsets.only(top: 4.0)),
              Text(
                "Address",
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w300
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 8.0)),
              (addresses.length >= 1)
                  ?
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.0)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          addresses[0].flat + ", " + addresses[0].colony,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Roboto"
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 4.0)),
                        Text(
                          addresses[0].city + ", "+ "Pincode : " + addresses[0].pincode,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Roboto"
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 8.0)),
                        GestureDetector(
                          onTap: (){
                            _deleteAddress(addresses[0].id)
                              .then((bool){
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext) => HomeScreen()
                                  ),
                                );
                            });
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16.0,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.w400
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                )
                  :
                new Container(),
              Padding(padding: EdgeInsets.only(top: 8.0)),
              (addresses.length >= 2)
                  ?
              Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.0)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          addresses[1].flat + ", " + addresses[1].colony,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Roboto"
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 4.0)),
                        Text(
                          addresses[1].city + ", "+ "Pincode : " + addresses[1].pincode,
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Roboto"
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 8.0)),
                        GestureDetector(
                          onTap: (){
                            _deleteAddress(addresses[1].id)
                                .then((bool){
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (BuildContext) => HomeScreen()),
                              );
                            });
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 16.0,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        )
                      ],
                    ),
                  )
              )
                  :
              new Container(),
              Padding(padding: EdgeInsets.only(top: 8.0)),
              (addresses.length >= 3)
                  ?
              Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.0)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          addresses[2].flat + ", " + addresses[2].colony,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Roboto"
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 4.0)),
                        Text(
                          addresses[2].city + ", "+ "Pincode : " + addresses[2].pincode,
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Roboto"
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 8.0)),
                        GestureDetector(
                          onTap: (){
                            _deleteAddress(addresses[2].id)
                                .then((bool){
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (BuildContext) => HomeScreen()),
                              );
                            });
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 16.0,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        )
                      ],
                    ),
                  )
              )
                  :
              new Container(),
              Padding(padding: EdgeInsets.only(top: 8.0)),
              OutlineButton(
                onPressed: (){
                  Navigator.pushReplacement(
                    context,
                    SlideRTL(widget: AddAddressBottomSheet(phone: widget.phone, calledfrom: "Account")),
                  );
                },
                borderSide: BorderSide(color: Color(0xff073848), width: 2.0),
                highlightedBorderColor: Color(0xffff7100),
                highlightColor: Color(0xffff7100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "ADD NEW ADDRESS",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 16.0, bottom: 16.0))
            ],
          ),
        ),
      ),
    );
  }

}