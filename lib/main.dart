import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Text(
          'Minimal App Test',
          style: TextStyle(fontSize: 32, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.blueGrey,
    ),
    theme: ThemeData.dark(),
  ));
}
