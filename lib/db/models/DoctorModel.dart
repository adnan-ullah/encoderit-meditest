class DoctorModel {
  DoctorModel({
    required this.id,
    required this.name,
    required this.designation,
  });

  final dynamic id;
  final dynamic name;
  final dynamic designation;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'designation': designation,
      };

  factory DoctorModel.fromJson(Map<String, dynamic> parsedJson) {
    return DoctorModel(
      id: parsedJson['id'],
      name: parsedJson['name'],
      designation: parsedJson['designation'],
    );
  }
}
