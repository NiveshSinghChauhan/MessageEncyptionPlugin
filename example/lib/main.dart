import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:message_encryption/message_encryption.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<dynamic, dynamic> _keys = {'public': null, 'private': null};
  String _decMsg;
  String _encMsg;
  String _message = 'hello this is me flutter';
  MessageEncryption messageEncryption = new MessageEncryption("RSA", 512);

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Map<dynamic, dynamic> key;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      key = await messageEncryption.generateKeys();
    } on PlatformException catch (error) {
      print("[PlatformException] ERROR --->" + error.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _keys = key;
    });
  }

  void encryptMessage() async {
    String encryptedMessage;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      encryptedMessage =
          await messageEncryption.encryptMessage(_keys['public'], _message);
    } on PlatformException catch (error) {
      print("[PlatformException] ERROR --->" + error.toString());
    }
    if (!mounted) return;

    setState(() {
      _encMsg = encryptedMessage;
      _message = encryptedMessage;
    });
  }

  void decryptMessage() async {
    String decryptedMessage;
    try {
      decryptedMessage =
          await messageEncryption.decryptMessage(_keys['private'], _encMsg);
    } on PlatformException catch (error) {
      print("[PlatformException] ERROR --->" + error.toString());
    }
    if (!mounted) return;
    print(decryptedMessage);

    setState(() {
      _decMsg = decryptedMessage;
      _message = decryptedMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'private = ${_keys['private']}',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'public = ${_keys['public']}',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Text(
            'MESSAGE = $_message',
            style: TextStyle(fontSize: 16.0),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              MaterialButton(
                child: Text("encrypt"),
                onPressed: () {
                  encryptMessage();
                },
              ),
              MaterialButton(
                child: Text("decrypt"),
                onPressed: () {
                  decryptMessage();
                },
              ),
            ],
          )
        ]),
      ),
    );
  }
}
