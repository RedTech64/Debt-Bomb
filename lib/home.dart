import 'package:debt_bomb/data_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main_game_view.dart';
import 'sign_in.dart';

class HomePage extends StatefulWidget {
  final UserDetails userDetails;
  final Map saveGame;

  HomePage({
    @required this.userDetails,
    @required this.saveGame
  });

  @override
  _HomePageState createState() => new _HomePageState(userDetails: userDetails,saveGame: saveGame);
}

class _HomePageState extends State<HomePage> {
  final UserDetails userDetails;
  Map saveGame;
  Map<String,double> rates;
  int _debtSliderValue = 2;
  bool _debtBuy = false;

  _HomePageState({
    @required this.userDetails,
    @required this.saveGame
  });

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
                new DataCard(
                  number: saveGame['balance'].toDouble(),
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            new DataCard(
              label: "National Debt",
              number: saveGame['debt'].toDouble(),
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
                    number: getRevenue(saveGame,saveGame['month']+1).toDouble(),
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
                    number: getRevenue(saveGame,saveGame['month']+1).toDouble()-getExpenditures(saveGame,saveGame['month']+1).toDouble(),
                    style: new TextStyle(
                      color: (getRevenue(saveGame,saveGame['month']+1)-getExpenditures(saveGame,saveGame['month']+1) < 0) ? Colors.red : Colors.green,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    compact: true,
                  ),
                ),
                new Expanded(
                  child: new DataCard(
                    label: "Expenditures",
                    number: getExpenditures(saveGame,saveGame['month']+1).toDouble(),
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
                      new Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Text(
                          _debtSliderValue.toString()+"B",
                          style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      new Expanded(
                        child: new Slider(
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
                  new Column(
                    children: _buildDebtCards(),
                  ),
/*                  new TreasuryNote(name: "1 Month Note", id: "1m", rate: 1.40, buy: _debtBuy),
                  new TreasuryNote(name: "6 Month Note", id: "6m", rate: 1.66, buy: _debtBuy),
                  new TreasuryNote(name: "1 Year Note", id: "1y", rate: 2.07, buy: _debtBuy),
                  new TreasuryNote(name: "2 Year Note", id: "2y", rate: 2.68, buy: _debtBuy),
                  new TreasuryNote(name: "5 Month Note", id: "5y", rate: 2.98, buy: _debtBuy),*/
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDebtCards() {
    List<Widget> list = <Widget>[];
    Map treasuries = saveGame['treasuries'];
    treasuries.forEach((id,data) {
      list.add(
        new TreasuryNote(
          name: data['name'],
          id: id,
          rate: data['rate'],
          buy: _debtBuy,
          onTap: () {
            _borrow(id,data['months'],data['rate']);
          },
        ));
    });
    return list;
  }

  void _borrow(String id,months,rate) {
    Map debt = saveGame['debtData'];
    String monthDue = (saveGame['month']+months).toString();
    int amount = _debtSliderValue*1000000000;
    if(debt[monthDue] == null) {
      debt[monthDue] = [];
    }
    List list = debt[monthDue];
    list.add({
      'id': id,
      'amount': amount,
      'rate': rate,
    });
    saveGame['treasuries'][id]['sold'] += _debtSliderValue;
    saveGame['treasuries'][id]['rate'] = calculateRate(saveGame,id);
    saveGame['balance'] += amount;
    saveGame['debt'] += amount+(amount*rate);
    saveGame['interestDue'] += (amount*rate)/months;
    setState(() {});
    uploadSaveGame(userDetails,saveGame);
  }
}

class TreasuryNote extends StatelessWidget {
  final String name;
  final String id;
  final double rate;
  final bool buy;
  final VoidCallback onTap;

  TreasuryNote({
    @required this.name,
    @required this.id,
    @required this.rate,
    @required this.buy,
    @required this.onTap
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
            numFormat.format(rate*100)+"%",
            style: new TextStyle(
              fontSize: 16.0,
              //fontWeight: FontWeight.bold,
            ),
          ),
        ),
        buy ?
        new RaisedButton(
            child: new Text("BUY"),
            onPressed: onTap
        ) :
        new RaisedButton(
            child: new Text("SELL"),
            onPressed: onTap
        )
      ],
    );
  }
}