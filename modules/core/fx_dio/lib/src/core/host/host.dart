abstract class Host<E extends Enum> {
  const Host();

  /// 环境 → 服务器地址映射
  Map<E, String> get value;

  /// 当前环境，由子类决定
  E get env;

  HostConfig get config => const HostConfig();

  String get url {
    String server = value[env] ?? '';
    String port = '';
    if (config.port != null) {
      port = ':${config.port}';
    }
    return '${config.scheme}://$server$port${config.apiNest}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other.runtimeType == runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
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

/// 默认环境枚举，用户也可以自定义自己的
enum HostEnv { dev, pre, release }

abstract class Api {
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
