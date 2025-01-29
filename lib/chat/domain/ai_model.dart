class Details {
  String parentModel;
  String format;
  String family;
  List<String>? families;
  String parameterSize;
  String quantizationLevel;

  Details({
    required this.parentModel,
    required this.format,
    required this.family,
    this.families,
    required this.parameterSize,
    required this.quantizationLevel,
  });

  Details.fromJson(Map<String, dynamic> json)
      : parentModel = json['parent_model'],
        format = json['format'],
        family = json['family'],
        families = json['families']?.cast<String>(),
        parameterSize = json['parameter_size'],
        quantizationLevel = json['quantization_level'];

  Map<String, dynamic> toJson() => {
        'parentModel': parentModel,
        'format': format,
        'family': family,
        'families': families,
        'parameterSize': parameterSize,
        'quantizationLevel': quantizationLevel,
      };
}

class AIModel {
  String name;
  String model;
  String modifiedAt;
  int size;
  String digest;
  Details details;

  AIModel({
    required this.name,
    required this.model,
    required this.modifiedAt,
    required this.size,
    required this.digest,
    required this.details,
  });

  AIModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        model = json['model'],
        modifiedAt = json['modified_at'],
        size = json['size'],
        digest = json['digest'],
        details = Details.fromJson(json['details']);

  static Map<String, dynamic> toJson(AIModel model) => {
        'name': model.name,
        'model': model.model,
        'modifiedAt': model.modifiedAt,
        'size': model.size,
        'digest': model.digest,
        'details': model.details.toJson(),
      };
}
