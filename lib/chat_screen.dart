import 'package:chat_app/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  String name;
  String photoUrl;
  String receiverUid;
  ChatScreen({this.name, this.photoUrl, this.receiverUid});

  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Message _message;
  List<Message> _messagesList = List<Message>();
  var map = Map<String, dynamic>();
  DocumentReference _documentReference;
  DocumentSnapshot documentSnapshot;
  CollectionReference _collectionReference;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  var _senderuid;

  StreamSubscription<DocumentSnapshot> subscription;

  TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    // subscription = _documentReference.snapshots().listen((dataSnapshot) {
    //   if (dataSnapshot.exists) {
    //     setState(() {
    //       _message = _message.fromMap(dataSnapshot.data);
    //     });
    //   }
    // });
  }

  @override
    void dispose() {
      super.dispose();
      subscription?.cancel();
    }

  void addMessageToDb(Message message) {
    print("Message : ${message.message}");
    map = message.toMap();

    print("Map : ${map}");
    _documentReference =
        Firestore.instance.collection("messages").document(message.senderUid);
    _documentReference.setData(map).whenComplete(() {
      print("Messages added to db");
      setState(() {
        _messagesList.add(message);
        print("Size ${_messagesList.length}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
        ),
        body: Column(
          children: <Widget>[
            ChatInputWidget(),
            //ChatMessagesListWidget(),
          ],
        ));
  }

  Widget ChatInputWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                  hintText: "Enter message...",
                  labelText: "Message",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              onFieldSubmitted: (value) {
                _messageController.text = value;
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              splashColor: Colors.white,
              icon: Icon(
                Icons.send,
                color: Colors.black,
              ),
              onPressed: () {
                sendMessage();
              },
            ),
          )
        ],
      ),
    );
  }

  void sendMessage() {
    var text = _messageController.text;
    _senderuid = _firebaseAuth.currentUser().then((user) {
      _senderuid = user.uid;
    });
    _message = Message(
        receiverUid: widget.receiverUid,
        senderUid: _senderuid,
        message: text,
        timestamp: DateTime.now().millisecond,
        type: text != null ? 'text' : 'image');
    addMessageToDb(_message);
  }

  Widget ChatMessagesListWidget() {
    return Flexible(
      child: ListView.builder(
        reverse: true,
        itemCount: _messagesList.length,
        itemBuilder: (context, index) {
          return chatMessageItem(_messagesList[index]);
        },
      ),
    );
  }

  Widget chatMessageItem(Message message) {
    message.senderUid == _senderuid
        ? buildRightLayout(message)
        : buildLeftLayout(message);
  }

  Widget buildRightLayout(Message message) {

    return Container(
        color: Colors.black,
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(message.message, style: TextStyle(color: Colors.black))
            ],
          ),
        ));
  }

  Widget buildLeftLayout(Message message) {
    return Container(
        color: Colors.black,
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(message.message, style: TextStyle(color: Colors.black))
            ],
          ),
        ));
  }
}
