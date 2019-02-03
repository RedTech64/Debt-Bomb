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
    return new SingleChildScrollView(
      child: Padding(
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
                        _getDate(),
                        textAlign: TextAlign.left,
                        style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  new DataCard(
                    number: saveGame['balance'].round().toDouble(),
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              new DataCard(
                label: "National Debt",
                number: saveGame['debt'].round().toDouble(),
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
                              divisions: 83,
                              min: 2.0,
                              max: 500.0,
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
                      padding: const EdgeInsets.all(0.0),
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
                            width: 45.0,
                            child: new Text(
                              "Rate",
                              style: new TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          new SizedBox(
                            width: 70.0,
                            child: new Text(
                              "Auto Sell",
                              textAlign: TextAlign.right,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDate() {
    int month = saveGame['month']%12;
    if(month == 0)
      month = 12;
    String textMonth;
    int year = ((saveGame['month']/12).floor())+2019;
    switch(month) {
      case 1:
        textMonth = "Jan."; break;
      case 2:
        textMonth = "Feb."; break;
      case 3:
        textMonth = "Mar."; break;
      case 4:
        textMonth = "Apr."; break;
      case 5:
        textMonth = "May."; break;
      case 6:
        textMonth = "Jun."; break;
      case 7:
        textMonth = "Jul."; break;
      case 8:
        textMonth = "Aug."; break;
      case 9:
        textMonth = "Sep."; break;
      case 10:
        textMonth = "Oct."; break;
      case 11:
        textMonth = "Nov."; break;
      case 12:
        textMonth = "Dec."; break;
    }
    return textMonth+" "+year.toString();
  }

  List<Widget> _buildDebtCards() {
    List<Widget> list = <Widget>[];
    Map treasuries = saveGame['treasuries'];
    treasuries.forEach((id,data) {
      list.add(
        new TreasuryNote(
          name: data['name'],
          id: id,
          rate: data['rate'].toDouble(),
          autoSell: data['autoSell'],
          buy: _debtBuy,
          onTap: () {
            borrow(id,_debtSliderValue,userDetails,saveGame);
            //uploadSaveGame(userDetails,saveGame);
            setState(() {});
          },
          onEditAuto: () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return new SimpleDialog(
                  title: new Text("Edit Auto Sell"),
                  children: <Widget>[new AutoSellDialogContext(id,data)],
                );
              }
            );
            setState(() {

            });
          },
        )
      );
    });
    return list;
  }
}

class TreasuryNote extends StatelessWidget {
  final String name;
  final String id;
  final double rate;
  final int autoSell;
  final bool buy;
  final VoidCallback onTap;
  final VoidCallback onEditAuto;

  TreasuryNote({
    @required this.name,
    @required this.id,
    @required this.rate,
    @required this.autoSell,
    @required this.buy,
    @required this.onTap,
    @required this.onEditAuto
  });

  @override
  Widget build(BuildContext context) {
    NumberFormat numFormat = new NumberFormat("#0.00","en-us");
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new SizedBox(
          width: 60.0,
          child: new Text(
            name,
            style: new TextStyle(
              fontSize: 16.0,
              //fontWeight: FontWeight.bold,
            ),
          ),
        ),
        new SizedBox(
          width: 55.0,
          child: new Text(
            numFormat.format(rate*100)+"%",
            style: new TextStyle(
              fontSize: 16.0,
              //fontWeight: FontWeight.bold,
            ),
          ),
        ),
        new InkWell(
          child: new SizedBox(
            width: 40.0,
            child: new Text(
              autoSell.toString()+"B",
              textAlign: TextAlign.center,
              style: new TextStyle(
                fontSize: 16.0,
                //fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: onEditAuto,
        ),
        buy ?
        new IconButton(icon: new Icon(Icons.cancel), onPressed: onTap) :
        new IconButton(icon: new Icon(Icons.add_circle), onPressed: onTap),
      ],
    );
  }
}

class AutoSellDialogContext extends StatefulWidget {
  final String id;
  final Map data;
  AutoSellDialogContext(this.id,this.data);

  @override
  _AutoSellDialogContextState createState() => new _AutoSellDialogContextState(this.id,this.data);
}

class _AutoSellDialogContextState extends State<AutoSellDialogContext> {
  final String id;
  final Map data;

  _AutoSellDialogContextState(this.id,this.data);

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new Slider(
          value: data['autoSell'].toDouble(),
          divisions: 40,
          min: 0.0,
          max: 200.0,
          onChanged: (value) {
            setState(() {
              data['autoSell'] = value.round();
            });
          }
        ),
        new SizedBox(
          width: 40.0,
          child: new Text(
            data['autoSell'].round().toString()+"B",
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}