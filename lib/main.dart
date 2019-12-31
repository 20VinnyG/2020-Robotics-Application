import 'package:flutter/material.dart';
import 'homepage.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FRC 1640 Scouting App',
      home: Homepage()
    );
  }
}