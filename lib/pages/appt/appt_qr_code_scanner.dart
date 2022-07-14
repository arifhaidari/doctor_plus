import 'dart:developer';
import '../../utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ApptQrScanner extends StatefulWidget {
  // final List<BookedApptModel> bookedApptList;
  const ApptQrScanner({Key? key}) : super(key: key);

  @override
  _ApptQrScannerState createState() => _ApptQrScannerState();
}

class _ApptQrScannerState extends State<ApptQrScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  String todayDate = 'Monday';

  // final int _apptId = 0;

  @override
  void initState() {
    super.initState();
    final nowDate = DateTime.now();
    todayDate = DateFormat.EEEE().format(nowDate);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  bool isFlushOn = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop({'is_success': false});
        return false;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await controller?.toggleFlash();
            setState(() {
              isFlushOn = !isFlushOn;
            });
          },
          backgroundColor: Palette.blueAppBar,
          child: Icon(isFlushOn ? Icons.flash_off : Icons.flash_on),
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: _buildQrView(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea =
        (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400)
            ? 300.0
            : 400.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 8,
          borderLength: 30,
          borderWidth: 5,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      result = scanData;

      if (result != null) {
        controller.stopCamera();
        Navigator.of(context).pop({'is_success': true, 'the_code': result!.code.toString()});
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
}
