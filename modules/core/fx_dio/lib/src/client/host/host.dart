import '../../core/host/host.dart';
import 'client_mixin.dart';

export '../../core/host/host.dart' show Host, HostConfig, HostEnv, Api, Method;

/// 可发起请求的 Host — 在 core Host 基础上混入 ClientMixin
abstract class RequestHost<E extends Enum> extends Host<E> with ClientMixin {
  const RequestHost();

  @override
  RequestHost<E> get host => this;
}
