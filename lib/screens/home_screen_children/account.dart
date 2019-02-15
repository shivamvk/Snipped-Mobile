import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              )
            ],
          ),
        ),
      ),
    );
  }

}