import 'package:debt_bomb/data_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final Map<String,dynamic> saveGame;

  HomePage(this.saveGame);

  @override
  _HomePageState createState() => new _HomePageState(saveGame);
}

class _HomePageState extends State<HomePage> {
  Map<String,dynamic> saveGame;
  int _debt = 21000000000000;
  int _revenue = 3100000000000;
  int _expenditures = 3954000000000;
  Map<String,double> rates;
  int _debtSliderValue = 2;
  bool _debtBuy = false;

  _HomePageState(this.saveGame);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Column(
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      "Jan. 2019",
                      textAlign: TextAlign.left,
                      style: new TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            new DataCard(
              label: "National Debt",
              number: saveGame['debt'],
              style: new TextStyle(
                color: Colors.red,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new DataCard(
                    label: "Revenue",
                    number: _revenue,
                    style: new TextStyle(
                      color: Colors.green,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    compact: true,
                  ),
                ),
                new Expanded(
                  child: new DataCard(
                    number: _revenue-_expenditures,
                    style: new TextStyle(
                      color: Colors.red,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    compact: true,
                  ),
                ),
                new Expanded(
                  child: new DataCard(
                    label: "Expenditures",
                    number: _expenditures,
                    style: new TextStyle(
                      color: Colors.red,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    compact: true,
                  ),
                ),
              ],
            ),
            new Card(
              child: new Column(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      "Debt Manager",
                      style: new TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  new Divider(height: 0.0),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new Text(
                        _debtSliderValue.toString()+"B",
                        style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      new Slider(
                          value: _debtSliderValue.toDouble(),
                          divisions: 12,
                          min: 2.0,
                          max: 50.0,
                          onChanged: (value) {
                            setState(() {
                              _debtSliderValue = value.round();
                            });
                          }
                      ),
                    ],
                  ),
                  new Divider(height: 0.0),
                  new Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new SizedBox(
                          width: 70.0,
                          child: new Text(
                            "Maturity",
                            style: new TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        new SizedBox(
                          width: 40.0,
                          child: new Text(
                            "Rate",
                            style: new TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        new Switch(
                          value: _debtBuy,
                          onChanged: (value) {
                            setState(() {
                              _debtBuy = value;
                            });
                          }
                        ),
                      ],
                    ),
                  ),
                  new Divider(height: 0.0),
                  new TreasuryNote(name: "1 Month Note", id: "1m", rate: 1.40, buy: _debtBuy),
                  new TreasuryNote(name: "6 Month Note", id: "6m", rate: 1.66, buy: _debtBuy),
                  new TreasuryNote(name: "1 Year Note", id: "1y", rate: 2.07, buy: _debtBuy),
                  new TreasuryNote(name: "2 Year Note", id: "2y", rate: 2.68, buy: _debtBuy),
                  new TreasuryNote(name: "5 Month Note", id: "5y", rate: 2.98, buy: _debtBuy),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TreasuryNote extends StatelessWidget {
  final String name;
  final String id;
  final double rate;
  final bool buy;

  TreasuryNote({
    @required this.name,
    @required this.id,
    @required this.rate,
    @required this.buy
  });

  @override
  Widget build(BuildContext context) {
    NumberFormat numFormat = new NumberFormat("##.00","en-us");
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new SizedBox(
          width: 100.0,
          child: new Text(
            name,
            style: new TextStyle(
              fontSize: 16.0,
              //fontWeight: FontWeight.bold,
            ),
          ),
        ),
        new SizedBox(
          width: 50.0,
          child: new Text(
            numFormat.format(rate)+"%",
            style: new TextStyle(
              fontSize: 16.0,
              //fontWeight: FontWeight.bold,
            ),
          ),
        ),
        buy ?
        new RaisedButton(
            child: new Text("BUY"),
            onPressed: () {}
        ) :
        new RaisedButton(
            child: new Text("SELL"),
            onPressed: () {}
        )
      ],
    );
  }
}