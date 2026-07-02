// lib/screens/fare_adjustment_slip_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/booking_model.dart';
import '../providers/recovery_provider.dart';
import 'booking_lookup_screen.dart';

class FareAdjustmentSlipScreen extends StatefulWidget {
  const FareAdjustmentSlipScreen({super.key});

  @override
  State<FareAdjustmentSlipScreen> createState() =>
      _FareAdjustmentSlipScreenState();
}

class _FareAdjustmentSlipScreenState extends State<FareAdjustmentSlipScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecoveryProvider>();
    final booking = provider.currentBooking;

    if (booking == null || provider.fareAdjustmentSlip == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: AppColors.background,
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 64,
                  color: AppColors.warning,
                ),
                SizedBox(height: 20),
                Text(
                  'Fare adjustment details are not available.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final slip = provider.fareAdjustmentSlip!;
    final result = provider.recoveryResult;
    final selectedFlight = result?['selectedFlight'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(slip),
            const SizedBox(height: 16),

            _buildSectionCard(
              icon: Icons.person_outline,
              title: 'Passenger & Booking',
              child: _buildPassengerDetails(booking),
            ),
            const SizedBox(height: 12),

            _buildSectionCard(
              icon: Icons.flight_outlined,
              title: 'Original Journey',
              child: _buildOriginalJourney(booking),
            ),
            const SizedBox(height: 12),

            _buildSectionCard(
              icon: Icons.flight_takeoff,
              title: 'Requested Alternate Flight',
              child: selectedFlight != null
                  ? _buildAlternateFlight(selectedFlight)
                  : _buildUnavailable(),
            ),
            const SizedBox(height: 12),

            _buildSectionCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Fare Summary',
              child: _buildFareSummary(provider),
            ),
            const SizedBox(height: 12),

            _buildSectionCard(
              icon: Icons.tag,
              title: 'Request Reference',
              child: _buildRequestReference(slip),
            ),
            const SizedBox(height: 16),

            _buildAirportNote(slip),
            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  provider.clearRecoveryFlow();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingLookupScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Back to Home',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      title: const Text('Fare Adjustment Slip'),
      elevation: 0,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(Map<String, dynamic> slip) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long, color: AppColors.warning, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Fare Adjustment Slip',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            slip['instruction'] as String? ??
                'Present this slip at the airport support desk for fare collection and final ticket reissue.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.text.withValues(alpha: 0.65),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildPassengerDetails(BookingModel booking) {
    return Column(
      children: [
        _dataRow('Passenger', booking.passengerName),
        _dataRow('Booking ID', booking.bookingId),
        _dataRow('PNR', booking.pnr),
        _dataRow('Route', booking.route),
        _dataRow('Travel Date', booking.travelDate),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildOriginalJourney(BookingModel booking) {
    if (booking.segments.isEmpty) {
      return _buildUnavailable();
    }

    final seg = booking.segments.first;

    return Column(
      children: [
        _dataRow('Flight', seg.flightNumber),
        _routeRow(seg.origin, seg.destination),
        _dataRow('Scheduled Departure', seg.scheduledDep),
        _dataRow('Scheduled Arrival', seg.scheduledArr),
        if (booking.disruption != null && booking.disruption!.label.isNotEmpty)
          _dataRow('Status', booking.disruption!.label),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildAlternateFlight(Map<String, dynamic> flight) {
    final label = flight['label']?.toString() ?? '';
    return Column(
      children: [
        _dataRow('Flight', flight['flightNumber']?.toString() ?? '—'),
        _routeRow(
          flight['origin']?.toString() ?? '—',
          flight['destination']?.toString() ?? '—',
        ),
        _dataRow('Departure', flight['departureTime']?.toString() ?? '—'),
        _dataRow('Arrival', flight['arrivalTime']?.toString() ?? '—'),
        if (label.isNotEmpty) _dataRow('Type', label),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildFareSummary(RecoveryProvider provider) {
    return Column(
      children: [
        _dataRow(
          'Original Fare',
          provider.originalFare != null ? '₹${provider.originalFare}' : '—',
        ),
        _dataRow(
          'New Flight Fare',
          provider.newFare != null ? '₹${provider.newFare}' : '—',
        ),
        const Divider(height: 20),
        _dataRow(
          'Additional Fare Required',
          provider.fareDifference != null ? '₹${provider.fareDifference}' : '—',
          highlight: true,
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildRequestReference(Map<String, dynamic> slip) {
    final requestId = slip['requestId']?.toString() ?? '—';
    final generatedAt = slip['generatedAt']?.toString() ?? '—';

    // Light formatting: replace T with a space and trim trailing Z for readability
    final displayDate = generatedAt.contains('T')
        ? generatedAt.replaceFirst('T', '  ').replaceAll('Z', ' UTC').trim()
        : generatedAt;

    return Column(
      children: [
        _dataRow('Request ID', requestId),
        _dataRow('Generated At', displayDate),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildAirportNote(Map<String, dynamic> slip) {
    final instruction =
        slip['instruction'] as String? ??
        'Please present this fare adjustment slip along with your booking '
            'reference at the airport support desk. Additional fare, if applicable, '
            'will be collected by airline staff before final ticket reissue.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.text,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Wraps [child] in a bordered card with a left-accented section heading.
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primary,
                      letterSpacing: 0.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Section body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  /// Label → value row used inside section bodies.
  Widget _dataRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: constraints.maxWidth * 0.35,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                    color: highlight ? AppColors.warning : AppColors.text,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Origin → destination visual row.
  Widget _routeRow(String origin, String destination) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              origin,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.arrow_forward,
              size: 18,
              color: AppColors.softSage,
            ),
          ),
          Flexible(
            child: Text(
              destination,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailable() {
    return Text(
      'Details unavailable',
      style: TextStyle(
        fontSize: 13,
        color: AppColors.text.withValues(alpha: 0.5),
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
