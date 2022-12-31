
import 'package:healthcare_homelab/presentation/pages/Invoice_pdf/model/supplier.dart';

import 'customer.dart';

class Invoice {
  final InvoiceInfo info;
  // final Supplier supplier;
  final Customer customer;
  final List<InvoiceItem> items;
  

  const Invoice({
    required this.info,
    // required this.supplier,
    required this.customer,
    required this.items,
  });
}

class InvoiceInfo {
  final String description;
  final String number;
  final DateTime date;


  const InvoiceInfo({
    required this.description,
    required this.number,
    required this.date,
    
  });
}

class InvoiceItem {
  final dynamic testName;
  final dynamic testPrice;
  final dynamic serialNumber;


  const InvoiceItem({
    required this.testName,
    required this.testPrice,
    required this.serialNumber,
  
  });
}