import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DataCard extends StatelessWidget {
  String label;
  final double number;
  TextStyle style;
  Color color;
  bool compact;

  DataCard({
    this.label,
    @required this.number,
    this.style,
    this.color,
    this.compact
  });

  @override
  Widget build(BuildContext context) {
    NumberFormat numFormat = new NumberFormat();
    NumberFormat numFormatCompact = new NumberFormat.compact();
    if(compact == null)
      compact = false;
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
                  compact ?
                  "\$"+numFormatCompact.format(number) :
                  "\$"+numFormat.format(number),
                  style: style
                ),
              )
            ],
          ),
      color: color,
    );
  }
}