import 'package:chat_app/all_users_screen.dart';
import 'package:chat_app/models/user_details.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  DocumentReference _documentReference;
  UserDetails _userDetails = UserDetails();
  var mapData = Map<String, String>();
  String uid;

  Future<FirebaseUser> signIn() async {
    GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentication =
        await _signInAccount.authentication;

    AuthCredential authCredential = GoogleAuthProvider.getCredential(
        idToken: _signInAuthentication.idToken,
        accessToken: _signInAuthentication.accessToken);

    FirebaseUser user =
        await _firebaseAuth.signInWithCredential(authCredential);
    return user;
  }

  void addDataToDb(FirebaseUser user) {
    _userDetails.name = user.displayName;
    _userDetails.emailId = user.email;
    _userDetails.photoUrl = user.photoUrl;
    _userDetails.uid = user.uid;
    mapData = _userDetails.toMap(_userDetails);

    uid = user.uid;

    _documentReference = Firestore.instance.collection("users").document(uid);

    _documentReference.get().then((documentSnapshot) {
      if (documentSnapshot.exists) {
        Navigator.pushReplacement(context,
            new MaterialPageRoute(builder: (context) => AllUsersScreen()));
      } else {
        _documentReference.setData(mapData).whenComplete(() {
          print("Users Colelction added to Database");
          Navigator.pushReplacement(context,
              new MaterialPageRoute(builder: (context) => AllUsersScreen()));
        }).catchError((e) {
          print("Error adding collection to Database $e");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('ChatApp'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to Chat App',
              style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
            ),
            RaisedButton(
              elevation: 8.0,
              padding: EdgeInsets.all(8.0),
              shape: StadiumBorder(),
              textColor: Colors.black,
              color: Colors.lime,
              child: Text('Sign In'),
              splashColor: Colors.red,
              onPressed: () {
                signIn().then((FirebaseUser user) {
                  addDataToDb(user);
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
