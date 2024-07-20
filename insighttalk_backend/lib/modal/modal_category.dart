class DsdCategory {
  String? categoryImage;
  int? minValue;
  int? maxValue;
  String? categoryTitle;
  List<String>? experts;
  List<String>? users;
  int? totalParticipants;

  DsdCategory({
    this.minValue,
    this.maxValue,
    this.categoryImage,
    this.categoryTitle,
    this.experts,
    this.users,
  });

  factory DsdCategory.fromJson(
      {required Map<String, dynamic> json, required String id}) {
    try {
      return DsdCategory(
        minValue: json['minValue'],
        maxValue: json['maxValue'],
        categoryImage: json['categoryImage'],
        categoryTitle: json['categoryTitle'],
        experts: List<String>.from(json['experts'] ?? []),
        users: List<String>.from(json['users'] ?? []),
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Map<String, dynamic> toJson({bool withId = false}) {
    return {
      if (minValue != null) 'minValue': minValue,
      if (maxValue != null) 'maxValue': maxValue,
      if (experts != null) 'experts': experts,
      if (users != null) 'users': users,
      if (categoryTitle != null) 'categoryTitle': categoryTitle,
      if (categoryImage != null) 'categoryImage': categoryImage,
    };
  }
}
