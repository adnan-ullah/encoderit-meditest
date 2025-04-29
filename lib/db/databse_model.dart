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
      required this.comments,
      required this.delivery_date,
      this.advanced,
      this.due_amount,
      this.total_admin_discount,
      this.total_agent_discount,
      this.total_discount,
      this.test_item_cost,
      this.test_item_discount,
      this.total_payable_pathology_cost,
      this.total_payable_imagine_cost,
      this.total_payable,
      this.total_unpayable,
      this.admin_pathology_discount,
      this.admin_radiology_discount,
      this.agent_pathology_discount,
      this.agent_radiology_discount,
      this.assigning,
      this.area,
      this.assigning_commission,
      this.agent_commission,
      this.is_paid,
      this.total_unpayable_pathology,
      this.total_unpayable_imagine,
      this.payment_date,
      this.radiology_assigning,
      this.radiology_assigning_commission,
      this.pathology_done,
      this.radiology_done,
        this.imageDiscountFile,
        this.reciever_name,
        this.last_modifier,
        this.due_recieved,
        this.prepared_by,

      
  
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
  final dynamic reciever_name;
  final dynamic last_modifier;
  final dynamic prepared_by;

  dynamic due_recieved;
  dynamic advanced;
  dynamic due_amount;
  dynamic total_admin_discount;
  dynamic total_agent_discount;
  dynamic total_discount;
  dynamic test_item_cost;
  dynamic test_item_discount;

  dynamic total_payable_pathology_cost;
  dynamic total_payable_imagine_cost;
  dynamic total_payable;
  dynamic total_unpayable;
  dynamic admin_pathology_discount;
  dynamic admin_radiology_discount;
  dynamic agent_pathology_discount;
  dynamic agent_radiology_discount;
 
  dynamic area;

  dynamic agent_commission;
  dynamic is_paid;
  dynamic total_unpayable_pathology;
  dynamic total_unpayable_imagine;
  dynamic payment_date;

  dynamic assigning;
  dynamic radiology_assigning;
  dynamic assigning_commission;
  dynamic radiology_assigning_commission;
  dynamic pathology_done;
  dynamic radiology_done;
  dynamic imageDiscountFile;

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

             'radiology_assigning': radiology_assigning,
        'radiology_assigning_commission': radiology_assigning_commission,
        'pathology_done': pathology_done,
        'radiology_done': radiology_done,
    'imageDiscountFile':imageDiscountFile,
    'reciever_name':reciever_name,
    'last_modifier':last_modifier,
    'due_recieved':due_recieved,
    'prepared_by':prepared_by,
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


      radiology_assigning: parsedJson['radiology_assigning'],
      radiology_assigning_commission: parsedJson['radiology_assigning_commission'],
      pathology_done: parsedJson['pathology_done'],
      radiology_done: parsedJson['radiology_done'],

        imageDiscountFile:parsedJson['imageDiscountFile'],
      reciever_name:parsedJson['reciever_name'],
      last_modifier: parsedJson['last_modifier'],
      due_recieved: parsedJson['due_recieved'],
      prepared_by: parsedJson['prepared_by'],

           
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

class CostModel {
  CostModel({
    required this.id,
    required this.postingDate,
    required this.category,
    required this.voucherNo,
    required this.voucherDate,
    required this.totalAmount,
    required this.remarks,
  });

  final dynamic id;
  final dynamic postingDate;
  final dynamic category;
  final dynamic voucherNo;
  final dynamic voucherDate;
  final dynamic totalAmount;
  final dynamic remarks;

  Map<String, dynamic> toJson() => {
    'id': id,
    'posting_date': postingDate,
    'category': category,
    'voucher_no': voucherNo,
    'voucher_date': voucherDate,
    'total_amount': totalAmount,
    'remarks': remarks,
  };

  factory CostModel.fromJson(Map<String, dynamic> parsedJson) {
    return CostModel(
      id: parsedJson['id'],
      postingDate: parsedJson['posting_date'],
      category: parsedJson['category'],
      voucherNo: parsedJson['voucher_no'],
      voucherDate: parsedJson['voucher_date'],
      totalAmount: parsedJson['total_amount'],
      remarks: parsedJson['remarks'],
    );
  }
}


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
