import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'order_screen_children/todays_orders.dart';
import 'order_screen_children/all_orders.dart';
import 'order_screen_children/upcoming_orders.dart';
import 'order_screen_children/past_orders.dart';
import 'home_screen.dart';

class OrdersScreen extends StatefulWidget{
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrdersScreen>{
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Orders"),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen())
                );
              },
            ),
            bottom: TabBar(
              indicatorColor: Color(0xffff7100),
              tabs: <Widget>[
                Tab(text: "All",),
                Tab(text: "Today's",),
                Tab(text: "Upcoming",),
                Tab(text: "Past",),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              AllOrders(),
              TodaysScreen(),
              UpcomingOrders(),
              PastOrders()
            ],
          ),
        ),
      ),
    );
  }
}