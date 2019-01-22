import 'package:debt_bomb/home.dart';
import 'package:flutter/material.dart';
import 'sign_in.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home: new SignInPage(),
    );
  }
}
