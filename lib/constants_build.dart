import 'package:flutter/material.dart';

List<BoxShadow> boxShadow() {
  return [
    BoxShadow(
      color: Colors.brown.shade800,
      blurRadius: 0,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.brown.shade400,
      blurRadius: 0,
      spreadRadius: 0,
      offset: Offset(-4, 0),
    ),
    BoxShadow(
      color: Colors.brown.shade600,
      blurRadius: 0,
      spreadRadius: 0,
      offset: Offset(4, 0),
    ),
    BoxShadow(
      color: Colors.brown.shade500,
      blurRadius: 0,
      spreadRadius: 0,
      offset: Offset(0, -4),
    ),
  ];
}
