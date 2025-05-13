class Customer {
  final dynamic id;
      final dynamic invoice_id; 
  final dynamic name;
  final dynamic address;
  final dynamic gender;
  final dynamic referrer;
  final dynamic date;
  final dynamic age;
  final dynamic totalAmount;
  final dynamic totalDiscount;
  final dynamic deliveryDate;
  final dynamic deliveryTime;
  final dynamic dueRecieveOne;
  final dynamic dueRecieveTwo;
  final dynamic dueAmount;
  final dynamic advance;
    final dynamic testItems;
   final dynamic collection_charge;
    final dynamic tube_cost;
    final dynamic prepared_by;
    final dynamic reciever_name;
  final dynamic last_modifier;
  final dynamic totalCashRecieved;



  const Customer({
    required this.id,
    this.invoice_id,
    this.gender,
    this.referrer,
    this.date,
    
    this.age,
    this.totalAmount,
    this.totalDiscount,
    this.deliveryDate,
    this.deliveryTime,
    this.name,
    this.address,
    this.dueRecieveOne,
    this.dueRecieveTwo,
    this.dueAmount,
    this.advance,
    this.testItems,
    this.collection_charge,
    this.tube_cost,

    this.prepared_by,
    this.reciever_name,
    this.last_modifier,
    this.totalCashRecieved

    

  });
}
