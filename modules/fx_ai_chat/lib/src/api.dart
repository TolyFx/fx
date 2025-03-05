import 'model/model.dart';
import 'package:dio/dio.dart';

class FxChatAi {
  final AiConfig config;

  FxChatAi(this.config);

  late Dio dio = Dio(BaseOptions(baseUrl: config.url));

  Future<AiChatOutput> chat(AiChatInput input) async {
    final response = await dio.post(
      '/chat/completions',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${config.key}',
      }),
      data: input.toJson(),
    );
    final dynamic repData = response.data;
    return AiChatOutput.fromMap(repData);
  }
}
