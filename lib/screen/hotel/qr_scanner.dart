import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({
    super.key,
  });
  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final user = FirebaseAuth.instance.currentUser!;
  Barcode? result;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var name = '';

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void updateArrayMap(String documentID, String userID) async {
    final documentReference = _firestore.collection('bookings').doc(documentID);
    final documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
      print(documentSnapshot.data()!['certificate']);
      List<Map<String, dynamic>> array =
          List.from(documentSnapshot.data()!['certificate']);
      int index = array.indexWhere((map) => map['id'] == userID);

      if (index != -1) {
        array[index]['participated'] = "Yes";
        await documentReference.update({'certificate': array});
      }
    }
  }

  void getUsername() async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(result!.code)
          .get()
          .then((value) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc((value.data() as Map<String, dynamic>)['uId'])
            .get()
            .then((value) {
          setState(() {
            name = (value.data() as Map<String, dynamic>)['username'];
          });
        });
      });
    } catch (e) {}

    // try {
    //   updateArrayMap(widget.eventID, result!.code!);
    // } catch (e) {
    //   e.toString();
    // }
  }

  @override
  Widget build(BuildContext context) {
    if (result != null) {
      print("${result!.code}is not null. starting username fetch.");
      getUsername();
    }
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderWidth: 10,
                borderColor: Color.fromARGB(255, 75, 167, 241),
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (name != '')
                  ? Text('$name checked in 🥳')
                  : Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }
}
