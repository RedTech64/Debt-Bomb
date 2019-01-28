import 'package:flutter/material.dart';
import 'policy _dialog.dart';
import 'dart:async';
import 'main_game_view.dart';
import 'sign_in.dart';
import 'package:intl/intl.dart';

class PolicyPage extends StatefulWidget {
  final UserDetails userDetails;
  final Map<String,dynamic> saveGame;
  final String type;

  PolicyPage({
    @required this.userDetails,
    @required this.saveGame,
    @required this.type
  });

  _PolicyPageState createState() => new _PolicyPageState(userDetails: userDetails, saveGame: saveGame, type: type);
}

class _PolicyPageState extends State<PolicyPage> {
  UserDetails userDetails;
  Map<String,dynamic> saveGame;
  String type;

  _PolicyPageState({
    @required this.userDetails,
    @required this.saveGame,
    @required this.type
  });

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Column(
        children: _buildPolicyCards(),
      ),
    );
  }

  List<Widget> _buildPolicyCards() {
    List<Widget> list = <Widget>[];
    Map<String,dynamic> policies = saveGame['policies'];
    policies.forEach((id,data) {
      if(data['enabled'] && data['type'] == type) {
        list.add(
          new Card(
            child: new InkWell(
              child: new Row(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      data['name'],
                      style: new TextStyle(
                        fontSize: 24.0,
                        //fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () async {
                PolicyEditDialogResult result = await _openPolicyEditDialog(context, id, data);
                if (result != null) {
                  saveGame['policies'][id] = result.policyData;
                  calculatePolicy(id, saveGame);
                  uploadSaveGame(userDetails, saveGame);
                  if(result.delete) {
                    saveGame['policies'][id]['enabled'] = false;
                  }
                }
              },
            ),
          ),
        );
      }
    });
    return list;
  }

  Future _openPolicyEditDialog(context,id,policyData) async {
    return await Navigator.of(context).push(new MaterialPageRoute<PolicyEditDialogResult>(
        builder: (BuildContext context) {
          return new PolicyEditDialog(id: id,policyData: policyData, edit: true);
        }));
  }
}

