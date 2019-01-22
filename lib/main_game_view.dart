import 'package:flutter/material.dart';
import 'home.dart';
import 'revenue.dart';
import 'sign_in.dart';
import 'policy _dialog.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainGameView extends StatefulWidget {
  final UserDetails userDetails;
  final Map<String,dynamic> saveGame;

  MainGameView({
    @required this.userDetails,
    @required this.saveGame
  });

  @override
  _MainGameViewState createState() => new _MainGameViewState(userDetails: userDetails,saveGame: saveGame);
}

class _MainGameViewState extends State<MainGameView> {
  final UserDetails userDetails;
  Map<String,dynamic> saveGame;
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
    _page = new HomePage(saveGame);
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
          setState(() {
            _pageIndex = index;
            switch(index) {
              case 0:
                _buttonColor = Colors.green;
                _page = new RevenuePage(userDetails: userDetails, saveGame: saveGame);
                _fab = new FloatingActionButton.extended(
                  icon: new Icon(Icons.add),
                  label: new Text("New Policy"),
                  onPressed: () {
                    _openPolicyDialog(context);
                  },
                );
                break;
              case 1:
                _buttonColor = Colors.black;
                _page = new HomePage(saveGame);
                _fab = null;
                break;
              case 2:
                _buttonColor = Colors.red;
                break;
            }
          });
        },
      ),
      floatingActionButton: _fab,
    );
  }

  Future _openPolicyDialog(context) async {
    PolicyEditDialogResult result = await Navigator.of(context).push(new MaterialPageRoute<PolicyEditDialogResult>(
        builder: (BuildContext context) {
          return new PolicyDialog(saveGame: saveGame);
      })
    );
    if(result != null) {
      saveGame['policies'][result.id] = result.policyData;
      await uploadSaveGame(userDetails,saveGame);
    }
  }
}

Future uploadSaveGame(userDetails,saveGame) {
  return Firestore.instance.collection('users').document(userDetails.uid).updateData({
    'saveGame': saveGame,
  });
}