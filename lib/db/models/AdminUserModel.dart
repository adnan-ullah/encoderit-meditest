
class AdminUserModel {
  AdminUserModel(
      {required this.name,
        required this.phone,
        required this.password,
        required this.active,
        required this.type,
        required this.referrer_code,
        required this.pathology_commission,
        required this.address,
        required this.surname,
        required this.short_address,
        required this.imagine_commission});

  final dynamic name;
  final dynamic phone;
  final dynamic password;
  final dynamic active;
  final dynamic type;
  final dynamic address;
  final dynamic referrer_code;
  final dynamic pathology_commission;
  final dynamic surname;
  final dynamic short_address;
  final dynamic imagine_commission;

  Map toJson() => {
    'name': name,
    'phone': phone,
    'password': password,
    'active': active,
    'type': type,
    'referrer_code': referrer_code,
    'pathology_commission': pathology_commission,
    'address': address,
    'surname': surname,
    'short_address': short_address,
    'imagine_commission': imagine_commission,
  };

  factory AdminUserModel.fromJson(Map<String, dynamic> parsedJson) {
    return AdminUserModel(
        name: parsedJson['name'],
        phone: parsedJson['phone'],
        password: parsedJson['password'],
        active: parsedJson['active'],
        type: parsedJson['type'],
        referrer_code: parsedJson['referrer_code'],
        pathology_commission: parsedJson['pathology_commission'],
        address: parsedJson['address'],
        surname: parsedJson['surname'],
        short_address: parsedJson['short_address'],
        imagine_commission: parsedJson['imagine_commission']);
  }
}
