import '../../constants/commission_types.dart';

class TestData {
  TestData({
    this.id,
    required this.name,
    required this.testprice,
    required this.discount,
    required this.diagnostic_center,
    required this.testkitprice,
    required this.lastupdate,
    required this.softdelete,
    required this.transport_cost,
    required this.niddle_cost,
    required this.servicecharge,
    required this.b2b_cost,
    this.is_payable,
    required this.category,
  });

  final dynamic id;
  final dynamic name;
  final dynamic testprice;
  final dynamic discount;
  final dynamic diagnostic_center;
  final dynamic testkitprice;
  final dynamic lastupdate;
  final dynamic softdelete;
  final dynamic transport_cost;
  final dynamic niddle_cost;
  final dynamic servicecharge;
  final dynamic b2b_cost;
  dynamic is_payable;
  final dynamic category;

  /// Get the commission type for this test based on its category
  String getCommissionType() {
    return CommissionTypes.getCommissionTypeFromTestCategory(category) ?? 
           CommissionTypes.others;
  }

  /// Check if this test belongs to a specific commission type
  bool belongsToCommissionType(String commissionType) {
    final normalizedType = CommissionTypes.normalize(commissionType);
    return getCommissionType() == normalizedType;
  }

  Map toJson() => {
    'id': id,
    'name': name,
    'testprice': testprice,
    'discount': discount,
    'diagnosticCenter': diagnostic_center,
    'testkitprice': testkitprice,
    'lastupdate': lastupdate,
    'softdelete': softdelete,
    'transport_cost': transport_cost,
    'niddle_cost': niddle_cost,
    'servicecharge': servicecharge,
    'b2b_cost': b2b_cost,
    'is_payable': is_payable,
    'category': category,
  };

  factory TestData.fromJson(Map<String, dynamic> parsedJson) {
    return TestData(
        id: parsedJson['id'],
        name: parsedJson['name'],
        testprice: parsedJson['testprice'],
        discount: parsedJson['discount'],
        diagnostic_center: parsedJson['diagnosticCenter'],
        testkitprice: parsedJson['testkitprice'],
        lastupdate: parsedJson['lastupdate'],
        softdelete: parsedJson['softdelete'],
        transport_cost: parsedJson['transport_cost'],
        niddle_cost: parsedJson['niddle_cost'],
        servicecharge: parsedJson['servicecharge'],
        b2b_cost: parsedJson['b2b_cost'],
        is_payable: parsedJson['is_payable'],
        category: parsedJson['category']);
  }
}
