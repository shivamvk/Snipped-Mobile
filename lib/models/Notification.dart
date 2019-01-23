import 'package:flutter/material.dart';

class Notification{
  final String title;
  final String text;

  Notification({
    this.title,
    this.text
  });

  factory Notification.fromJson(Map<String, dynamic> parsedJson){
    return Notification(
      title: parsedJson['title'],
      text: parsedJson['body']
    );
  }
}

class NotificationObj{
  Notification notification;

  NotificationObj({
    this.notification
  });

  factory NotificationObj.fromJson(Map<String, dynamic> parsedJson){
    return NotificationObj(
      notification: Notification.fromJson(parsedJson['notification'])
    );
  }
}