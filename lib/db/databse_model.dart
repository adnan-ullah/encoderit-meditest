import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
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
     required this.servicecharge
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
      };

  factory TestData.fromJson(Map<String, dynamic> parsedJson) {
    return TestData(
        id: parsedJson['id'],
        name: parsedJson['name'],
        testprice: parsedJson['testprice'],
        discount: parsedJson['discount'],
        diagnostic_center: parsedJson['diagnostic_center'],
        testkitprice: parsedJson['testkitprice'],
        lastupdate: parsedJson['lastupdate'],
        softdelete: parsedJson['softdelete'],
        transport_cost: parsedJson['transport_cost'],
        niddle_cost: parsedJson['niddle_cost'],
        servicecharge: parsedJson['servicecharge']);
  }
}

class TestDataRequest {
  TestDataRequest({
    required this.id,
    required this.name,
    required this.gender,
    required this.mobile,
    required this.age,
    required this.testlist,
    required this.totalprice,
    required this.servicecharge,
    required this.address,
    required this.referrer,
    required this.lastupdate,
    required this.dateofcreated,
    required this.softdelete,
    required this.latitude,
    required this.longitude,
    required this.teststatus,
    required this.invoice_call
  });

  final dynamic id;
  final dynamic name;
  final dynamic gender;
  final dynamic mobile;
  final dynamic age;
  final List<TestData> testlist;
  final dynamic totalprice;
  final dynamic servicecharge;
  final dynamic address;
  final dynamic referrer;
  final dynamic lastupdate;
  final dynamic dateofcreated;
  final dynamic softdelete;
  final dynamic latitude;
  final dynamic longitude;
  final dynamic teststatus;
  final dynamic invoice_call;

  Map toJson() => {
        'id': id,
        'name': name,
        'gender': gender,
        'mobile': mobile,
        'age': age,
        'testlist': testlist.map((e) => e.toJson()).toList(),
        'totalprice': totalprice,
        'servicecharge': servicecharge,
        'address': address,
        'referrer': referrer,
        'lastupdate': lastupdate,
        'dateofcreated': dateofcreated,
        'softdelete': softdelete,
        'latitude': latitude,
        'longitude': longitude,
        'teststatus': teststatus,
        'invoice_call': invoice_call,
      };
}
