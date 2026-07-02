import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recent_search_model.dart';

class LocalStorageService {
  static const _key = 'recent_searches';

  Future<List<RecentSearchModel>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    return rawList
        .map((e) => RecentSearchModel.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> saveRecentSearch(RecentSearchModel search) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getRecentSearches();
    // Remove duplicate (same pnr + lastName)
    current.removeWhere((e) => e.pnr == search.pnr && e.lastName == search.lastName);
    // Insert at top
    current.insert(0, search);
    // Keep only latest 3
    if (current.length > 3) {
      current.removeRange(3, current.length);
    }
    final encoded = current.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }
}
