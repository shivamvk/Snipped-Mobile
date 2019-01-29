import 'package:snipped/models/Service.dart';

class Order{

  final String id;
  final String phone;
  final List<Service> services;
  final String amount;
  final String address;
  final String date;
  final String time;
  final String appointmentDate;
  final String appointmentTime;
  final String status;
  final String remarks;
  final String coupon;

  Order({
    this.id,
    this.phone,
    this.services,
    this.amount,
    this.address,
    this.date,
    this.time,
    this.appointmentDate,
    this.appointmentTime,
    this.status,
    this.remarks,
    this.coupon
  });

  factory Order.fromJson(Map<String, dynamic> parsedJson){

    var list = parsedJson['services'] as List;
    List<Service> servicesList = list.map((i) => Service.fromJson(i)).toList();

   return Order(
     id: parsedJson['_id'],
     phone: parsedJson['phone'],
     services: servicesList,
     amount: parsedJson['amount'],
     address: parsedJson['address'],
     date: parsedJson['date'],
     time: parsedJson['time'],
     appointmentDate: parsedJson['appointmentDate'],
     appointmentTime: parsedJson['appointmentTime'],
     status: parsedJson['status'],
     remarks: parsedJson['remarks'],
     coupon: parsedJson['coupon']
   );
  }
}

class Response{
  final int status;
  final List<Order> orders;
  final String message;

  Response({
    this.status,
    this.orders,
    this.message
  });

  factory Response.fromJson(Map<String, dynamic> parsedJson){

    var list = parsedJson['data'] as List;
    List<Order> ordersList = list.map((i) => Order.fromJson(i)).toList();

    return Response(
        status: parsedJson['status'],
        orders: ordersList,
        message: parsedJson['message']
    );
  }

}