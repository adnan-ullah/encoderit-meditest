import '../../constants/commission_types.dart';

class AdminUserModel {
  AdminUserModel(
      {required this.name,
      required this.phone,
      required this.password,
      required this.active,
      required this.type,
      required this.referrer_code,
      required this.address,
      required this.surname,
      required this.short_address,
      required this.percentage,
      Map<String, dynamic>? commissions}) {
    // Initialize commissions map from provided map
    _commissions = _buildCommissionsMap(
      commissionsMap: commissions,
    );
  }

  final dynamic name;
  final dynamic phone;
  final dynamic password;
  final dynamic active;
  final dynamic type;
  final dynamic address;
  final dynamic referrer_code;
  final dynamic surname;
  final dynamic short_address;
  final dynamic percentage;

  // New Map-based commission structure
  late final Map<String, dynamic> _commissions;

  /// Get commission for a specific type
  dynamic getCommission(String commissionType) {
    final normalizedType = CommissionTypes.normalize(commissionType);
    return _commissions[normalizedType] ?? '0';
  }

  /// Get all commissions as a Map
  Map<String, dynamic> get commissions => Map<String, dynamic>.from(_commissions);

  /// Set commission for a specific type
  void setCommission(String commissionType, dynamic value) {
    final normalizedType = CommissionTypes.normalize(commissionType);
    _commissions[normalizedType] = value;
  }

  /// Build commissions map from individual fields or provided map
  Map<String, dynamic> _buildCommissionsMap({
    Map<String, dynamic>? commissionsMap,
  }) {
    final Map<String, dynamic> result = {};

    if (commissionsMap != null) {
      // If commissions map is provided (new format), use it
      result.addAll(commissionsMap);
    }

    // Initialize all new commission types with 0 if not present
    for (final type in CommissionTypes.allTypes) {
      if (!result.containsKey(type)) {
        result[type] = '0';
      }
    }

    return result;
  }

  Map toJson() => {
        'name': name,
        'phone': phone,
        'password': password,
        'active': active,
        'type': type,
        'referrer_code': referrer_code,
        'address': address,
        'surname': surname,
        'short_address': short_address,
        'percentage': percentage,
        'commissions': _commissions, // Include new commissions map
      };

  factory AdminUserModel.fromJson(Map<String, dynamic> parsedJson) {
    // Merge legacy fields into commissions map for backward compatibility
    final Map<String, dynamic> merged = {};
    if (parsedJson['commissions'] != null) {
      merged.addAll(Map<String, dynamic>.from(parsedJson['commissions']));
    }

    return AdminUserModel(
        name: parsedJson['name'],
        phone: parsedJson['phone'],
        password: parsedJson['password'],
        active: parsedJson['active'],
        type: parsedJson['type'],
        referrer_code: parsedJson['referrer_code'],
        address: parsedJson['address'],
        surname: parsedJson['surname'],
        short_address: parsedJson['short_address'],
        percentage: parsedJson['percentage'],
        commissions: merged.isNotEmpty ? merged : null);
  }
}
