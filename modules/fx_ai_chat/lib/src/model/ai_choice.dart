import 'message.dart';

class AiChoice {
  final int index;
  final String? logprobs;
  final String finishReason;
  final Message message;

  AiChoice({
    required this.index,
    this.logprobs,
    required this.finishReason,
    required this.message,
  });

  factory AiChoice.fromMap(dynamic map) {
    return AiChoice(
      index: map['index'] ?? 0,
      logprobs: map['logprobs'],
      finishReason: map['finish_reason'] ?? 0,
      message : Message.fromMap(map['message']),
    );
  }
}
