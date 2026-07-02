// lib/models/alternate_flight_model.dart

/// Nested model for the fare object returned by the backend.
class FareInfo {
  final String currency;
  final int amount;

  FareInfo({
    required this.currency,
    required this.amount,
  });

  factory FareInfo.fromJson(Map<String, dynamic> json) {
    return FareInfo(
      currency: json['currency'] ?? '',
      amount: json['amount'] ?? 0,
    );
  }
}

class AlternateFlightModel {
  final String flightId;
  final String flightNumber;
  final String origin;
  final String destination;
  final String departureTime;
  final String arrivalTime;
  final String label;

  // Fare-aware fields (nullable — older responses may not include them)
  final FareInfo? fare;
  final int? fareDifference;
  final String? fareAction;

  AlternateFlightModel({
    required this.flightId,
    required this.flightNumber,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.label,
    this.fare,
    this.fareDifference,
    this.fareAction,
  });

  factory AlternateFlightModel.fromJson(Map<String, dynamic> json) {
    return AlternateFlightModel(
      flightId: json['flightId'] ?? '',
      flightNumber: json['flightNumber'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      departureTime: json['departureTime'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
      label: json['label'] ?? '',
      fare: json['fare'] != null
          ? FareInfo.fromJson(json['fare'] as Map<String, dynamic>)
          : null,
      fareDifference: json['fareDifference'] as int?,
      fareAction: json['fareAction'] as String?,
    );
  }
}
