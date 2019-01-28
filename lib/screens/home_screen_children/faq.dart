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
    const url = "tel:8130583124";
    if(await canLaunch(url)){
      launch(url);
    } else{

    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 9,
            child: Center(
              child: FutureBuilder(
                future: _getFaqs(),
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  if(snapshot.hasData){
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index){
                        return new Container(
                          color: (list.contains(snapshot.data[index].id))? Colors.grey[200] : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      if(list.contains(snapshot.data[index].id)){
                                        list.remove(snapshot.data[index].id);
                                      } else{
                                        list.add(snapshot.data[index].id);
                                      }
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Q: " + snapshot.data[index].ques,
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black
                                        ),
                                      ),
                                      (list.contains(snapshot.data[index].id))?
                                          Icon(Icons.arrow_drop_up)
                                          : Icon(Icons.arrow_drop_down)
                                    ],
                                  ),
                                ),
                                (list.contains(snapshot.data[index].id))?
                                    Text(
                                      "Ans: " + snapshot.data[index].ans,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w300
                                      ),
                                    )
                                    : new Container(),
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
            child: RaisedButton(
              onPressed: () => _callSupport(),
              color: Color(0xff073848),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(
                    Icons.call,
                    color: Color(0xffff7100),
                    size: 50.0,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        "Still can't find answer?",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w300,
                          color: Colors.white
                        ),
                      ),
                      Text(
                        "Call us!",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white
                        ),
                      )
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white,)
                ],
              )
            ),
          )
        ],
      ),
    );
  }

}