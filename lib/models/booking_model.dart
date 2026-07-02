class BookingModel {
  final String bookingId;
  final String pnr;
  final String passengerName;
  final String route;
  final String travelDate;
  final DisruptionInfo? disruption;
  final List<FlightSegment> segments;
  final PolicyInfo? policy;
  final List<String> eligibleActions;

  BookingModel({
    required this.bookingId,
    required this.pnr,
    required this.passengerName,
    required this.route,
    required this.travelDate,
    this.disruption,
    required this.segments,
    this.policy,
    required this.eligibleActions,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final passenger = json['passenger'] as Map<String, dynamic>? ?? {};
    final trip = json['trip'] as Map<String, dynamic>? ?? {};

    final firstName = passenger['firstName'] ?? '';
    final lastName = passenger['lastName'] ?? '';

    final origin = trip['origin'] ?? '';
    final destination = trip['destination'] ?? '';

    return BookingModel(
      bookingId: json['bookingId'] ?? '',
      pnr: json['pnr'] ?? '',
      passengerName: '$firstName $lastName'.trim(),
      route: '$origin → $destination',
      travelDate: trip['travelDate'] ?? '',
      disruption: json['disruption'] != null
          ? DisruptionInfo.fromJson(json['disruption'])
          : null,
      segments: (json['segments'] as List<dynamic>? ?? [])
          .map((e) => FlightSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
      policy: json['policy'] != null
          ? PolicyInfo.fromJson(json['policy'])
          : null,
      eligibleActions: (json['eligibleActions'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class DisruptionInfo {
  final String type;
  final String label;
  final String reason;
  final String message;
  final String? impactSummary;

  DisruptionInfo({
    required this.type,
    required this.label,
    required this.reason,
    required this.message,
    this.impactSummary,
  });

  factory DisruptionInfo.fromJson(Map<String, dynamic> json) {
    return DisruptionInfo(
      type: json['type'] ?? '',
      label: json['statusLabel'] ?? '',
      reason: json['reason'] ?? '',
      message: json['message'] ?? '',
      impactSummary: json['impactSummary'],
    );
  }
}

class FlightSegment {
  final String flightNumber;
  final String origin;
  final String destination;
  final String scheduledDep;
  final String scheduledArr;
  final String? updatedDep;
  final String? updatedArr;
  final String status;
  final int delayMinutes;

  FlightSegment({
    required this.flightNumber,
    required this.origin,
    required this.destination,
    required this.scheduledDep,
    required this.scheduledArr,
    this.updatedDep,
    this.updatedArr,
    required this.status,
    this.delayMinutes = 0,
  });

  factory FlightSegment.fromJson(Map<String, dynamic> json) {
    return FlightSegment(
      flightNumber: json['flightNumber'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      scheduledDep: json['scheduledDepartureTime'] ?? '',
      scheduledArr: json['scheduledArrivalTime'] ?? '',
      updatedDep: json['updatedDepartureTime'],
      updatedArr: json['updatedArrivalTime'],
      status: json['status'] ?? '',
      delayMinutes: json['delayMinutes'] ?? 0,
    );
  }
}

class PolicyInfo {
  final bool refundEligible;
  final bool rebookEligible;
  final bool supportEligible;
  final String? eligibilityNote;

  PolicyInfo({
    required this.refundEligible,
    required this.rebookEligible,
    required this.supportEligible,
    this.eligibilityNote,
  });

  factory PolicyInfo.fromJson(Map<String, dynamic> json) {
    return PolicyInfo(
      refundEligible: json['refundEligible'] ?? false,
      rebookEligible: json['rebookEligible'] ?? false,
      supportEligible: json['supportEligible'] ?? false,
      eligibilityNote: json['eligibilityNote'],
    );
  }
}
