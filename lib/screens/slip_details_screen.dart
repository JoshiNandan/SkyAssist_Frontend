// lib/screens/slip_details_screen.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/recovery_slip_model.dart';

class SlipDetailsScreen extends StatelessWidget {
  final RecoverySlipModel slip;
  const SlipDetailsScreen({super.key, required this.slip});

  @override
  Widget build(BuildContext context) {
    final isFareAdj = slip.recoveryType.toUpperCase() == 'REBOOK' &&
        slip.status.toUpperCase().contains('PENDING');
    final accentColor = _accentColor(slip.recoveryType, isFareAdj: isFareAdj);
    final displayGenerated = slip.generatedAt.contains('T')
        ? slip.generatedAt.replaceFirst('T', '  ').replaceAll('Z', ' UTC').trim()
        : slip.generatedAt;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(_appBarTitle(slip.recoveryType, isFareAdj: isFareAdj)),
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header banner
            _buildHeader(accentColor, isFareAdj),
            const SizedBox(height: 16),

            // Passenger & booking
            _buildSectionCard(
              icon: Icons.person_outline,
              title: 'Passenger & Booking',
              child: Column(
                children: [
                  _row('Passenger', slip.passengerName),
                  _row('Booking ID', slip.bookingId),
                  _row('PNR', slip.pnr),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Original journey
            _buildSectionCard(
              icon: Icons.flight_outlined,
              title: 'Original Journey',
              child: Column(
                children: [
                  _row('Flight', slip.flightNumber),
                  _routeRow(slip.from, slip.to),
                  _row('Journey Date', slip.journeyDate),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Alternate flight (rebook only)
            if (slip.alternateFlightNumber != null) ...[ 
              _buildSectionCard(
                icon: Icons.flight_takeoff,
                title: 'Alternate Flight',
                child: Column(
                  children: [
                    _row('Flight', slip.alternateFlightNumber ?? '—'),
                    if (slip.alternateDeparture != null)
                      _row('Departure', slip.alternateDeparture!),
                    if (slip.alternateArrival != null)
                      _row('Arrival', slip.alternateArrival!),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Recovery details
            _buildSectionCard(
              icon: Icons.assignment_outlined,
              title: 'Recovery Details',
              child: Column(
                children: [
                  _row('Recovery Type', slip.recoveryType),
                  _row('Status', slip.status),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Reference
            _buildSectionCard(
              icon: Icons.tag,
              title: 'Request Reference',
              child: Column(
                children: [
                  _row('Slip ID', slip.slipId),
                  _row('Generated At', displayGenerated),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Instruction note
            if (slip.instruction != null) _buildNote(slip.instruction!),
            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color accentColor, bool isFareAdj) {
    final isPending = slip.status.toUpperCase().contains('PENDING');
    final statusColor = isPending ? AppColors.warning : AppColors.success;
    final statusIcon = isPending ? Icons.hourglass_top_rounded : Icons.verified_rounded;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.28)),
      ),
      child: Column(
        children: [
          Icon(_headerIcon(slip.recoveryType, isFareAdj: isFareAdj),
              color: accentColor, size: 40),
          const SizedBox(height: 12),
          Text(
            _appBarTitle(slip.recoveryType, isFareAdj: isFareAdj),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // ── Prominent status badge ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  slip.status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                Icon(icon, size: 17, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primary,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 13, color: AppColors.text.withValues(alpha: 0.55)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeRow(String from, String to) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(from,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.arrow_forward, size: 18, color: AppColors.softSage),
          ),
          Text(to,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildNote(String instruction) {
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
                  fontSize: 13, color: AppColors.text, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  String _appBarTitle(String type, {bool isFareAdj = false}) {
    switch (type.toUpperCase()) {
      case 'REFUND':
        return 'Refund Request Slip';
      case 'SUPPORT':
        return 'Support Request Slip';
      case 'REBOOK':
        return isFareAdj ? 'Fare Adjustment Slip' : 'Rebook Confirmation Slip';
      default:
        return 'Recovery Slip';
    }
  }

  IconData _headerIcon(String type, {bool isFareAdj = false}) {
    switch (type.toUpperCase()) {
      case 'REFUND':
        return Icons.account_balance_wallet_outlined;
      case 'SUPPORT':
        return Icons.headset_mic_outlined;
      case 'REBOOK':
        return isFareAdj ? Icons.receipt_long : Icons.flight_takeoff;
      default:
        return Icons.receipt_long;
    }
  }

  Color _accentColor(String type, {bool isFareAdj = false}) {
    switch (type.toUpperCase()) {
      case 'REFUND':
        return AppColors.success;
      case 'SUPPORT':
        return AppColors.primary;
      case 'REBOOK':
        return isFareAdj ? AppColors.warning : AppColors.success;
      default:
        return AppColors.primary;
    }
  }
}
