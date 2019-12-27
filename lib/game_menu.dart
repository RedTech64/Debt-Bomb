import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'main_game_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class MainMenuPage extends StatelessWidget {
  final UserDetails userDetails;

  MainMenuPage({
    @required this.userDetails,
  });

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              "Debt Bomb",
              style: new TextStyle(
                fontSize: 72.0,
                fontWeight: FontWeight.bold
              ),
            ),
            new SizedBox(
              height: 30.0,
            ),
            new SizedBox(
              width: 300.0,
              height: 200.0,
              child: new RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(48.0),
                ),
                child: new Text(
                  "Load Game",
                  style: new TextStyle(
                    fontSize: 32.0,
                  ),
                ),
                color: Colors.redAccent,
                onPressed: () {
                  _loadGame(context);
                },
              ),
            ),
            new SizedBox(
              height: 20.0,
            ),
            new SizedBox(
              width: 300.0,
              height: 200.0,
              child: new RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(48.0),
                ),
                child: new Text(
                  "New Game",
                  style: new TextStyle(
                    fontSize: 32.0,
                  ),
                ),
                color: Colors.redAccent,
                onPressed: () {
                  _newGame(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _loadGame(context) async {
    DocumentReference refSaveGame = Firestore.instance.collection('users').document(userDetails.uid);
    DocumentSnapshot saveGameDoc = await refSaveGame.get();
    Map saveGame = saveGameDoc.data['saveGame'];
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new MainGameView(userDetails: userDetails,saveGame: saveGame)));
  }

  Future _newGame(context) async {
    DocumentReference refDataRef = Firestore.instance.collection('reference').document('data');
    DocumentSnapshot refDoc = await refDataRef.get();
    CollectionReference collRef = refDataRef.collection('policies');
    QuerySnapshot collDocs = await collRef.getDocuments();
    List<DocumentSnapshot> policyDocs = collDocs.documents;
    Map<String,Map<String,dynamic>> policyList = new Map();
    policyDocs.forEach((DocumentSnapshot d) {
      policyList[d.documentID] = (d.data);
    });
    collRef = refDataRef.collection('debt');
    collDocs = await collRef.orderBy('months').getDocuments();
    List<DocumentSnapshot> debtDocs = collDocs.documents;
    Map<String,Map<String,dynamic>> debtList = new Map();
    debtDocs.forEach((DocumentSnapshot d) {
      debtList[d.documentID] = (d.data);
    });
    Map refData = refDoc.data;
    refData['policies'] = policyList;
    refData['treasuries'] = debtList;
    Firestore.instance.collection('users').document(userDetails.uid).updateData({
      'saveGame': refData,
    });
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new MainGameView(userDetails: userDetails,saveGame: refData)));
  }

}