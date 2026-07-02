// lib/screens/alternate_flights_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/recovery_provider.dart';
import '../widgets/alternate_flight_card.dart';
import '../widgets/booking_summary_card.dart';
import 'otp_verification_screen.dart';

class AlternateFlightsScreen extends StatefulWidget {
  const AlternateFlightsScreen({super.key});

  @override
  State<AlternateFlightsScreen> createState() => _AlternateFlightsScreenState();
}

class _AlternateFlightsScreenState extends State<AlternateFlightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RecoveryProvider>();
      if (provider.alternateFlights.isEmpty) {
        provider.fetchAlternateFlights();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecoveryProvider>();
    final booking = provider.currentBooking;

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Alternate Flights')),
        body: const Center(child: Text('No booking found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Alternate Flights'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: BookingSummaryCard(booking: booking),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Fare details shown are compared against your original booking fare.',
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => provider.fetchAlternateFlights(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : provider.alternateFlights.isEmpty
                ? const Center(child: Text('No alternate flights available.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.alternateFlights.length,
                    itemBuilder: (context, index) {
                      final flight = provider.alternateFlights[index];
                      return AlternateFlightCard(
                        flight: flight,
                        isSelected:
                            provider.selectedFlightId == flight.flightId,
                        onTap: () =>
                            provider.setSelectedFlight(flight.flightId),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () {
                  if (provider.selectedFlightId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a flight')),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OtpVerificationScreen(),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Continue to OTP Verification',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
