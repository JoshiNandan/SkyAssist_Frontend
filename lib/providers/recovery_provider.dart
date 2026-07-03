// lib/providers/recovery_provider.dart
import 'package:flutter/foundation.dart';

import '../models/alternate_flight_model.dart';
import '../models/booking_model.dart';
import '../models/recent_search_model.dart';
import '../models/recovery_slip_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/slip_storage_service.dart';

class RecoveryProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final LocalStorageService _storage = LocalStorageService();

  BookingModel? currentBooking;
  List<RecentSearchModel> recentSearches = [];
  bool isLoading = false;
  String? errorMessage;

  // Part 2A state
  List<AlternateFlightModel> alternateFlights = [];
  String? pendingAction; // REBOOK / REFUND / SUPPORT
  String? selectedFlightId;
  String supportReason = "";

  // Part 2B state
  String? maskedOtpDestination;
  String? otpDebugCode;
  String? successMessage;
  Map<String, dynamic>? recoveryResult;

  // Part 3 — fare-adjustment rebook state
  String? recoveryStatus;
  int? fareDifference;
  int? originalFare;
  int? newFare;
  Map<String, dynamic>? fareAdjustmentSlip;

  // Refund / Support slip state
  Map<String, dynamic>? recoverySlip;

  // Slip persistence state
  final SlipStorageService _slipStorage = SlipStorageService();
  RecoverySlipModel? lastSavedSlip;
  RecoverySlipModel? duplicateSlip; // non-null when a duplicate was detected

  void setPendingAction(String action) {
    pendingAction = action;
    notifyListeners();
  }

  void setSelectedFlight(String flightId) {
    selectedFlightId = flightId;
    notifyListeners();
  }

  void setSupportReason(String reason) {
    supportReason = reason;
    notifyListeners();
  }

  void clearRecoveryFlow() {
    alternateFlights = [];
    pendingAction = null;
    selectedFlightId = null;
    supportReason = "";
    errorMessage = null;
    maskedOtpDestination = null;
    otpDebugCode = null;
    successMessage = null;
    recoveryResult = null;
    recoveryStatus = null;
    fareDifference = null;
    originalFare = null;
    newFare = null;
    fareAdjustmentSlip = null;
    recoverySlip = null;
    lastSavedSlip = null;
    duplicateSlip = null;
    notifyListeners();
  }

  Future<bool> fetchAlternateFlights() async {
    if (currentBooking == null) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      alternateFlights = await _api.getAlternateFlights(
        currentBooking!.bookingId,
      );
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestOtpForCurrentBooking() async {
    if (currentBooking == null) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.requestOtp(currentBooking!.bookingId);
      maskedOtpDestination = response['maskedDestination'];
      if (response.containsKey('otp')) {
        otpDebugCode = response['otp'].toString();
      }
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtpCode(String otp) async {
    if (currentBooking == null) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.verifyOtp(currentBooking!.bookingId, otp);
      isLoading = false;
      notifyListeners();
      return response['otpVerified'] ?? false;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> executePendingRecoveryAction() async {
    if (currentBooking == null) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      Map<String, dynamic> response;
      if (pendingAction == "REFUND") {
        response = await _api.requestRefund(currentBooking!.bookingId);
      } else if (pendingAction == "SUPPORT") {
        response = await _api.requestSupport(
          currentBooking!.bookingId,
          supportReason,
        );
      } else if (pendingAction == "REBOOK") {
        if (selectedFlightId == null) throw Exception("No flight selected");
        response = await _api.rebookFlight(
          currentBooking!.bookingId,
          selectedFlightId!,
        );
      } else {
        throw Exception("Unknown action");
      }

      recoveryResult = response;
      successMessage = response['message'];
      recoveryStatus = response['recoveryStatus'] as String?;

      // Extract fare-adjustment details when present (rebook only)
      if (pendingAction == "REBOOK" &&
          recoveryStatus == 'PENDING_FARE_ADJUSTMENT') {
        fareDifference = (response['fareDifference'] as num?)?.toInt();
        originalFare = (response['originalFare'] as num?)?.toInt();
        newFare = (response['newFare'] as num?)?.toInt();
        fareAdjustmentSlip = response['slip'] as Map<String, dynamic>?;
      }

      // Extract slip for direct rebook (equal/lower fare), refund, and support
      if ((pendingAction == "REBOOK" && recoveryStatus == 'REBOOKED') ||
          pendingAction == "REFUND" ||
          pendingAction == "SUPPORT") {
        recoverySlip = response['slip'] as Map<String, dynamic>?;
      }

      // Persist slip locally
      await _persistSlipFromResponse(response);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _persistSlipFromResponse(Map<String, dynamic> response) async {
    if (currentBooking == null) return;
    final booking = currentBooking!;

    // Resolve the slip object from the response
    final rawSlip = (response['slip'] as Map<String, dynamic>?) ??
        (pendingAction == 'REBOOK' &&
                recoveryStatus == 'PENDING_FARE_ADJUSTMENT'
            ? fareAdjustmentSlip
            : null);
    if (rawSlip == null) return;

    // ── Strict validation: all core fields must be present and non-empty ──
    final slipId = rawSlip['requestId'] as String?;
    final bookingId = booking.bookingId;
    final pnr = booking.pnr;
    final passengerName = booking.passengerName;
    final seg = booking.segments.isNotEmpty ? booking.segments.first : null;
    final flightNumber = seg?.flightNumber ?? '';
    final from = seg?.origin ?? '';
    final to = seg?.destination ?? '';
    final journeyDate = booking.travelDate;
    final recoveryType = (rawSlip['type'] as String?) ?? pendingAction ?? '';

    if (bookingId.isEmpty ||
        pnr.isEmpty ||
        passengerName.isEmpty ||
        flightNumber.isEmpty ||
        from.isEmpty ||
        to.isEmpty ||
        journeyDate.isEmpty ||
        recoveryType.isEmpty) {
      return; // incomplete data — do not persist a broken slip
    }

    final altFlight =
        (rawSlip['selectedFlight'] as Map<String, dynamic>?) ??
        (recoveryResult?['selectedFlight'] as Map<String, dynamic>?);

    final slip = RecoverySlipModel(
      slipId: (slipId != null && slipId.isNotEmpty)
          ? slipId
          : 'SLP-${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      pnr: pnr,
      passengerName: passengerName,
      flightNumber: flightNumber,
      from: from,
      to: to,
      journeyDate: journeyDate,
      recoveryType: recoveryType,
      status: _resolveSlipStatus(rawSlip['status'] as String?),
      generatedAt: rawSlip['generatedAt'] as String? ?? DateTime.now().toIso8601String(),
      alternateFlightId: altFlight?['flightId']?.toString(),
      alternateFlightNumber: altFlight?['flightNumber']?.toString(),
      alternateDeparture: altFlight?['departureTime']?.toString(),
      alternateArrival: altFlight?['arrivalTime']?.toString(),
      instruction: rawSlip['instruction'] as String?,
    );

    final duplicate = await _slipStorage.saveSlip(slip);
    if (duplicate != null) {
      duplicateSlip = duplicate;
    } else {
      lastSavedSlip = slip;
      duplicateSlip = null;
    }
  }

  /// Maps a raw backend status to a guaranteed non-empty display status.
  /// PENDING_FARE_ADJUSTMENT keeps its own label; everything else that is
  /// blank or unrecognised falls back to CONFIRMED.
  String _resolveSlipStatus(String? raw) {
    if (raw != null && raw.isNotEmpty) return raw;
    if (recoveryStatus == 'PENDING_FARE_ADJUSTMENT') return 'PENDING_FARE_ADJUSTMENT';
    return 'CONFIRMED';
  }

  Future<void> loadRecentSearches() async {
    recentSearches = await _storage.getRecentSearches();
    notifyListeners();
  }

  Future<bool> lookupBooking(String pnr, String lastName) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final booking = await _api.lookupBooking(pnr, lastName);
      currentBooking = booking;

      await _storage.saveRecentSearch(
        RecentSearchModel(pnr: pnr, lastName: lastName),
      );
      await loadRecentSearches();

      isLoading = false;
      notifyListeners();
      return true;
    } on BookingNotFoundException {
      errorMessage = 'No booking found for the entered PNR and last name.';
      isLoading = false;
      notifyListeners();
      return false;
    } on ApiTimeoutException {
      errorMessage =
          'The server is taking longer than expected to respond. Please wait a moment and try again.';
      isLoading = false;
      notifyListeners();
      return false;
    } on ApiNetworkException {
      errorMessage =
          'Unable to reach SkyAssist services. Please check your internet connection and try again.';
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> lookupFromRecent(RecentSearchModel search) async {
    return lookupBooking(search.pnr, search.lastName);
  }
}
