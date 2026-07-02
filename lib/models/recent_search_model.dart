// lib/models/recent_search_model.dart
class RecentSearchModel {
  final String pnr;
  final String lastName;

  RecentSearchModel({required this.pnr, required this.lastName});

  Map<String, dynamic> toJson() => {'pnr': pnr, 'lastName': lastName};

  factory RecentSearchModel.fromJson(Map<String, dynamic> json) {
    return RecentSearchModel(
      pnr: json['pnr'] ?? '',
      lastName: json['lastName'] ?? '',
    );
  }
}
