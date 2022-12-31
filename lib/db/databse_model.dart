import 'package:json_annotation/json_annotation.dart';

class TestData {
  TestData(
      {this.id,
      required this.name,
      required this.testprice,
      required this.discount,
      required this.diagnostic_center,
      required this.testkitprice,
      required this.lastupdate,
      required this.softdelete,
      required this.transport_cost,
      required this.niddle_cost,
      required this.servicecharge});

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
        diagnostic_center: parsedJson['diagnosticCenter'],
        testkitprice: parsedJson['testkitprice'],
        lastupdate: parsedJson['lastupdate'],
        softdelete: parsedJson['softdelete'],
        transport_cost: parsedJson['transport_cost'],
        niddle_cost: parsedJson['niddle_cost'],
        servicecharge: parsedJson['servicecharge']);
  }
}

class TestDataRequest {
  TestDataRequest(
      {required this.id,
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
      required this.invoice_call,
      required this.type,
      required this.image_one,
      required this.image_two,
      this.comments,
      this.delivery_date,
      this.advanced,
      this.due_amount
      });

  final dynamic id;
  final dynamic name;
  final dynamic gender;
  final dynamic mobile;
  final dynamic age;
  final List<TestData>? testlist;
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
  final dynamic type;
  final dynamic image_one;
  final dynamic image_two;
  final dynamic comments;
  final dynamic delivery_date;
  final dynamic advanced;
  final dynamic due_amount;

  Map toJson() => {
        'id': id,
        'name': name,
        'gender': gender,
        'mobile': mobile,
        'age': age,
        'testlist': List<dynamic>.from(testlist!.map((x) => x.toJson())),
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
        'type': type,
        'image_one': image_one,
        'image_two': image_two,
        'comments': comments,
        'delivery_date': delivery_date,
        'advanced': advanced,
        'due_amount': due_amount,
      };

  factory TestDataRequest.fromJson(Map<String, dynamic> parsedJson) {
    return TestDataRequest(
      id: parsedJson['id'],
      name: parsedJson['name'],
      gender: parsedJson['gender'],
      mobile: parsedJson['mobile'],
      age: parsedJson['age'],
      //testlist:List<TestData>.from(parsedJson["testlist"].map((x) => TestData.fromJson(x))),
      testlist: parsedJson["testlist"] == null
          ? null
          : List<TestData>.from(
              parsedJson["testlist"].map((x) => TestData.fromJson(x))),
      totalprice: parsedJson['totalprice'],
      servicecharge: parsedJson['servicecharge'],
      address: parsedJson['address'],
      referrer: parsedJson['referrer'],
      lastupdate: parsedJson['lastupdate'],
      dateofcreated: parsedJson['dateofcreated'],
      softdelete: parsedJson['softdelete'],
      latitude: parsedJson['latitude'],
      longitude: parsedJson['longitude'],
      teststatus: parsedJson['teststatus'],
      invoice_call: parsedJson['invoice_call'],
      type: parsedJson['type'],
      image_one: parsedJson['image_one'],
      image_two: parsedJson['image_two'],
      comments: parsedJson['comments'],
      delivery_date: parsedJson['delivery_date'],
        advanced: parsedJson['advanced'],
      due_amount: parsedJson['due_amount'],
    );
  }
}
