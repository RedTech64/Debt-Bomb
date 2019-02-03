import 'package:flutter/material.dart';
import 'dart:async';
import 'main_game_view.dart';
import 'sign_in.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class PolicyDialog extends StatelessWidget {
  final Map saveGame;
  final String type;

  PolicyDialog({
    @required this.saveGame,
    @required this.type
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
    Map policies = saveGame['policies'];
    policies.forEach((id,data) {
      if(!data['enabled'] && data['type'] == type)
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
        return new PolicyEditDialog(id: id,policyData: policyData,edit: false);
      }));
  }
}

class PolicyEditDialog extends StatefulWidget {
  final String id;
  final Map policyData;
  final bool edit;

  PolicyEditDialog({
    @required this.id,
    @required this.policyData,
    @required this.edit
  });

  @override
  _PolicyEditDialogState createState() => _PolicyEditDialogState(id: id, policyData: policyData, edit: edit);
}

class _PolicyEditDialogState extends State<PolicyEditDialog> {
  String id;
  bool edit;
  Map policyData;
  Map newPolicyData;

  _PolicyEditDialogState({
    @required this.id,
    @required this.policyData,
    @required this.edit,
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
        title: edit ? new Text("Edit Policy") : new Text("Add Policy"),
        actions: <Widget>[
          edit  ?
          new FlatButton(
            child: new Text("REPEAL", style: new TextStyle(color: Colors.white)),
            onPressed: () {
              policyData['enabled'] = false;
              Navigator.pop(context,new PolicyEditDialogResult(id,newPolicyData, true));
            }
          ) : new Container(),
          new FlatButton(
            child: edit ? new Text("SAVE", style: new TextStyle(color: Colors.white)) : new Text("ADD", style: new TextStyle(color: Colors.white)),
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
    NumberFormat numFormatCompact = new NumberFormat.compact();
    List<Widget> list = <Widget>[];
    Map sliderSettings = newPolicyData['sliderSettings'];
    sliderSettings.forEach((id,setting) {
      list.add(
        new Card(
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(
                  setting['name'],
                  style: new TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
              new Divider(height: 0.0),
/*              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(
                  setting['description'],
                  style: new TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),*/
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.fromLTRB(8.0,8.0,0.0,8.0),
                    child: new Text(
                      setting['percent'] ? setting['setting'].toString()+"%" : "",
                    ),
                  ),
                  new Expanded(
                    child: new Padding(
                      padding: const EdgeInsets.fromLTRB(0.0,8.0,0.0,8.0),
                      child: new Slider(
                        value: setting['setting'].toDouble(),
                        min: setting['min'].toDouble(),
                        max: setting['max'].toDouble(),
                        onChanged: (value) {
                          setState(() {
                            newPolicyData['sliderSettings'][id]['setting'] = value.round();
                          });
                        }
                      ),
                    ),
                  ),
                  new SizedBox(
                    width: 50.0,
                    child: new Padding(
                      padding: const EdgeInsets.fromLTRB(0.0,8.0,8.0,8.0),
                      child: new Text(
                        numFormatCompact.format(_getYearlyAffect(id)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ));
    });
    return list;
  }

  double _getYearlyAffect(id) {
    Map monthMultipliers = newPolicyData['sliderSettings'][id]['monthMultipliers'];
    double sum = 0.0;
    num totalMult = 0;
    monthMultipliers.forEach((month,num) {
      totalMult += num*newPolicyData['sliderSettings'][id]['defaultMultiplier'];
    });
    totalMult += (newPolicyData['sliderSettings'][id]['defaultMultiplier'])*(12-monthMultipliers.length);
    print(totalMult);
    if(newPolicyData['sliderSettings'][id]['percent']) {
      sum += totalMult*(newPolicyData['sliderSettings'][id]['setting']/100)*newPolicyData['sliderSettings'][id]['sliderMultiplier'];
    } else {
      sum += totalMult*newPolicyData['sliderSettings'][id]['setting']*newPolicyData['sliderSettings'][id]['sliderMultiplier'];
    }
    return sum;
  }
}

class PolicyEditDialogResult {
  final String id;
  final Map policyData;
  final bool delete;

  PolicyEditDialogResult(this.id,this.policyData,this.delete);
}