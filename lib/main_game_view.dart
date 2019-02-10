import 'package:flutter/material.dart';
import 'home.dart';
import 'policy_page.dart';
import 'sign_in.dart';
import 'policy _dialog.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'stats.dart';

class MainGameView extends StatefulWidget {
  final UserDetails userDetails;
  final Map saveGame;

  MainGameView({
    @required this.userDetails,
    @required this.saveGame
  });

  @override
  _MainGameViewState createState() => new _MainGameViewState(userDetails: userDetails,saveGame: saveGame);
}

class _MainGameViewState extends State<MainGameView> {
  final UserDetails userDetails;
  Map saveGame;
  int _pageIndex = 1;
  Color _buttonColor = Colors.black;
  Widget _page;
  Widget _fab = null;

  _MainGameViewState({
    @required this.userDetails,
    @required this.saveGame
  });

  @override
  void initState() {
    super.initState();
    _setPage(1);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Debt Bomb"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.insert_chart),
            onPressed: () {
              Navigator.push(context, new MaterialPageRoute(builder: (context) => new StatisticsPage(saveGame: saveGame)));
            }),
          new IconButton(
              icon: new Icon(Icons.save),
              onPressed: () {
                uploadSaveGame(userDetails, saveGame);
              }),
        ],
      ),
      body: _page,
      bottomNavigationBar: new BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), title: Text('Revenue')),
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), title: Text('Spending')),
        ],
        currentIndex: _pageIndex,
        fixedColor: _buttonColor,
        onTap: (index) {
          _setPage(index);
        },
      ),
      floatingActionButton: _fab,
    );
  }

  void _setPage(index) {
    setState(() {
      _pageIndex = index;
      switch(index) {
        case 0:
          _buttonColor = Colors.green;
          _page = new PolicyPage(userDetails: userDetails, saveGame: saveGame,type: "revenue");
          _fab = new FloatingActionButton.extended(
            icon: new Icon(Icons.add),
            label: new Text("New Policy"),
            onPressed: () {
              _openPolicyDialog(context,"revenue");
            },
          );
          break;
        case 1:
          _buttonColor = Colors.black;
          _page = new HomePage(userDetails: userDetails,saveGame: saveGame);
          _fab = new FloatingActionButton.extended(
            icon: new Icon(Icons.arrow_right),
            label: new Text("Next Turn"),
            onPressed: () {
              _nextTurn();
            },
          );
          break;
        case 2:
          _buttonColor = Colors.red;
          _page = new PolicyPage(userDetails: userDetails, saveGame: saveGame,type: "expenditure");
          _fab = new FloatingActionButton.extended(
            icon: new Icon(Icons.add),
            label: new Text("New Policy"),
            onPressed: () {
              _openPolicyDialog(context,"expenditure");
            },
          );
          break;
      }
    });
  }

  void _nextTurn() {
    saveGame['month'] += 1;
    saveGame['balance'] += getRevenue(saveGame, saveGame['month']);
    saveGame['balance'] -= getExpenditures(saveGame, saveGame['month']);
    saveGame['debt'] -= saveGame['interestDue'];
    if(saveGame['debtData'][(saveGame['month']).toString()] != null) {
      List debtData = saveGame['debtData'][(saveGame['month']).toString()];
      debtData.forEach((map) {
        saveGame['interestDue'] -= (map['amount']*map['rate']).round()/saveGame['treasuries'][map['id']]['months'];
        saveGame['debt'] -= map['amount'];
        saveGame['treasuries'][map['id']]['sold'] -= map['amount']/1000000000;
        if(saveGame['treasuries'][map['id']]['resell'])
          saveGame['treasuries'][map['id']]['resellAmount'] += map['amount']/1000000000;
      });
      saveGame['debtData'][(saveGame['month']).toString()] = null;
    }
    Map treasuries = saveGame['treasuries'];
    treasuries.forEach((id,data) {
      if(data['appetite'] >= 0 && data['rate'] > 0)
        if(data['rate'] > 1)
          saveGame['treasuries'][id]['rate'] = data['rate']/2;
        else
          saveGame['treasuries'][id]['rate'] -= ((data['appetite']+data['monthlyAppetite']/data['monthlyAppetite'])*pow((data['rate']),2))/100;
      if(data['rate'] < 0)
        treasuries[id]['rate'] = 0.0;
      if(data['rate'] >= 1)
        treasuries[id]['monthlyAppetite'] = data['baseAppetite'] + (data['rate']*100)/5;
      else
        treasuries[id]['monthlyAppetite'] = data['baseAppetite'] + (data['rate']*100)*pow(100-(data['rate']*100), 0.5)*(10-(saveGame['debt']/saveGame['gdp']))/8;
      treasuries[id]['appetite'] = data['monthlyAppetite'];
      if(data['autoSell'] > 0 || data['resellAmount'] > 0)
        borrow(id,data['autoSell']+data['resellAmount'],userDetails,saveGame);
      treasuries[id]['resellAmount'] = 0;
    });
    if((saveGame['interestDue'] > 0 && saveGame['interestDue'] < 100) || (saveGame['interestDue'] < 0 && saveGame['interestDue'] > -100)) {
      saveGame['interestDue'] = 0;
    }
    setState(() {
      _page = new HomePage(userDetails: userDetails, saveGame: saveGame);
    });
    //uploadSaveGame(userDetails, saveGame);
  }

  Future _openPolicyDialog(context,type) async {
    PolicyEditDialogResult result = await Navigator.of(context).push(new MaterialPageRoute<PolicyEditDialogResult>(
        builder: (BuildContext context) {
          return new PolicyDialog(saveGame: saveGame,type: type);
      })
    );
    if(result != null) {
      saveGame['policies'][result.id] = result.policyData;
      calculatePolicy(result.id, saveGame);
      uploadSaveGame(userDetails, saveGame);
    }
  }
}

Future uploadSaveGame(userDetails,saveGame) {
  return Firestore.instance.collection('users').document(userDetails.uid).updateData({
    'saveGame': saveGame,
  });
}

void borrow(String id,amountInBillions,userDetails,saveGame) {
  Map debt = saveGame['debtData'];
  String monthDue = (saveGame['month']+saveGame['treasuries'][id]['months']).toString();
  num amount = amountInBillions*1000000000;
  if(debt[monthDue] == null) {
    debt[monthDue] = [];
  }
  List list = new List.from(debt[monthDue]);
  list.add({
    'id': id,
    'amount': amount,
    'rate': saveGame['treasuries'][id]['rate'],
  });
  debt[monthDue]= list;
  saveGame['balance'] += amount;
  saveGame['debt'] += amount+(amount*saveGame['treasuries'][id]['rate']).round();
  saveGame['interestDue'] += (amount*saveGame['treasuries'][id]['rate']).round()/saveGame['treasuries'][id]['months'];
  saveGame['treasuries'][id]['sold'] += amountInBillions;
  saveGame['treasuries'][id]['appetite'] -= amountInBillions;
  saveGame['treasuries'][id]['rate'] = calculateRate(saveGame,id,amount);
}

void calculatePolicy(id,saveGame) {
  Map policies = saveGame['policies'];
  policies.forEach((id,data) {
    List amount = [0,0,0,0,0,0,0,0,0,0,0,0];
    if(data['enabled']) {
      Map settings = policies[id]['sliderSettings'];
      settings.forEach((id,data) {
        Map monthMultipliers = data['monthMultipliers'];
        print(monthMultipliers);
        for(int i = 1; i <= 12; i++) {
          if(monthMultipliers[i.toString()] == null) {
            if(data['percent']) {
              amount[i-1] += (data['setting']/100)*data['defaultMultiplier']*data['sliderMultiplier'];
            } else {
              amount[i-1] += data['setting']*data['defaultMultiplier']*data['sliderMultiplier'];
            }
          } else {
            if(data['percent']) {
              amount[i-1] += (data['setting']/100)*data['defaultMultiplier']*monthMultipliers[i.toString()]*data['sliderMultiplier'];
            } else {
              amount[i-1] += data['setting']*data['defaultMultiplier']*monthMultipliers[i.toString()]*data['sliderMultiplier'];
            }
          }
        }
      });
    }
    if(policies[id]['type'] == "revenue") {
      policies[id]['income'] = amount;
    } else if(policies[id]['type'] == "expenditure") {
      policies[id]['cost'] = amount;
    }
  });
}

double calculateRate(saveGame,id,amount) {
  Map treasury = saveGame['treasuries'][id];
  if(treasury['appetite'] >= 0)
    return treasury['rate'];
  else
    return treasury['rate'] += (((treasury['appetite']*-1)+treasury['monthlyAppetite']/treasury['monthlyAppetite'])/10000)*amount/1000000000000;
}

double getRevenue(saveGame,month) {
  month = (month%12);
  if(month == 0)
    month = 12;
  double sum = 0.0;
  Map policies = saveGame['policies'];
  policies.forEach((id,data) {
    if(data['type'] == "revenue" && data['enabled'] == true) {
      if(data['income'] == null) {
        calculatePolicy(id,saveGame);
      }
      sum += data['income'][month-1];
    }
  });
  return sum;
}

double getExpenditures(saveGame,time) {
  int month = (time%12);
  if(month == 0)
    month = 12;
  double sum = 0.0;
  Map policies = saveGame['policies'];
  policies.forEach((id,data) {
    if(data['type'] == "expenditure" && data['enabled'] == true) {
      if(data['cost'] == null) {
        calculatePolicy(id,saveGame);
      }
      sum += data['cost'][month-1];
    }
  });
  sum += saveGame['interestDue'];
  if(saveGame['debtData'][time.toString()] != null) {
    List treasuries = saveGame['debtData'][time.toString()];
    treasuries.forEach((map) {
      sum += map['amount'];
    });
  }
  return sum;
}