import 'dart:async';
import 'dart:io';

import 'package:chat_app/chat_screen.dart';
import 'package:chat_app/home_page.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/user_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AllUsersScreen extends StatefulWidget {
  _AllUsersScreenState createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot> _subscription;
  List<DocumentSnapshot> usersList;
  final CollectionReference _collectionReference =
      Firestore.instance.collection("users");

  @override
  void initState() {
    super.initState();
    _subscription = _collectionReference.snapshots().listen((datasnapshot) {
      setState(() {
        usersList = datasnapshot.documents;
        print("Users List ${usersList.length}");
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("All Users"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                await firebaseAuth.signOut();
                await googleSignIn.disconnect();
                await googleSignIn.signOut();
                print("Signed Out");
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => MyApp()),
                    (Route<dynamic> route) => false);
              },
            )
          ],
        ),
        body: usersList != null
            ? Container(
                child: ListView.builder(
                  itemCount: usersList.length,
                  itemBuilder: ((context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(usersList[index].data['photoUrl']),
                      ),
                      title: Text(usersList[index].data['name'],
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                      subtitle: Text(usersList[index].data['emailId'],
                          style: TextStyle(
                            color: Colors.grey,
                          )),
                      onTap: (() {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                    name: usersList[index].data['name'],
                                    photoUrl: usersList[index].data['photoUrl'],
                                    receiverUid:
                                        usersList[index].data['uid'])));
                      }),
                    );
                  }),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }
}
