// contest_model.dart
import 'package:flutter/material.dart';

class Contest {
  String imageUrl;
  String title;
  String description;
  DateTime startDate;
  DateTime endDate;
  String organizer;
  DateTime applicationStart;
  DateTime applicationEnd;
  String applicationLink;
  String location;
  String contact;
  int views;

  Contest({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.organizer,
    required this.applicationStart,
    required this.applicationEnd,
    required this.applicationLink,
    required this.location,
    required this.contact,
    this.views = 0,
  });
}
