import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data_card.dart';

class StatisticsPage extends StatefulWidget {
  final Map saveGame;

  StatisticsPage({
    @required this.saveGame,
  });

  @override
  _StatisticsPageState createState() => _StatisticsPageState(saveGame: this.saveGame);
}

class _StatisticsPageState extends State<StatisticsPage> {
  Map saveGame;
  String _menuValue = "Full Year";

  _StatisticsPageState({
    @required this.saveGame,
  });

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Stats Page"),
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            new DataCard(
              label: "Interest Payment",
              number: saveGame['interestDue'].toDouble(),
            ),
            new DropdownButton(
              value: _menuValue,
              items: <String>["Full Year","January","February","March","April","May","June","July","August","September","October","November","December"].map((value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _menuValue = value;
                });
              }
            ),
            new FittedBox(
              fit: BoxFit.fill,
              child: new DataTable(
                columns: <DataColumn>[
                  new DataColumn(label: new Text("Policy"),),
                  new DataColumn(label: new Text("Income")),
                  new DataColumn(label: new Text("Cost")),
                ],
                rows: _buildRows(),
              ),
            )
          ],
        )
      ),
    );
  }

  List<DataRow> _buildRows() {
    NumberFormat numFormatCompact = new NumberFormat.compact();
    List<DataRow> list = [];
    int time = _getTimeFrame();
    num incomeTotal = 0;
    num costTotal = 0;
    Map policies = saveGame['policies'];
    policies.forEach((id,policyData) {
      if(policyData['enabled']) {
        Map sliderSettings = policyData['sliderSettings'];
        sliderSettings.forEach((id, sliderData) {
          num amount = 0;
          if (time == -1) {
            for (int i = 1; i <= 12; i++) {
              amount += _getMonthAmount(i, sliderData);
            }
          } else {
            amount = _getMonthAmount(time, sliderData);
          }
          if (policyData['type'] == "revenue")
            incomeTotal += amount;
          else
            costTotal += amount;
          list.add(
              new DataRow(
                  cells: [
                    new DataCell(new Text(
                        policyData['name'] + "-" + sliderData['name'])),
                    (policyData['type'] == "revenue")
                        ?
                    new DataCell(new Text(numFormatCompact.format(amount)))
                        : new DataCell(new Text("")),
                    (policyData['type'] == "expenditure")
                        ?
                    new DataCell(new Text(numFormatCompact.format(amount)))
                        : new DataCell(new Text(""))
                  ]
              )
          );
        });
      }
    });
    list.add(
      new DataRow(
        cells: [
          new DataCell(new Text("Totals")),
          new DataCell(new Text(numFormatCompact.format(incomeTotal))),
          new DataCell(new Text(numFormatCompact.format(costTotal))),
        ],
      )
    );
    return list;
  }

  num _getMonthAmount(month,data) {
    num setting = data['setting'];
    if(data['percent']) {
      if(data['monthMultipliers'][month] == null)
        return data['sliderMultiplier']*data['defaultMultiplier']*(setting/100);
      return data['sliderMultiplier']*data['defaultMultiplier']*data['monthMultipliers'][month]*(setting/100);
    } else {
      if(data['monthMultipliers'][month] == null)
        return data['sliderMultiplier']*data['defaultMultiplier']*setting;
      return data['sliderMultiplier']*data['defaultMultiplier']*data['monthMultipliers'][month]*setting;
    }
  }

  int _getTimeFrame() {
    switch(_menuValue) {
      case "Full Year":
        return -1; break;
      case "January":
        return 0; break;
      case "February":
        return 1; break;
      case "March":
        return 2; break;
      case "April":
        return 3; break;
      case "May":
        return 4; break;
      case "June":
        return 5; break;
      case "July":
        return 6; break;
      case "August":
        return 7; break;
      case "September":
        return 8; break;
      case "October":
        return 9; break;
      case "November":
        return 10; break;
      case "December":
        return 11; break;
    }
  }
}