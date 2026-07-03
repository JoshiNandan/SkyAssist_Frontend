// lib/services/slip_storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recovery_slip_model.dart';

class SlipStorageService {
  static const _key = 'generated_slips';

  Future<List<RecoverySlipModel>> getAllSlips() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    return rawList
        .map((e) => RecoverySlipModel.fromJson(jsonDecode(e)))
        .toList();
  }

  /// Returns null on success, or an existing slip if a duplicate is found.
  Future<RecoverySlipModel?> saveSlip(RecoverySlipModel slip) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAllSlips();

    final existing = current
        .where((s) => s.bookingId == slip.bookingId)
        .firstOrNull;

    if (existing != null) return existing;

    current.insert(0, slip);
    final encoded = current.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, encoded);
    return null;
  }

  Future<void> deleteSlip(String slipId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAllSlips();
    current.removeWhere((s) => s.slipId == slipId);
    final encoded = current.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }
}
