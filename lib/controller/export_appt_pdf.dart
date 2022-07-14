import '../models/models.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

class ExportApptPdf {
  // static Future<File> generate() async {
  static Future<void> generate(List<BookedApptModel> bookedApptList, String operation) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        buildHeader(bookedApptList, operation),
        SizedBox(height: 0.5 * PdfPageFormat.cm),
        Divider(),
        SizedBox(height: 0.5 * PdfPageFormat.cm),
        buildWidgetBody(bookedApptList),
      ],
      footer: (context) => buildFooter(),
    ));

    // final dir = await getApplicationDocumentsDirectory();
    // final file = File('${dir.path}/appt_list');

    // final bytes = await pdf.save();
    // await file.writeAsBytes(bytes);

    // display and print using Printing.layoutPdf
    await Printing.layoutPdf(
        name: 'Appointment_list_${DateFormat.yMMMd().format(DateTime.now()).toString()}',
        onLayout: (PdfPageFormat format) async {
          return pdf.save();
        });
    // await Printing.sharePdf(bytes: file.readAsBytesSync(), filename: 'appt_list.pdf');
  }

  static Widget buildHeader(List<BookedApptModel> apptList, String operation) {
    final todayDate = DateFormat.yMMMd().format(DateTime.now());
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(apptList.first.clinicName ?? 'Unknown Clinic',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
      SizedBox(height: 0.3 * PdfPageFormat.cm),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Total Patients: ${apptList.length}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
        Text(operation == 'today' ? 'Date: $todayDate' : 'Whole Week Appts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ))
      ])
    ]);
  }

  static Widget buildWidgetBody(List<BookedApptModel> theApptList) {
    final myDataList = theApptList
        .map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Container(
                alignment: Alignment.center,
                width: 185,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(width: 1), borderRadius: BorderRadius.circular(10)),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 3),
                      Container(
                        height: 65,
                        width: 65,
                        child: BarcodeWidget(
                          height: 60,
                          width: 60,
                          barcode: Barcode.qrCode(),
                          data: e.id.toString(),
                        ),
                      ),
                      SizedBox(height: 3),
                      RichText(
                        text: TextSpan(
                          text: 'Name: ',
                          children: [TextSpan(text: e.patientName ?? 'Unknown Patient')],
                        ),
                      ),
                      SizedBox(height: 3),
                      RichText(
                        text: TextSpan(
                          text: 'Phone: ',
                          children: [TextSpan(text: e.phone ?? 'Unknown Phone')],
                        ),
                      ),
                      SizedBox(height: 3),
                      RichText(
                        text: TextSpan(
                          text: 'Start Appt: ',
                          children: [TextSpan(text: e.startApptTime ?? 'Unknonw Time')],
                        ),
                      ),
                      SizedBox(height: 3),
                      RichText(
                        text: TextSpan(
                          text: 'Day: ',
                          children: [TextSpan(text: e.weekDay ?? 'Unknown Day')],
                        ),
                      ),
                    ]))))
        .toList();

    return Padding(
        padding: const EdgeInsets.only(left: 35),
        child: Wrap(
          spacing: 30,
          runSpacing: 15,
          alignment: WrapAlignment.spaceEvenly,
          children: [...myDataList],
        ));
  }

  static Widget buildFooter() {
    final style = TextStyle(fontWeight: FontWeight.bold);
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 2 * PdfPageFormat.mm),
          Text('Powered By Doctor Plus | www.doctorplus.af', style: style),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text('0771234567 | info@doctorplus.af', style: style),
        ],
      ),
    ]);
  }
}
