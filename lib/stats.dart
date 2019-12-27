import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data_card.dart';
import 'main_game_view.dart';

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
    NumberFormat numFormat = new NumberFormat();
    NumberFormat numFormatCompact = new NumberFormat.compact();
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Stats Page"),
      ),
      body: new Center(
        child: new SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              new Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Text("Next Month:"),
                ),
              ),
              new Row(
                children: <Widget>[
                  new Expanded(
                    child: new DataCard(
                      label: "Revenue",
                      value: numFormatCompact.format(getRevenue(saveGame,saveGame['month']+1)),
                      style: new TextStyle(
                        color: Colors.green,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  new Expanded(
                    child: new DataCard(
                      label: "Expenditures",
                      value: numFormatCompact.format(getExpenditures(saveGame,saveGame['month']+1)),
                      style: new TextStyle(
                        color: Colors.red,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              new Row(
                children: <Widget>[
                  new Expanded(
                    child: new DataCard(
                      label: "Deficit",
                      value: numFormatCompact.format(getRevenue(saveGame,saveGame['month']+1).toDouble()-getExpenditures(saveGame,saveGame['month']+1)),
                      style: new TextStyle(
                        color: (getRevenue(saveGame,saveGame['month']+1)-getExpenditures(saveGame,saveGame['month']+1) < 0) ? Colors.red : Colors.green,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  new Expanded(
                    child: new DataCard(
                      label: "Debt Due",
                      value: numFormatCompact.format(getDebtDue(saveGame,saveGame['month']+1).toDouble()),
                      style: new TextStyle(
                        color: Colors.red,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  new Expanded(
                    child: new DataCard(
                      label: "Total Deficit",
                      value: numFormatCompact.format(getRevenue(saveGame,saveGame['month']+1).toDouble()-getExpenditures(saveGame,saveGame['month']+1)-getDebtDue(saveGame,saveGame['month']+1)),
                      style: new TextStyle(
                        color: (getRevenue(saveGame,saveGame['month']+1)-getExpenditures(saveGame,saveGame['month']+1)-getDebtDue(saveGame,saveGame['month']+1) < 0) ? Colors.red : Colors.green,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              new Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Text("Yearly:"),
                ),
              ),
              new Row(
                children: <Widget>[
                  new Expanded(
                    child: new DataCard(
                      label: "Revenue",
                      value: numFormatCompact.format(_getYearlyRevenue()),
                      style: new TextStyle(
                        color: Colors.green,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  new Expanded(
                    child: new DataCard(
                      label: "Expenditures",
                      value: numFormatCompact.format(_getYearlyExpenditure()),
                      style: new TextStyle(
                        color: Colors.red,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
              new Card(
                child: new FittedBox(
                  fit: BoxFit.fill,
                  child: new DataTable(
                    columns: <DataColumn>[
                      new DataColumn(label: new Text("Policy")),
                      new DataColumn(label: new Text("Income")),
                      new DataColumn(label: new Text("Cost")),
                    ],
                    rows: _buildPolicyRows(),
                  ),
                ),
              ),
              new Card(
                child: new FittedBox(
                  fit: BoxFit.fill,
                  child: new DataTable(
                    columns: <DataColumn>[
                      new DataColumn(label: new Text("Maturity")),
                      new DataColumn(label: new Text("Amount")),
                      new DataColumn(label: new Text("Percent")),
                    ],
                    rows: _buildDebtRows(),
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }

  num _getYearlyRevenue() {
    num total = 0;
    for(int i = 1; i <= 12; i++) {
      total += getRevenue(saveGame, i);
    }
    return total;
  }

  num _getYearlyExpenditure() {
    num total = 0;
    for(int i = 1; i <= 12; i++) {
      total += getExpenditures(saveGame, i);
    }
    return total;
  }

  List<DataRow> _buildPolicyRows() {
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
                    new DataCell(new Text("\$"+numFormatCompact.format(amount)))
                        : new DataCell(new Text("")),
                    (policyData['type'] == "expenditure")
                        ?
                    new DataCell(new Text("\$"+numFormatCompact.format(amount)))
                        : new DataCell(new Text(""))
                  ]
              )
          );
        });
      }
    });
    num interest = 0;
    if(time == -1)
      interest = saveGame['interestDue']*12;
    else
      interest = saveGame['interestDue'];
    list.add(
        new DataRow(
          cells: [
            new DataCell(new Text("Interest Payment")),
            new DataCell(new Text("")),
            new DataCell(new Text("\$"+numFormatCompact.format(interest))),
          ],
        )
    );
    list.add(
      new DataRow(
        cells: [
          new DataCell(new Text("Totals")),
          new DataCell(new Text(numFormatCompact.format(incomeTotal))),
          new DataCell(new Text(numFormatCompact.format(costTotal+interest))),
        ],
      )
    );
    return list;
  }

  List<DataRow> _buildDebtRows() {
    NumberFormat numFormatCompact = new NumberFormat();
    NumberFormat numFormat = new NumberFormat("#0.00","en-us");
    List<DataRow> rows = [];
    Map treasuryData = saveGame['treasuries'];
    num sum = 0;
    treasuryData.forEach((id,data) {
        sum += data['sold'];
      }
    );
    treasuryData.forEach((id,data) {
      rows.add(
        new DataRow(
          cells: [
            new DataCell(new Text(data['name'])),
            new DataCell(new Text(numFormatCompact.format(data['sold'])+"B")),
            new DataCell(new Text(numFormat.format(data['sold']*100/sum).toString()+"%")),
          ]
        )
      );
    });
    return rows;
  }

  num _getMonthAmount(month,data) {
    num setting = data['setting'];
    if(data['percent']) {
      if(data['monthMultipliers'][month.toString()] == null)
        return data['sliderMultiplier']*data['defaultMultiplier']*(setting/100);
      return data['sliderMultiplier']*data['defaultMultiplier']*data['monthMultipliers'][month.toString()]*(setting/100);
    } else {
      if(data['monthMultipliers'][month.toString()] == null)
        return data['sliderMultiplier']*data['defaultMultiplier']*setting;
      return data['sliderMultiplier']*data['defaultMultiplier']*data['monthMultipliers'][month.toString()]*setting;
    }
  }

  int _getTimeFrame() {
    switch(_menuValue) {
      case "Full Year":
        return -1; break;
      case "January":
        return 1; break;
      case "February":
        return 2; break;
      case "March":
        return 3; break;
      case "April":
        return 4; break;
      case "May":
        return 5; break;
      case "June":
        return 6; break;
      case "July":
        return 7; break;
      case "August":
        return 8; break;
      case "September":
        return 9; break;
      case "October":
        return 10; break;
      case "November":
        return 11; break;
      case "December":
        return 12; break;
    }
  }
}