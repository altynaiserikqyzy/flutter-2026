import '../../core/api/api_exception.dart';

/// Exhaustive because ApiException is sealed — no default.
String apiErrorText(ApiException e) => switch (e) {
  NoConnectionException() => 'No connection. Check your network.',
  NotFoundException() => 'Not found.',
  UnauthorizedException() => 'Not authorized.',
  ServerException(:final status) => 'Server error ($status). Try later.',
  BadResponseException() => 'Unexpected response from the server.',
};
