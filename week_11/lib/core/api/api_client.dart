import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

// The composition root (main.dart) needs `Client()` but must not import
// package:http itself — so grep "package:http" lib/ stays at two files.
export 'package:http/http.dart' show Client;

/// The only place that talks to the network. Everything that leaves this
/// class is either a Response that already passed [_check], or an
/// [ApiException].
class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  /// Headers in one place.
  Map<String, String> get headers => const {'Accept': 'application/json'};

  Future<http.Response> get(Uri uri) async {
    final r = await _send(() => _client.get(uri, headers: headers));
    _check(r);
    return r;
  }

  Future<http.Response> post(Uri uri, String jsonBody) async {
    final r = await _send(
      () => _client.post(
        uri,
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonBody,
      ),
    );
    _check(r);
    return r;
  }

  /// The lab's `_decode`: body -> JSON, FormatException -> BadResponseException.
  dynamic decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException('invalid JSON: ${e.message}');
    }
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final r = await call().timeout(const Duration(seconds: 10));
      if (kDebugMode) {
        log(
          '${r.request?.method} ${r.request?.url} -> ${r.statusCode}',
          name: 'api',
        );
      }
      return r;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      // some platforms wrap the socket error in a ClientException
      throw const NoConnectionException();
    }
  }

  /// Status is checked BEFORE the body, every time.
  void _check(http.Response r) {
    final s = r.statusCode;
    if (s == 401) throw const UnauthorizedException();
    if (s == 404) throw const NotFoundException();
    if (s >= 500) throw ServerException(s);
    if (s >= 400) throw BadResponseException('HTTP $s');
  }
}
