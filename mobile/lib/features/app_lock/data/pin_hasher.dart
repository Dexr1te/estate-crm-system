import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// PBKDF2 (RFC 8018) with HMAC-SHA256 as its pseudo-random function.
Uint8List pbkdf2HmacSha256(
  List<int> password,
  List<int> salt,
  int iterations,
  int length,
) {
  if (iterations < 1) throw ArgumentError.value(iterations, 'iterations');
  if (length < 1) throw ArgumentError.value(length, 'length');

  final prf = Hmac(sha256, password);
  const blockSize = 32;
  final blocks = (length + blockSize - 1) ~/ blockSize;
  final out = Uint8List(blocks * blockSize);

  for (var i = 1; i <= blocks; i++) {
    final first = Uint8List(salt.length + 4)
      ..setAll(0, salt)
      ..[salt.length] = (i >> 24) & 0xff
      ..[salt.length + 1] = (i >> 16) & 0xff
      ..[salt.length + 2] = (i >> 8) & 0xff
      ..[salt.length + 3] = i & 0xff;

    var u = prf.convert(first).bytes;
    final t = Uint8List.fromList(u);
    for (var n = 1; n < iterations; n++) {
      u = prf.convert(u).bytes;
      for (var k = 0; k < blockSize; k++) {
        t[k] ^= u[k];
      }
    }
    out.setAll((i - 1) * blockSize, t);
  }
  return Uint8List.sublistView(out, 0, length);
}

/// Compares two byte strings in time that depends only on their lengths, so a
/// wrong guess says nothing about how close it came.
bool constantTimeEquals(List<int> a, List<int> b) {
  var diff = a.length ^ b.length;
  final n = a.length < b.length ? a.length : b.length;
  for (var i = 0; i < n; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}
