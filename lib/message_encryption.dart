import 'dart:async';

import 'package:flutter/services.dart';

class MessageEncryption {

  String _algorithm = "RSA";
  int _byteLength = 512;

  MessageEncryption(this._algorithm, this._byteLength);

  final MethodChannel _channel =
      const MethodChannel('message_encryption');

  Future<Map<dynamic, dynamic>> generateKeys() async {
    final Map<dynamic, dynamic> keys = await _channel
        .invokeMethod('generateKeys', {'algorithm': _algorithm, 'byteLength': _byteLength});
    return keys;
  }

  Future<String> encryptMessage(String publicKey, String message) async {
    final String encryptedMessage = await _channel
        .invokeMethod('encryptMessage', {'algorithm': _algorithm, 'publicKey': publicKey, 'message': message});
    return encryptedMessage;
  }

  Future<String> decryptMessage(String privateKey, String encryptedMessage) async {
    final String decryptedMessage = await _channel
        .invokeMethod('decryptMessage', {'algorithm': _algorithm, 'privateKey': privateKey, 'encryptedMessage': encryptedMessage});
    return decryptedMessage;
  }
}
