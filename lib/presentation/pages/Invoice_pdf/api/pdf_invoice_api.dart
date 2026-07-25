import 'dart:io';

import 'package:healthcare_homelab/constants/app_info.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

import '../../../../responsives/dimensions.dart';
import '../model/customer.dart';
import '../model/invoice.dart';
import '../utils.dart';
import 'pdf_api.dart';

class PdfInvoiceApi {
  static Future<File> generate(Invoice invoice) async {
    final pdf = Document();

    //width : 7.7
    //height:

    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat(3 * PdfPageFormat.inch, 6 * PdfPageFormat.inch,
          marginAll: 4 * PdfPageFormat.mm),
      build: (context) => [
        buildHeader(invoice),
        SizedBox(height: 4 * PdfPageFormat.mm),
        buildTitle(invoice),
        buildInvoice(invoice),
        Divider(),
        SizedBox(height: 3 * PdfPageFormat.mm),
        buildFooterInfo(invoice)
      ],
    ));

    final dateTime =
        DateTime.fromMillisecondsSinceEpoch(invoice.customer.date);
    final monthYear =
        '${DateFormat('MMMM').format(dateTime)}${dateTime.year}'; // e.g. May2026

    return PdfApi.saveDocument(
      name: '${invoice.customer.invoice_id.toString()} (Customer_Copy).pdf',
      pdf: pdf,
      subDir: 'Healthcare Homelab/Invoices/$monthYear',
    );
  }

  static Widget buildHeader(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeadInfo(),
          SizedBox(height: 3 * PdfPageFormat.mm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildCustomerAddress(invoice.customer),
              buildInvoiceInfo(invoice.customer),
            ],
          ),
        ],
      );

  static Widget buildCustomerAddress(Customer customer) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: PdfPageFormat.cm * 3.4,
            child: Text("ID#  " + customer.invoice_id,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            width: PdfPageFormat.cm * 3.5,
            child: Text("Name: " + customer.name,
                style: TextStyle(
                  fontSize: 8,
                )),
          ),
          Text("Gender: " + customer.gender,
              style: TextStyle(
                fontSize: 8,
              )),
          SizedBox(
            width: PdfPageFormat.cm * 3.5,
            child: Text("Address:  " + customer.address,
                style: TextStyle(
                  fontSize: 8,
                )),
          ),
          SizedBox(
            width: PdfPageFormat.cm * 3.5,
            child: Text("Ref:  " + customer.referrer,
                style: TextStyle(
                  fontSize: 8,
                )),
          ),
        ],
      );

  static Widget buildInvoiceInfo(Customer customer) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          "Date: " +
              DateFormat(
                'dd-MMM-yyy',
              )
                  .format(DateTime.fromMillisecondsSinceEpoch(customer.date))
                  .toString(),
          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
      Text(
          "Time: " +
              DateFormat(
                'hh:mm a',
              )
                  .format(DateTime.fromMillisecondsSinceEpoch(customer.date))
                  .toString(),
          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
      Text("Age: " + customer.age.toString(),
          style: TextStyle(
            fontSize: 8,
          )),
    ]);
  }

  // static Widget buildSupplierAddress(Supplier supplier) => Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(supplier.name, style: TextStyle(fontWeight: FontWeight.bold)),
  //         SizedBox(height: 1 * PdfPageFormat.mm),
  //         Text(supplier.address),
  //       ],
  //     );

  static Widget buildTitle(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Investigation",
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
          SizedBox(height: 3 * PdfPageFormat.mm),
        ],
      );

  static Widget buildInvoice(Invoice invoice) {
    final headers = [
      'SL',
      'TEST NAME',
      'TEST PRICE',
    ];
    final data = invoice.items.map((item) {
      //  final total = item.unitPrice * item.quantity * (1 + item.vat);

      return [
        '${item.serialNumber}',
        item.testName,
        item.testPrice,
      ];
    }).toList();

    data.add(["", "C.Charge/Needle/Others", invoice.customer.collection_charge]);
    data.add(["", "Tube Cost", invoice.customer.tube_cost]);

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontSize: 7, fontWeight: FontWeight.bold),
      headerDecoration: BoxDecoration(color: PdfColors.grey300),
      cellHeight: 2,
      columnWidths: {
        0: FlexColumnWidth(2.0),
        1: FlexColumnWidth(9.5),
        2: FlexColumnWidth(
            4.5), // i want this one to take the rest available space
      },
      cellStyle: TextStyle(fontSize: 8),
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerLeft,
        2: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(Invoice invoice) {
    final netTotal = invoice.items
        .map((item) => item.testPrice * item.serialNumber)
        .reduce((item1, item2) => item1 + item2);
    final vatPercent = 1;
    //final vatPercent = invoice.items.first.vat;
    final vat = netTotal * vatPercent;
    final total = netTotal + vat;

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Total Amount',
                  value: Utils.formatPrice(netTotal),
                  unite: true,
                ),
                buildText(
                  title: 'Advance ${vatPercent * 100} %',
                  value: Utils.formatPrice(vat),
                  unite: true,
                ),
                buildText(
                  title: 'Discount ${vatPercent * 100} %',
                  value: Utils.formatPrice(vat),
                  unite: true,
                ),
                Divider(),
                buildText(
                  title: 'Due Amount Total',
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  value: Utils.formatPrice(total),
                  unite: true,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFooter(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 2 * PdfPageFormat.mm),
          // buildSimpleText(title: 'Address', value: invoice.supplier.address),
          SizedBox(height: 1 * PdfPageFormat.mm),
          // buildSimpleText(title: 'Paypal', value: invoice.supplier.paymentInfo),
        ],
      );

  static Widget buildFooterInfo(Invoice invoice) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// LEFT COLUMN (Delivery Date + Prepared & Modified Info)
      Expanded(
        flex: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Report Delivery",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
            SizedBox(height: 2),
            Text(
              DateFormat('dd MMM, yyyy').format(
                  DateTime.fromMillisecondsSinceEpoch(invoice.customer.deliveryDate)),
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
            ),
            Text("08:00 PM",
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            /// Prepared By
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Prepared by: ",
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.normal)),
                Expanded(
                  child: Text(
                    invoice.customer.prepared_by ?? '',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),

            /// Modified By
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Modified by: ",
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.normal)),
                Expanded(
                  child: Text(
                    invoice.customer.last_modifier ?? '',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      /// RIGHT COLUMN (Amounts)
      Expanded(
        flex: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildAmountRow(
              label: "Total Amount:",
              value: (int.parse(invoice.customer.totalAmount.toString()) +
                  int.parse(invoice.customer.totalDiscount.toString()))
                  .toString(),
            ),
            buildAmountRow(
              label: "Discount:",
              value: invoice.customer.totalDiscount.toString(),
            ),
            buildAmountRow(
              label: "Advanced:",
              value: (int.parse(invoice.customer.advance.toString()) +
                  int.parse(invoice.customer.dueRecieveOne.toString()) +
                  int.parse(invoice.customer.dueRecieveTwo.toString()))
                  .toString(),
            ),
            buildAmountRow(
              label: "Due Amount:",
              value: invoice.customer.dueAmount.toString(),
            ),
          ],
        ),
      ),
    ],
  );

  /// Helper for aligned amount rows
  static Widget buildAmountRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 8),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }


  static Widget buildHeadInfo() => Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$app_name",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
              "SK Tower, Above Dutch Bangla Bank Booth (Opposite to Patenga Model Thana) Steel Mills Bazar, North Patenga,Chittagong",
              style: TextStyle(fontSize: 8),
              textAlign: TextAlign.center),

          Text("Mobile: 01785890750 , 01862739539",
              style: TextStyle(fontSize: 8), textAlign: TextAlign.center),
          Text("Customer Copy",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),

          // buildSimpleText(title: 'Address', value: invoice.supplier.address),

          Divider(),
          // buildSimpleText(title: 'Paypal', value: invoice.supplier.paymentInfo),
        ],
      ));

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}
