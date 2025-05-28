
import 'TestData.dart';

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
        this.is_pathology_paid,
        this.is_radiology_paid,
        this.total_unpayable_pathology,
        this.total_unpayable_imagine,
        this.payment_date,
        this.pathology_payment_date,
        this.radiology_payment_date,
        this.advance_payment_date,
        this.radiology_assigning,
        this.radiology_assigning_commission,
        this.pathology_done,
        this.radiology_done,
        this.imageDiscountFile,
        this.due_recieved_two_by,
        this.advance_recieved_by,
        this.last_modifier,
        this.due_recieved_two,
        this.prepared_by,
        this.due_recieve_two_date,
        this.total_cash_recieve,
        this.due_recieved_one_by,
        this.due_recieved_one,
        this.due_recieve_one_date
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
  final dynamic due_recieved_one_by;
  final dynamic due_recieved_two_by;
  final dynamic advance_recieved_by;
  final dynamic last_modifier;
  final dynamic prepared_by;
  final dynamic due_recieve_one_date;
  final dynamic due_recieve_two_date;
  final dynamic total_cash_recieve;

  dynamic due_recieved_one;
  dynamic due_recieved_two;
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
  dynamic is_pathology_paid;
  dynamic is_radiology_paid;
  dynamic total_unpayable_pathology;
  dynamic total_unpayable_imagine;
  dynamic payment_date;
  dynamic advance_payment_date;
  dynamic pathology_payment_date;
  dynamic radiology_payment_date;

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
    'is_pathology_paid': is_pathology_paid,
    'is_radiology_paid': is_radiology_paid,
    'total_unpayable_pathology': total_unpayable_pathology,
    'total_unpayable_imagine': total_unpayable_imagine,
    'payment_date': payment_date,
    'advance_payment_date': advance_payment_date,
    'collector_payment_date': pathology_payment_date,
    'radiology_payment_date': radiology_payment_date,


    'radiology_assigning': radiology_assigning,
    'radiology_assigning_commission': radiology_assigning_commission,
    'pathology_done': pathology_done,
    'radiology_done': radiology_done,
    'imageDiscountFile':imageDiscountFile,
    'due_recieved_one_by':due_recieved_one_by,
    'due_recieved_one':due_recieved_one,
    'due_recieve_one_date':due_recieve_one_date,
    'due_recieved_two_by':due_recieved_two_by,
    'advance_recieved_by':advance_recieved_by,
    'last_modifier':last_modifier,
    'due_recieved_two':due_recieved_two,
    'prepared_by':prepared_by,
    'due_recieve_two_date':due_recieve_two_date,
    'total_cash_recieve':total_cash_recieve,

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
      is_pathology_paid: parsedJson['is_pathology_paid'],
      is_radiology_paid: parsedJson['is_radiology_paid'],
      total_unpayable_pathology: parsedJson['total_unpayable_pathology'],
      total_unpayable_imagine: parsedJson['total_unpayable_imagine'],
      payment_date: parsedJson['payment_date'],
      advance_payment_date: parsedJson['advance_payment_date'],
      pathology_payment_date: parsedJson['collector_payment_date'],
      radiology_payment_date: parsedJson['radiology_payment_date'],


      radiology_assigning: parsedJson['radiology_assigning'],
      radiology_assigning_commission: parsedJson['radiology_assigning_commission'],
      pathology_done: parsedJson['pathology_done'],
      radiology_done: parsedJson['radiology_done'],
      due_recieved_one_by:parsedJson['due_recieved_one_by'],
      due_recieved_one: parsedJson['due_recieved_one'],
      due_recieve_one_date: parsedJson['due_recieve_one_date'],
      imageDiscountFile:parsedJson['imageDiscountFile'],
      due_recieved_two_by:parsedJson['due_recieved_two_by'],
      advance_recieved_by:parsedJson['advance_recieved_by'],
      last_modifier: parsedJson['last_modifier'],
      due_recieved_two: parsedJson['due_recieved_two'],
      prepared_by: parsedJson['prepared_by'],
      due_recieve_two_date: parsedJson['due_recieve_two_date'],
      total_cash_recieve: parsedJson['total_cash_recieve'],
    );
  }
}