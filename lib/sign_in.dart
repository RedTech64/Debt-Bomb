import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'game_menu.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => new _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _fAuth = FirebaseAuth.instance;
  final GoogleSignIn _gSignIn = new GoogleSignIn();

  Future<FirebaseUser> _signIn() async {
    GoogleSignInAccount googleSignInAccount = await _gSignIn.signInSilently();
    print('SIGN IN ATTEMPT 1');
    if(googleSignInAccount.id == null)
      googleSignInAccount = await _gSignIn.signIn();
    GoogleSignInAuthentication authentication =
    await googleSignInAccount.authentication;
    print('SIGN IN ATTEMPT 2');
    FirebaseUser user = await _fAuth.signInWithGoogle(
      idToken: authentication.idToken,
      accessToken: authentication.accessToken);
    print('SIGN IN ATTEMPT 3');
    UserDetails details = new UserDetails(
      user.providerId,
      user.uid,
      user.displayName,
      user.email
    );
    DocumentSnapshot userDoc = await Firestore.instance.collection('users').document(details.uid).get();
    print('SIGN IN ATTEMPT 4');
    if(userDoc.exists)
      await Firestore.instance.collection('users').document(details.uid).updateData({
        'name': details.displayName,
        'email': details.email,
        'uid': details.uid
      });
    else
      await Firestore.instance.collection('users').document(details.uid).setData({
        'name': details.displayName,
        'email': details.email,
        'uid': details.uid
      });


    print("User Name : ${user.displayName}");
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new MainMenuPage(userDetails: details),
      ),
    );
    return user;
  }

  void _signOut() {
    _gSignIn.signOut();
    print('Signed out');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Container(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Text(
                "Debt Bomb",
                style: new TextStyle(
                    fontSize: 72.0,
                    fontWeight: FontWeight.bold
                ),
              ),
              new RaisedButton(
                onPressed: () {
                  _signIn()
                    .then((FirebaseUser user) => print(user))
                    .catchError((e) => print(e));
                },
                child: new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Text(
                    "Sign in with Google",
                    style: new TextStyle(
                      fontSize: 32.0,
                    ),
                  ),
                ),
                color: Colors.redAccent,
              ),
            ],
          ),
        )
      ),
    );
  }
}

class UserDetails {
  final String providerId;
  final String uid;
  final String displayName;
  final String email;

  UserDetails(this.providerId,this.uid,this.displayName,this.email);
}