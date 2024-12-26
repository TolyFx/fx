import 'dart:async';

abstract class ApiAuth {
  FutureOr<Map<String, dynamic>> get  buildHeaders;
}

typedef Pair = ({String key, String value});

class BearerTokenAuth extends ApiAuth {
  final String token;

  BearerTokenAuth({
    required this.token,
  });

  Pair get auth => (key: 'Authorization', value: 'Bearer $token');

  @override
  Map<String, dynamic> get buildHeaders => {
        auth.key: auth.value,
      };
}
