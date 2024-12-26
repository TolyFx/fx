import 'code.dart';

/// 接口层: 后端业务定义的状态码
enum ApiCode with Code {
  other(-1),
  ok(0),
  invalid(403),
  ;

  @override
  final int code;

  const ApiCode(this.code);

  factory ApiCode.fromInt(int? value) {
    Iterable<ApiCode> codes = ApiCode.values.where((e) => e.code == value);
    ApiCode code = ApiCode.other;
    if (codes.isNotEmpty) {
      code = codes.first;
    }
    return code;
  }
}
