package com.example.messageencryption;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import android.util.Base64;
import java.security.*;
import java.util.HashMap; 

/** MessageEncryptionPlugin */
public class MessageEncryptionPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "message_encryption");
    channel.setMethodCallHandler(new MessageEncryptionPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    
    if (call.method.equals("generateKeys")) {
      final String algorithm = call.argument("algorithm");
      final int byteLength = call.argument("byteLength");

      try {
        final HashMap<String, String> key = generateKeys(algorithm, byteLength);
        result.success(key);
      } catch (NoSuchAlgorithmException | NoSuchProviderException error) {
        result.error(error.toString(), error.getMessage(), error.getStackTrace());
      }
      return ;
    }

    if (call.method.equals("encryptMessage")) {
      final String algorithm = call.argument("algorithm");
      final String publicKey = call.argument("publicKey");
      final String message = call.argument("message");

      try {
        final String encryptedMessage = encryptMessage(algorithm, publicKey, message);
        result.success(encryptedMessage);
      } catch (Exception error) {
        result.error(error.toString(), error.getMessage(), error);
      }
      return ;
    }

    if (call.method.equals("decryptMessage")) {
      final String algorithm = call.argument("algorithm");
      final String privateKey = call.argument("privateKey");
      final String encryptedMessage = call.argument("encryptedMessage");

      try {
        final String decryptedMessage = decryptMessage(algorithm, privateKey, encryptedMessage);
        result.success(decryptedMessage);
      } catch (Exception error) {
        result.error(error.toString(), error.getMessage(), error);
      }
      return ;
    }

    result.notImplemented();
  }

  private HashMap<String, String> generateKeys(String algorithm, int byteLength) throws NoSuchAlgorithmException, NoSuchProviderException {
    final HashMap<String, String>keys = new HashMap<String, String>();

    KeyPair generateKeyPair = MessageEncryption.generateKeyPair(algorithm, byteLength);
    final byte[] publicKey = generateKeyPair.getPublic().getEncoded();
    final byte[] privateKey = generateKeyPair.getPrivate().getEncoded();

    keys.put("public", Base64.encodeToString(publicKey, Base64.DEFAULT));
    keys.put("private", Base64.encodeToString(privateKey, Base64.DEFAULT));

    return keys;
  }
  
  private String decryptMessage(String algorithm, String privateKey, String encryptedMessage) throws Exception {
    final byte[] privateKeyInBytes = Base64.decode(privateKey, Base64.DEFAULT);
    final byte[] encryptedMessageInBytes = Base64.decode(encryptedMessage, Base64.DEFAULT);
    byte[] decryptedMessage = MessageEncryption.decrypt(algorithm, privateKeyInBytes, encryptedMessageInBytes);
    String decryptedMessageString = new String(decryptedMessage);
    return decryptedMessageString;
  }

  private String encryptMessage(String algorithm, String publicKey, String message) throws Exception {
    final byte[] publicKeyInBytes = Base64.decode(publicKey, Base64.DEFAULT);
    byte[] encryptedMessage = MessageEncryption.encrypt(algorithm, publicKeyInBytes, message.getBytes());
    String encryptedMessageString = Base64.encodeToString(encryptedMessage, Base64.DEFAULT);
    return encryptedMessageString;
  }
}
