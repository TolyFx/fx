import 'client_mixin.dart';

abstract class Host with ClientMixin{

  static bool isDevelopment = true;

  const Host();

  Map<HostEnv, String> get value;

  HostEnv get env => isDevelopment ? HostEnv.dev : HostEnv.release;

  HostConfig get config => const HostConfig();

  String url({bool isDev = false}) {
    String server = value[env] ?? '';
    String port = '';
    if (config.port != null) {
      port = ':${config.port}';
    }
    return '${config.scheme}://$server$port${config.apiNest}';
  }

  @override
  Host get host => this;
}

class HostConfig {
  final String scheme;
  final int? port;
  final String apiNest;

  const HostConfig({
    this.scheme = 'https',
    this.port,
    this.apiNest = '',
  });
}

enum HostEnv { dev, release }

abstract class Api{

  Method get method;
}

enum Method {
  post('POST'),
  get('GET'),
  delete('DELETE'),
  put('PUT'),
  ;
  final String value;
  const Method(this.value);
}
