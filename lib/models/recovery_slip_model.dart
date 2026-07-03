// lib/models/recovery_slip_model.dart

class RecoverySlipModel {
  final String slipId;
  final String bookingId;
  final String pnr;
  final String passengerName;
  final String flightNumber;
  final String from;
  final String to;
  final String journeyDate;
  final String recoveryType; // REBOOK | REFUND | SUPPORT
  final String status;
  final String generatedAt;
  final String? alternateFlightId;
  final String? alternateFlightNumber;
  final String? alternateDeparture;
  final String? alternateArrival;
  final String? instruction;

  RecoverySlipModel({
    required this.slipId,
    required this.bookingId,
    required this.pnr,
    required this.passengerName,
    required this.flightNumber,
    required this.from,
    required this.to,
    required this.journeyDate,
    required this.recoveryType,
    required this.status,
    required this.generatedAt,
    this.alternateFlightId,
    this.alternateFlightNumber,
    this.alternateDeparture,
    this.alternateArrival,
    this.instruction,
  });

  Map<String, dynamic> toJson() => {
        'slipId': slipId,
        'bookingId': bookingId,
        'pnr': pnr,
        'passengerName': passengerName,
        'flightNumber': flightNumber,
        'from': from,
        'to': to,
        'journeyDate': journeyDate,
        'recoveryType': recoveryType,
        'status': status,
        'generatedAt': generatedAt,
        'alternateFlightId': alternateFlightId,
        'alternateFlightNumber': alternateFlightNumber,
        'alternateDeparture': alternateDeparture,
        'alternateArrival': alternateArrival,
        'instruction': instruction,
      };

  factory RecoverySlipModel.fromJson(Map<String, dynamic> json) {
    return RecoverySlipModel(
      slipId: json['slipId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      pnr: json['pnr'] ?? '',
      passengerName: json['passengerName'] ?? '',
      flightNumber: json['flightNumber'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      journeyDate: json['journeyDate'] ?? '',
      recoveryType: json['recoveryType'] ?? '',
      status: json['status'] ?? '',
      generatedAt: json['generatedAt'] ?? '',
      alternateFlightId: json['alternateFlightId'],
      alternateFlightNumber: json['alternateFlightNumber'],
      alternateDeparture: json['alternateDeparture'],
      alternateArrival: json['alternateArrival'],
      instruction: json['instruction'],
    );
  }
}
