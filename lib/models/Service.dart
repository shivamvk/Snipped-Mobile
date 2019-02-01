import 'package:flutter/material.dart';

class ServiceResponse{
  final int status;
  final List<Service> services;
  final String message;

  ServiceResponse({
    this.status,
    this.services,
    this.message
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> parsedJson){

    var list = parsedJson['data'] as List;
    List<Service> servicesList = list.map((i) => Service.fromJson(i)).toList();

    return ServiceResponse(
        status: parsedJson['status'],
        services: servicesList,
        message: parsedJson['message']
    );
  }

}

class Service{

  final String category;
  final String subcategory;
  final int price;
  final String name;
  final String id;
  final String gender;
  final String description;

  Service({
    this.id,
    this.name,
    this.price,
    this.category,
    this.subcategory,
    this.gender,
    this.description
  });

  factory Service.fromJson(Map<String, dynamic> parsedJson){
    return Service(
      id: parsedJson['_id'],
      name: parsedJson['name'],
      price: parsedJson['price'],
      category: parsedJson['category'],
      subcategory: parsedJson['subcategory'],
      gender: parsedJson['gender'],
      description: parsedJson['description']
    );
  }

}