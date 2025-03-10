import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StudentQRScreen extends StatelessWidget {
  final String tripId;
  final String studentId;
  final String type;

  const StudentQRScreen({
    super.key,
    required this.tripId,
    required this.studentId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final qrData = '$tripId|$studentId|$type';

    return Scaffold(
      appBar: AppBar(
        title: Text('${type == 'check_in' ? 'Check In' : 'Check Out'} QR Code'),
      ),
      body: Center(
        child: QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}
