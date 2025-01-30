import '../../data/models/ai_model.dart';

class AIEntity {
  String name;
  String model;
  String modifiedAt;
  int size;
  String digest;
  Details details;

  AIEntity({
    required this.name,
    required this.model,
    required this.modifiedAt,
    required this.size,
    required this.digest,
    required this.details,
  });
}
