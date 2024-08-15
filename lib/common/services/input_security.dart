// import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/export.dart';
import '../../support/app_config.dart' as app_config;
import 'utils.dart';

// ref https://stackoverflow.com/questions/67829870/how-to-implement-rsa-encryption-in-dart-using-encrypt
class InputSecurity {
  /// String Public Key
  String publickey = app_config.publicKey;

  String encrypt(String plaintext, String publicKey) {
    /// After a lot of research on how to convert the public key [String] to [RSA PUBLIC KEY]
    /// We would have to use PEM Cert Type and the convert it from a PEM to an RSA PUBLIC KEY through basic_utils
    var pem = publicKey;
    var public = CryptoUtils.rsaPublicKeyFromPem(pem);

    /// Initializing Cipher
    var cipher = PKCS1Encoding(RSAEngine());
    cipher.init(true, PublicKeyParameter<RSAPublicKey>(public));

    /// Converting into a [Unit8List] from List<int>
    /// Then Encoding into Base64
    Uint8List output =
        cipher.process(Uint8List.fromList(utf8.encode(plaintext)));
    var base64EncodedText = base64Encode(output);
    return base64EncodedText;
  }

  dynamic text(String text) {
    try {
      return encrypt(text, publickey);
    } catch (e) {
      dd(e);
    }
    return '';
  }
}
