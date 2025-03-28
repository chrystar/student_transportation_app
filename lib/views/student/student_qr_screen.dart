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
    // Validate input data
    if (tripId.isEmpty || studentId.isEmpty || type.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text(
            'Invalid QR Code Data',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    // Generate QR data
    final qrData = '$tripId|$studentId|$type';

    return Scaffold(
      appBar: AppBar(
        title: Text('${type == 'check_in' ? 'Check In' : 'Check Out'} QR Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // QR Code
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250.0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              errorCorrectionLevel: QrErrorCorrectLevel.H, // High error correction
            ),
            const SizedBox(height: 20),

            // Trip and Student Information
            Text(
              'Trip ID: $tripId',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Student ID: $studentId',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Type: ${type == 'check_in' ? 'Check In' : 'Check Out'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Instructions
            const Text(
              'Please scan this QR code to proceed.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Back Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                backgroundColor: const Color(0xffEC441E),
              ),
              child: const Text(
                'Back',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}