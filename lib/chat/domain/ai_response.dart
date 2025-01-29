import 'message_model.dart';

class AIResponse {
  String model;
  String createdAt;
  Message message;
  String? doneReason;
  bool done;
  int? totalDuration;
  int? loadDuration;
  int? promptEvalCount;
  int? promptEvalDuration;
  int? evalCount;
  int? evalDuration;

  AIResponse({
    required this.model,
    required this.createdAt,
    required this.message,
    this.doneReason,
    required this.done,
    this.totalDuration,
    this.loadDuration,
    this.promptEvalCount,
    this.promptEvalDuration,
    this.evalCount,
    this.evalDuration,
  });

  AIResponse.fromJson(Map<String, dynamic> json)
      : model = json['model'],
        createdAt = json['created_at'],
        message = Message.fromJson(json['message']),
        doneReason = json['done_reason'],
        done = json['done'],
        totalDuration = json['total_duration'],
        loadDuration = json['load_duration'],
        promptEvalCount = json['prompt_eval_count'],
        promptEvalDuration = json['prompt_eval_duration'],
        evalCount = json['eval_count'],
        evalDuration = json['eval_duration'];

  Map<String, dynamic> toJson() => {
        'model': model,
        'createdAt': createdAt,
        'message': message.toJson(),
        'doneReason': doneReason,
        'done': done,
        'totalDuration': totalDuration,
        'loadDuration': loadDuration,
        'promptEvalCount': promptEvalCount,
        'promptEvalDuration': promptEvalDuration,
        'evalCount': evalCount,
        'evalDuration': evalDuration,
      };
}
