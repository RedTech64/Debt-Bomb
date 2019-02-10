import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DataCard extends StatelessWidget {
  String label;
  final String value;
  TextStyle style;
  Color color;

  DataCard({
    this.label,
    @required this.value,
    this.style,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return new Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: new Column(
            children: <Widget>[
          (label == null) ? Container() :
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(
                  label,
                  style: new TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              (label == null) ? Container() :
              new Divider(height: 0.0),
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(
                  value,
                  style: style
                ),
              )
            ],
          ),
      color: color,
    );
  }
}