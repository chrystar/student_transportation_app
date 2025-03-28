import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/trip_model.dart';
import 'payment_screen.dart';

class TripConfirmationScreen extends StatelessWidget {
  final TripModel trip;

  const TripConfirmationScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Trip")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pickup Location: ${trip.pickupAddress}",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text("Dropoff Location: ${trip.dropoffAddress}",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text("Pickup Time: ${DateFormat('MMM dd, yyyy - hh:mm a').format(trip.pickupTime)}",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => PaymentScreen(trip: trip),
                  //   ),
                  // );
                },
                child: const Text("Proceed to Payment"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
