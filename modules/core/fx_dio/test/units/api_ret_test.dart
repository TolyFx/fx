import 'package:flutter_test/flutter_test.dart';
import 'package:fx_dio/fx_dio.dart';

void main() {
  group('ApiRet', () {
    test('ApiOK 访问 data 正常', () {
      final ApiRet<String> ret = ApiOK<String>('hello');
      expect(ret.success, isTrue);
      expect(ret.data, 'hello');
    });

    test('ApiFail 访问 msg 取 message', () {
      final ApiRet<String> ret = ApiFail<String>(
        trace: RequestException(RequestErrorCode.emptyData, 'no data'),
      );
      expect(ret.failed, isTrue);
      expect(ret.msg, 'no data');
    });

    test('ApiFail msg 回退到 error.toString', () {
      final ApiRet<String> ret = ApiFail<String>(
        trace: RequestException(RequestErrorCode.exception, '', const FormatException('bad')),
      );
      expect(ret.msg, contains('FormatException'));
    });
  });
}
