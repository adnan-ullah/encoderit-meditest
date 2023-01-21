import 'package:json_annotation/json_annotation.dart';

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
    required this.is_payable,
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
  final dynamic is_payable;
  final dynamic category;

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
    required this.invoice_call,
    required this.type,
    required this.image_one,
    required this.image_two,
    required this.comments,
    required this.delivery_date,
    required this.advanced,
    required this.due_amount,
    required this.total_admin_discount,
    required this.total_agent_discount,
    required this.total_discount,
    required this.test_item_cost,
    required this.test_item_discount,
    required this.total_payable_pathology_cost,
    required this.total_payable_imagine_cost,
    required this.total_payable,
    required this.total_unpayable,
    required this.admin_pathology_discount,
    required this.admin_radiology_discount,
    required this.agent_pathology_discount,
    required this.agent_radiology_discount,
    required this.assigning,
    required this.area,
    required this.assigning_commission,
    required this.agent_commission,
    required this.is_paid,
    required this.total_unpayable_pathology,
    required this.total_unpayable_imagine,
    required this.payment_date
  });

  final dynamic id;
  final dynamic name;
  final dynamic gender;
  final dynamic mobile;
  final dynamic age;
  final List<TestData>? testlist;
  final int totalprice;
  final int servicecharge;
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
  final int advanced;
  final int due_amount;
  final int total_admin_discount;
  final int total_agent_discount;
  final int total_discount;
  final int test_item_cost;
  final int test_item_discount;

  final int total_payable_pathology_cost;
  final int total_payable_imagine_cost;
  final int total_payable;
  final int total_unpayable;
  final int admin_pathology_discount;
  final int admin_radiology_discount;
  final int agent_pathology_discount;
  final int agent_radiology_discount;
  final dynamic assigning;
  final dynamic area;
  final int assigning_commission;
  final int agent_commission;
  final bool is_paid;
  final int total_unpayable_pathology;
  final int total_unpayable_imagine;

    final int payment_date;

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
        'total_admin_discount': total_admin_discount,
        'total_agent_discount': total_agent_discount,
        'total_discount': total_discount,
        'test_item_cost': test_item_cost,
        'test_item_discount': test_item_discount,
        'total_payable_pathology_cost': total_payable_pathology_cost,
        'total_payable_imagine_cost': total_payable_imagine_cost,
        'total_payable': total_payable,
        'total_unpayable': total_unpayable,
        'admin_pathology_discount': admin_pathology_discount,
        'admin_radiology_discount': admin_radiology_discount,
        'agent_pathology_discount': agent_pathology_discount,
        'agent_radiology_discount': agent_radiology_discount,
        'assigning': assigning,
        'area': area,
        'assigning_commission': assigning_commission,
        'agent_commission': agent_commission,
        'is_paid': is_paid,
        'total_unpayable_pathology': total_unpayable_pathology,
        'total_unpayable_imagine': total_unpayable_imagine,
         'payment_date': payment_date,
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
      total_admin_discount: parsedJson['total_admin_discount'],
      total_agent_discount: parsedJson['total_agent_discount'],
      total_discount: parsedJson['total_discount'],
      test_item_cost: parsedJson['test_item_cost'],
      test_item_discount: parsedJson['test_item_discount'],
      total_payable_pathology_cost: parsedJson['total_payable_pathology_cost'],
      total_payable_imagine_cost: parsedJson['total_payable_imagine_cost'],
      total_payable: parsedJson['total_payable'],
      total_unpayable: parsedJson['total_unpayable'],
      admin_pathology_discount: parsedJson['admin_pathology_discount'],
      admin_radiology_discount: parsedJson['admin_radiology_discount'],
      agent_pathology_discount: parsedJson['agent_pathology_discount'],
      agent_radiology_discount: parsedJson['agent_radiology_discount'],
      assigning: parsedJson['assigning'],
      area: parsedJson['area'],
      assigning_commission: parsedJson['assigning_commission'],
      agent_commission: parsedJson['agent_commission'],
      is_paid: parsedJson['is_paid'],
      total_unpayable_pathology: parsedJson['total_unpayable_pathology'],
      total_unpayable_imagine: parsedJson['total_unpayable_imagine'],
        payment_date: parsedJson['payment_date'],
    );
  }
}

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
