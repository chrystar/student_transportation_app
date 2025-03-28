import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final String from;
  final String to;
  final DateTime date;
  final TimeOfDay time;
  final int passengers;
  final Function onPaymentSuccess;

  const PaymentScreen({
    super.key,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.passengers,
    required this.onPaymentSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Credit Card'),
              onTap: () {
                // Simulate payment success
                onPaymentSuccess();
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Wallet'),
              onTap: () {
                // Simulate payment success
                onPaymentSuccess();
              },
            ),
            ListTile(
              leading: const Icon(Icons.paypal),
              title: const Text('PayPal'),
              onTap: () {
                // Simulate payment success
                onPaymentSuccess();
              },
            ),
          ],
        ),
      ),
    );
  }
}