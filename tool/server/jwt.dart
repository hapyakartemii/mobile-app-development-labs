import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Minimal HS256 JSON Web Token: `header.payload.signature` in base64url.
/// The signature is an HMAC-SHA256 of `header.payload` with a secret key,
/// so a client can read the token but can't forge or change it.
class Jwt {
  Jwt(String secret) : _hmac = Hmac(sha256, utf8.encode(secret));

  static const lifetime = Duration(days: 7);

  final Hmac _hmac;

  /// Token for [userId], valid for [lifetime].
  String issue(String userId) {
    final now = DateTime.now();
    final header = _encode({'alg': 'HS256', 'typ': 'JWT'});
    final payload = _encode({
      'sub': userId,
      'iat': _seconds(now),
      'exp': _seconds(now.add(lifetime)),
    });
    return '$header.$payload.${_sign('$header.$payload')}';
  }

  /// User id from a valid, unexpired token; `null` otherwise.
  String? verify(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    if (_sign('${parts[0]}.${parts[1]}') != parts[2]) return null;

    final payload =
        jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))))
            as Map<String, dynamic>;
    if (_seconds(DateTime.now()) > (payload['exp'] as int)) return null;
    return payload['sub'] as String;
  }

  String _encode(Map<String, Object> json) =>
      _base64(utf8.encode(jsonEncode(json)));

  String _sign(String data) => _base64(_hmac.convert(utf8.encode(data)).bytes);

  static String _base64(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  static int _seconds(DateTime time) => time.millisecondsSinceEpoch ~/ 1000;
}
