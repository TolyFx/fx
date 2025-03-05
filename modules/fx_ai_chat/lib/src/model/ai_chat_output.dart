import 'ai_choice.dart';

class AiChatOutput {
  final String id;
  final String object;
  final int created;
  final String model;
  final Usage usage;
  final List<AiChoice> choices;
  final String systemFingerprint;

  AiChatOutput({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.usage,
    required this.choices,
    required this.systemFingerprint,
  });

  factory AiChatOutput.fromMap(dynamic map) {
    dynamic choicesData = map['choices'];
    List<AiChoice> choices = [];
    if (choicesData is List) {
      choices = choicesData.map(AiChoice.fromMap).toList();
    }

    return AiChatOutput(
      id: map['id'] ?? '',
      object: map['object'] ?? '',
      created: map['created'] ?? 0,
      model: map['model'] ?? '',
      usage: Usage.fromMap(map['usage']),
      choices: choices,
      systemFingerprint: map['system_fingerprint'] ?? '',
    );
  }
}

class Usage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final Map<String, dynamic> promptTokensDetails;
  final int promptCacheHitTokens;
  final int promptCacheMissTokens;

  Usage({
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.totalTokens = 0,
    this.promptTokensDetails = const {},
    this.promptCacheHitTokens = 0,
    this.promptCacheMissTokens = 0,
  });

  factory Usage.fromMap(dynamic map) {
    return Usage(
      promptTokens: map['prompt_tokens'] ?? 0,
      completionTokens: map['completion_tokens'] ?? 0,
      totalTokens: map['total_tokens'] ?? 0,
      promptTokensDetails: map['prompt_tokens_details'] ?? {},
      promptCacheHitTokens: map['prompt_cache_hit_tokens'] ?? 0,
      promptCacheMissTokens: map['prompt_cache_miss_tokens'] ?? 0,
    );
  }
}
