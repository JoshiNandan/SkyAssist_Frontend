// lib/widgets/alternate_flight_card.dart
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/alternate_flight_model.dart';

class AlternateFlightCard extends StatelessWidget {
  final AlternateFlightModel flight;
  final bool isSelected;
  final VoidCallback onTap;

  const AlternateFlightCard({
    super.key,
    required this.flight,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Flight ${flight.flightNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (flight.label.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        flight.label,
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeColumn(flight.origin, flight.departureTime),
                  const Icon(Icons.flight_takeoff, color: AppColors.softSage),
                  _buildTimeColumn(flight.destination, flight.arrivalTime),
                ],
              ),
              // --- Fare section ---
              if (flight.fareAction != null) ...[
                const SizedBox(height: 12),
                _buildFareSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeColumn(String location, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          location,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(color: AppColors.text)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Fare helpers
  // ---------------------------------------------------------------------------

  /// Builds the compact fare-info container shown beneath the route row.
  Widget _buildFareSection() {
    final label = _fareLabel(flight.fareAction);
    final color = _fareColor(flight.fareAction);
    final icon = _fareIcon(flight.fareAction);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary label row
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          // Fare-difference detail (when applicable)
          if (flight.fareDifference != null && flight.fareDifference != 0) ...[
            const SizedBox(height: 4),
            Text(
              _fareDifferenceText(flight.fareAction, flight.fareDifference!),
              style: TextStyle(
                color: color.withValues(alpha: 0.85),
                fontSize: 12,
              ),
            ),
          ],

          // Total fare line
          if (flight.fare != null) ...[
            const SizedBox(height: 4),
            Text(
              'Fare: ${_formatCurrency(flight.fare!.currency, flight.fare!.amount)}',
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Maps [fareAction] to a human-readable label.
  String _fareLabel(String? fareAction) {
    switch (fareAction) {
      case 'NO_ADDITIONAL_FARE':
        return 'No additional fare';
      case 'LOWER_FARE_AVAILABLE':
        return 'Lower fare available';
      case 'FARE_DIFFERENCE_REQUIRED':
        return 'Additional fare required';
      default:
        return 'Fare details unavailable';
    }
  }

  /// Returns a theme-consistent colour for the fare action.
  Color _fareColor(String? fareAction) {
    switch (fareAction) {
      case 'NO_ADDITIONAL_FARE':
        return AppColors.success;
      case 'LOWER_FARE_AVAILABLE':
        return AppColors.primary; // teal — positive but distinct from success
      case 'FARE_DIFFERENCE_REQUIRED':
        return AppColors.warning;
      default:
        return AppColors.softSage;
    }
  }

  /// Returns a small leading icon for the fare row.
  IconData _fareIcon(String? fareAction) {
    switch (fareAction) {
      case 'NO_ADDITIONAL_FARE':
        return Icons.check_circle_outline;
      case 'LOWER_FARE_AVAILABLE':
        return Icons.arrow_downward;
      case 'FARE_DIFFERENCE_REQUIRED':
        return Icons.info_outline;
      default:
        return Icons.help_outline;
    }
  }

  /// Builds the ₹X-lower / ₹X-extra helper text.
  String _fareDifferenceText(String? fareAction, int difference) {
    final absValue = difference.abs();
    if (fareAction == 'LOWER_FARE_AVAILABLE') {
      return '₹$absValue lower than original fare';
    } else if (fareAction == 'FARE_DIFFERENCE_REQUIRED') {
      return '₹$absValue extra';
    }
    return '';
  }

  /// Formats an amount with its currency symbol.
  String _formatCurrency(String currency, int amount) {
    if (currency == 'INR') return '₹$amount';
    return '$currency $amount';
  }
}
