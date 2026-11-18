import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

/// Screens ask for models and get models — or one of our exceptions.
/// Never a Response, never a status code, never a Map.
class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final r = await _api.get(Uri.https(_api.host, '/users'));
    return _parse('users', r, (json) {
      return (json as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<User> getById(int id) async {
    final r = await _api.get(Uri.https(_api.host, '/users/$id'));
    return _parse(
      'users/$id',
      r,
      (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<User> create(User draft) async {
    // the server assigns the id, so we do not send ours
    final body = jsonEncode(draft.toJson()..remove('id'));
    final r = await _api.post(Uri.https(_api.host, '/users'), body);
    if (r.statusCode != 201) {
      throw BadResponseException('users: expected 201, got ${r.statusCode}');
    }
    return _parse(
      'users',
      r,
      (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  /// decode + fromJson; a failed cast becomes BadResponseException
  /// that names the field (the TypeError message says which one).
  T _parse<T>(String where, http.Response r, T Function(dynamic json) build) {
    final json = _api.decode(r); // may throw BadResponseException itself
    try {
      return build(json);
    } on TypeError catch (e) {
      throw BadResponseException('$where: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$where: $e');
    }
  }
}
