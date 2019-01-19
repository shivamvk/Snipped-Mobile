import 'package:flutter/material.dart';

class Response{
  final int status;
  final List<User> users;
  final String message;

  Response({
    this.status,
    this.users,
    this.message
  });

  factory Response.fromJson(Map<String, dynamic> parsedJson){

    var list = parsedJson['data'] as List;
    List<User> usersList = list.map((i) => User.fromJson(i)).toList();

    return Response(
        status: parsedJson['status'],
        users: usersList,
        message: parsedJson['message']
    );
  }

}

class User{
  final String phone;
  final String name;
  final String email;

  User({
    this.phone,
    this.name,
    this.email
  });

  factory User.fromJson(Map<String, dynamic> parsedJson){
    return User(
        phone: parsedJson['phone'],
        name: parsedJson['username'],
        email: parsedJson['email']
    );
  }

}