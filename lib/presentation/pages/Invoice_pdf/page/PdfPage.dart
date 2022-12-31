import 'package:flutter/material.dart';

import 'package:healthcare_homelab/constants/app_info.dart';

import '../../../../main.dart';
import '../api/pdf_api.dart';
import '../api/pdf_invoice_api.dart';
import '../model/customer.dart';
import '../model/invoice.dart';
import '../model/supplier.dart';
import '../widget/button_widget.dart';
import '../widget/title_widget.dart';
import 'package:device_preview/device_preview.dart';

class PdfPage extends StatefulWidget {
  @override
  _PdfPageState createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  @override
  Widget build(BuildContext context) => DevicePreview(
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
                title: Text(
              "$app_name",
            )),
            body: Container(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TitleWidget(
                      icon: Icons.picture_as_pdf,
                      text: 'Generate Invoice',
                    ),
                    const SizedBox(height: 48),
                    ButtonWidget(
                      text: 'Invoice PDF',
                      onClicked: () async {
                        final date = DateTime.now();
                        final dueDate = date.add(Duration(days: 7));

                        final invoice = Invoice(
                          // supplier: Supplier(
                          //   name: 'Sarah Field',
                          //   address: 'Sarah Street 9, Beijing, China',
                          //   paymentInfo: 'https://paypal.me/sarahfieldzz',
                          // ),
                          customer: Customer(
                              id: "2134",
                              name: 'Adnan Ullah',
                              address:
                                  'Adnan Ullah Street, Cupertino, BD 95014',
                              gender: 'Male',
                              referrer: 'Dr Shawon',
                              age: '22',
                              date: "23 dec, 2010"),

                          info: InvoiceInfo(
                            date: date,
                            description: 'My description...',
                            number: '${DateTime.now().year}-9999',
                          ),

                          items: [
                            InvoiceItem(
                              testName: 'Coffee',
                              serialNumber: 3,
                              testPrice: 5.999999,
                            ),
                            InvoiceItem(
                              testName: 'Water',
                              serialNumber: 8,
                              testPrice: 0.99,
                            ),
                            InvoiceItem(
                              testName: 'Orange',
                              serialNumber: 3,
                              testPrice: 2.99,
                            ),
                            InvoiceItem(
                              testName: 'Apple',
                              serialNumber: 8,
                              testPrice: 3.99,
                            ),
                            InvoiceItem(
                              testName: 'Mango',
                              serialNumber: 1,
                              testPrice: 1.59,
                            ),
                          ],
                        );

                        final pdfFile = await PdfInvoiceApi.generate(invoice);

                        PdfApi.openFile(pdfFile);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}
