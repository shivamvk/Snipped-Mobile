import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';

import 'package:snipped/models/Faq.dart';

class ChildFaq extends StatefulWidget{
  @override
  _ChildFaqState createState() => _ChildFaqState();
}

List<String> list = new List();

class _ChildFaqState extends State<ChildFaq>{

  Future<List<Faq>> _getFaqs() async{
    String url = "http://3.0.235.136:8080/Snipped-0.0.1-SNAPSHOT/faq";
    var data = await http.get(url);

    Response response = Response.fromJson(json.decode(data.body));
    return response.faqs;
  }

  _callSupport() async{
    const url = "tel:8630363425";
    if(await canLaunch(url)){
      launch(url);
    }
  }

  _mailSupport() async {
    const url = "mailto:internals.snipped@gmail.com?subject=I have a query!&body=Please describe your query here.";
    if(await canLaunch(url)){
      launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 10,
            child: Center(
              child: FutureBuilder(
                future: _getFaqs(),
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  if(snapshot.hasData){
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index){
                        return new Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.90,
                                      child: Text(
                                        "Q: " + snapshot.data[index].ques,
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                    Text(
                                      "Ans: " + snapshot.data[index].ans,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w300
                                      ),
                                    ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: (list.contains(snapshot.data[index].id))? Container() : Divider(),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if(snapshot.hasError){
                    return new Center(
                      child: new Text('Error: ${snapshot.error}'),
                    );
                  }
                  return new CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(Color(0xffff7100))
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: (MediaQuery.of(context).orientation == Orientation.portrait)? 1 : 2,
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.green,
              child: Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 8.0)),
                  Text(
                    "Still can't find an answer?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontFamily: "Roboto"
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 8.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(left: 32.0)),
                      GestureDetector(
                        onTap: () => _callSupport(),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.call, color: Colors.white,),
                            Padding(padding: EdgeInsets.only(left: 4.0)),
                            Text(
                              "Call us!",
                              style:TextStyle(
                                color: Colors.white,
                                fontSize: 16.0
                              ),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _mailSupport(),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.mail, color: Colors.white,),
                            Padding(padding: EdgeInsets.only(left: 4.0)),
                            Text(
                              "Mail us!",
                              style:TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(right: 32.0))
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

}