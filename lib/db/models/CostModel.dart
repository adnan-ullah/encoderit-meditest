
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
