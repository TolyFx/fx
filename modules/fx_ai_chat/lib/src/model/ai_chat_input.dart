import 'message.dart';

class AiConfig {
  final String? platform;
  final String key;
  final String url;
  final String model;

  AiConfig({
    this.platform,
    required this.key,
    required this.url,
    required this.model,
  });
}

class AiChatInput {
  final String model;

  // 采样温度，介于 0 和 2 之间。更高的值，如 0.8，会使输出更随机，而更低的值，如 0.2，会使其更加集中和确定。
  // 我们通常建议可以更改这个值或者更改 top_p，但不建议同时对两者进行修改。
  final double temperature;

  // 作为调节采样温度的替代方案，模型会考虑前 top_p 概率的 token 的结果。
  // 所以 0.1 就意味着只有包括在最高 10% 概率中的 token 会被考虑。
  // 我们通常建议修改这个值或者更改 temperature，但不建议同时对两者进行修改。
  final double topP;

  // 介于 -2.0 和 2.0 之间的数字。如果该值为正，那么新 token 会根据其是否已在已有文本中出现受到相应的惩罚，从而增加模型谈论新主题的可能性。
  final int presencePenalty;
  final List<Message> messages;

  // 介于 1 到 8192 间的整数，限制一次请求中模型生成 completion 的最大 token 数。输入 token 和输出 token 的总长度受模型的上下文长度的限制。
  final int maxTokens;

  // 介于 -2.0 和 2.0 之间的数字。如果该值为正，那么新 token 会根据其在已有文本中的出现频率受到相应的惩罚，降低模型重复相同内容的可能性。
  final double? frequencyPenalty;

  // 一个 object，指定模型必须输出的格式。
  // 设置为 { "type": "json_object" } 以启用 JSON 模式，该模式保证模型生成的消息是有效的 JSON。
  final Map<String, dynamic>? responseFormat;

  // 一个 string 或最多包含 16 个 string 的 list，在遇到这些词时，API 将停止生成更多的 token。
  final List<String>? stop;

  // 如果设置为 True，将会以 SSE（server-sent events）的形式以流式发送消息增量。消息流以 data: [DONE] 结尾。
  final bool? stream;

  final Map<String, dynamic>? streamOptions;

  AiChatInput({
    required this.model,
    required this.messages,
    this.temperature = 1,
    this.topP = 1,
    this.presencePenalty = 0,
    this.maxTokens = 2048,
    this.frequencyPenalty,
    this.responseFormat,
    this.stop,
    this.stream,
    this.streamOptions,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'model': model,
      'messages': messages.map((e) => e.toJson()).toList(),
      'temperature': temperature,
      'top_p': topP,
      'presence_penalty': presencePenalty,
      'max_tokens': maxTokens,
    };
    if (stop != null) {
      data['stop'] = stop;
    }
    if (frequencyPenalty != null) {
      data['frequency_penalty'] = frequencyPenalty;
    }

    if (responseFormat != null) {
      data['response_format'] = responseFormat;
    }

    if (stream != null) {
      data['stream'] = stream;
    }

    if (streamOptions != null) {
      data['stream_options'] = streamOptions;
    }

    return data;
  }
}
