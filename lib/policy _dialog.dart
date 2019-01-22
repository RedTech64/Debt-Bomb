import 'package:flutter/material.dart';
import 'dart:async';
import 'main_game_view.dart';
import 'sign_in.dart';
import 'dart:convert';

class PolicyDialog extends StatelessWidget {
  final Map<String,dynamic> saveGame;

  PolicyDialog({
    @required this.saveGame,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Add Policy"),
      ),
      body: new SingleChildScrollView(
        child: new Center(
          child: new Column(
            children: _buildPolicyCards(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPolicyCards(context) {
    List<Widget> cardList = <Widget>[];
    Map<String,dynamic> policies = saveGame['policies'];
    policies.forEach((id,data) {
      cardList.add(
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
              PolicyEditDialogResult result = await _openPolicyAddDialog(context,id,policies[id]);
              if(result != null) {
                result.policyData['enabled'] = true;
                Navigator.pop(context, result);
              }
            },
          ),
        ),
      );
    });
    return cardList;
  }

  Future _openPolicyAddDialog(context,id,policyData) async {
    return await Navigator.of(context).push(new MaterialPageRoute<PolicyEditDialogResult>(
      builder: (BuildContext context) {
        return new PolicyEditDialog(id: id,policyData: policyData);
      }));
  }
}

class PolicyEditDialog extends StatefulWidget {
  final String id;
  final Map<String,dynamic> policyData;

  PolicyEditDialog({
    @required this.id,
    @required this.policyData
  });

  @override
  _PolicyEditDialogState createState() => _PolicyEditDialogState(id: id, policyData: policyData);
}

class _PolicyEditDialogState extends State<PolicyEditDialog> {
  String id;
  Map<String,dynamic> policyData;
  Map<String,dynamic> newPolicyData;

  _PolicyEditDialogState({
    @required this.id,
    @required this.policyData
  });

  @override
  void initState() {
    JsonEncoder jsonEncoder = new JsonEncoder();
    JsonDecoder jsonDecoder = new JsonDecoder();
    newPolicyData = jsonDecoder.convert(jsonEncoder.convert(policyData));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Edit Policy"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.delete),
            onPressed: () {
              Navigator.pop(context,new PolicyEditDialogResult(id,newPolicyData, true));
            }
          ),
          new IconButton(
            icon: new Icon(Icons.add),
            onPressed: () {
              Navigator.pop(context,new PolicyEditDialogResult(id,newPolicyData, false));
            }
          ),
        ],
      ),
      body: new Center(
        child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            children: <Widget>[
              new Card(
                child: new Column(
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(
                        policyData['name'],
                        style: new TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    new Divider(height: 0.0),
                    new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(
                        policyData['description'],
                        style: new TextStyle(
                            fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              new Column(
                children: _buildSliderOptions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSliderOptions() {
    List<Widget> list = <Widget>[];
    Map<dynamic,dynamic> sliderSettings = newPolicyData['sliderSettings'];
    sliderSettings.forEach((id,setting) {
      list.add(
        new Card(
          child: new Column(
            children: <Widget>[
              new Text(
                setting['name'],
                style: new TextStyle(
                  fontSize: 16.0,
                ),
              ),
              new Divider(height: 0.0),
              new Text(
                setting['description'],
                style: new TextStyle(
                  fontSize: 16.0,
                ),
              ),
              new Slider(
                value: setting['setting'].toDouble(),
                min: setting['min'].toDouble(),
                max: setting['max'].toDouble(),
                onChanged: (value) {
                  setState(() {
                    newPolicyData['sliderSettings'][id]['setting'] = value.round();
                  });
                }
              ),
            ],
          ),
      ));
    });
    return list;
  }
}

class PolicyEditDialogResult {
  final String id;
  final Map<String,dynamic> policyData;
  final bool delete;

  PolicyEditDialogResult(this.id,this.policyData,this.delete);
}