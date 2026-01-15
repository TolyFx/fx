import 'package:fx/src/framework/host.dart';
import 'package:fx_dio/fx_dio.dart';

void main() {
  FxDio().register(const FxAppHost());
}

void requestLogin() {}
