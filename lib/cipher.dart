import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

abstract class Cipher {
  Future<Uint8List> encrypt(Uint8List input);
  Future<Uint8List> decrypt(Uint8List input);
}

class AESGCM256 extends Cipher {
  final algorithm = AesGcm.with256bits();
  final String key;

  AESGCM256({
    required this.key,
  });

  Future<SecretKey> get secretKey async {
    var hashAlgo = Sha256();
    var keyHash = await hashAlgo.hash(utf8.encode(key));

    final secretKey = await algorithm.newSecretKeyFromBytes(keyHash.bytes);

    return secretKey;
  }

  @override
  Future<Uint8List> encrypt(Uint8List input) async {
    final nonce = algorithm.newNonce();

    var secretBox = await algorithm.encrypt(
      input,
      secretKey: await secretKey,
      nonce: nonce,
    );

    // print('Nonce: ${secretBox.nonce}');
    // print('Ciphertext: ${secretBox.cipherText}');
    // print('MAC: ${secretBox.mac.bytes}');

    return secretBox.concatenation(nonce: true, mac: true);
  }

  @override
  Future<Uint8List> decrypt(Uint8List input) async {
    var secretBox = SecretBox.fromConcatenation(
      input,
      nonceLength: AesGcm.defaultNonceLength,
      macLength: 16,
    );

    return Uint8List.fromList(await algorithm.decrypt(
      secretBox,
      secretKey: await secretKey,
    ));
  }
}
