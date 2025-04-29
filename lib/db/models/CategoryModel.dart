class CategoryModel {
  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
  });

  final dynamic id;
  final dynamic name;
  final dynamic type;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> parsedJson) {
    return CategoryModel(
      id: parsedJson['id'],
      name: parsedJson['name'],
      type: parsedJson['type'],
    );
  }
}
