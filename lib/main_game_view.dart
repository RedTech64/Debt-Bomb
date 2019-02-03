import 'package:flutter/material.dart';
import 'home.dart';
import 'policy_page.dart';
import 'sign_in.dart';
import 'policy _dialog.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

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
    saveGame['balance'] += getRevenue(saveGame, saveGame['month']+1);
    saveGame['balance'] -= getExpenditures(saveGame, saveGame['month']+1);
    if(saveGame['debtData'][(saveGame['month']+1).toString()] != null) {
      List treasuries = saveGame['debtData'][(saveGame['month']+1).toString()];
      treasuries.forEach((map) {
        saveGame['interestDue'] -= (map['amount']*map['rate'])/saveGame['treasuries'][map['id']]['months'];
        saveGame['debt'] -= (map['amount']*map['rate'])+map['amount'];
        saveGame['treasuries'][map['id']]['sold'] -= map['amount']/1000000000;
        saveGame['treasuries'][map['id']]['rate'] = calculateRate(saveGame, map['id']);
      });
      saveGame['debtData'][(saveGame['month']+1).toString()] = null;
    }
    if((saveGame['interestDue'] > 0 && saveGame['interestDue'] < 100) || (saveGame['interestDue'] < 0 && saveGame['interestDue'] > -100)) {
      saveGame['interestDue'] = 0;
    }
    saveGame['month'] += 1;
    setState(() {
      _page = new HomePage(userDetails: userDetails, saveGame: saveGame);
    });
    uploadSaveGame(userDetails, saveGame);
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
  if(treasury['sold'] > treasury['appetite'])
    return treasury['rate'] += ((treasury['sold']/treasury['appetite'])/10000)*amount/1000000000;
  else
    return treasury['rate'].toDouble();
  //return 1/(1+treasury['shift']*pow(e,-.01*treasury['sold']));
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