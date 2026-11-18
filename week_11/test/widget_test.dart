import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_repository.dart';

const _json = '''
{"id":1,"name":"Leanne Graham","username":"Bret","email":"Sincere@april.biz",
"address":{"street":"Kulas Light","suite":"Apt. 556","city":"Gwenborough",
"zipcode":"92998-3874","geo":{"lat":"-37.3159","lng":"81.1496"}},
"phone":"1-770-736-8031 x56442","website":"hildegard.org",
"company":{"name":"Romaguera-Crona","catchPhrase":"Multi-layered client-server neural-net","bs":"harness real-time e-markets"}}
''';

UserRepository repoWith(Future<http.Response> Function(http.Request) h) =>
    UserRepository(ApiClient(MockClient(h)));

void main() {
  test('User fromJson / toJson round-trip', () {
    final u = User.fromJson(jsonDecode(_json) as Map<String, dynamic>);
    expect(u.address.geo.lat, -37.3159);
    expect(u.phoneDigits, '1770736803156442');
    expect(User.fromJson(u.toJson()), u);
    expect(u.toJson()['address']['geo']['lat'], '-37.3159');
  });

  test('wrong type in JSON -> BadResponseException', () {
    final bad = _json.replaceFirst('"id":1', '"id":"1"');
    final repo = repoWith((_) async => http.Response(bad, 200));
    expect(repo.getById(1), throwsA(isA<BadResponseException>()));
  });

  test('404 -> NotFoundException (status is checked before the body)', () {
    final repo = repoWith((_) async => http.Response('{}', 404));
    expect(repo.getById(999), throwsA(isA<NotFoundException>()));
  });

  test('500 -> ServerException(500)', () {
    final repo = repoWith((_) async => http.Response('', 500));
    expect(
      repo.getAll(),
      throwsA(isA<ServerException>().having((e) => e.status, 'status', 500)),
    );
  });

  test('SocketException -> NoConnectionException', () {
    final repo = repoWith((_) async => throw const SocketException('x'));
    expect(repo.getAll(), throwsA(isA<NoConnectionException>()));
  });

  test('not JSON -> BadResponseException', () {
    final repo = repoWith((_) async => http.Response('<html>', 200));
    expect(repo.getAll(), throwsA(isA<BadResponseException>()));
  });
}
