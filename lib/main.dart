import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sms_maintained/sms.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

SmsSender sender = new SmsSender();
List id = [];

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey qrKey = GlobalKey();
  Barcode qrText;
  int currState = 0;
  int isOpen = 0;
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
                key: qrKey,
                overlay: QrScannerOverlayShape(
                    borderRadius: 10,
                    borderColor: Colors.red,
                    borderLength: 30,
                    cutOutSize: 300),
                onQRViewCreated: _onQRViewCreate),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan Result: ${qrText?.code}'),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreate(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;

        if (isOpen != 1) {
          isOpen = 1;
          _showMyDialog();
        }
      });
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('App Alert!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Do you to send this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () async {
                sender.sendSms(new SmsMessage('09068600572', qrText?.code));
                isOpen = 0;
                await Future.delayed(const Duration(seconds: 2), () {});
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                isOpen = 0;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
