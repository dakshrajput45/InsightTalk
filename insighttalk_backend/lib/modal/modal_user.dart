class DsdUser {
  String? id;
  String? userName;
  String? email;
  DsdUserAddress? address;
  List<String>? category;

  DsdUser({
    this.userName,
    this.id,
    this.email,
    this.address,
    this.category,
  });

  factory DsdUser.fromJson(
      {required Map<String, dynamic> json, required String id}) {
    try {
      return DsdUser(
        id: id,
        userName: json['userName'],
        category: List<String>.from(json['category'] ?? []),
        address: json['address'] != null
            ? DsdUserAddress.fromJson(json: json['address'])
            : null,
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Map<String, dynamic> toJson({bool withId = false}) {
    return {
      if (userName != null) 'userName': userName,
      if (email != null) 'email': email,
      if (address != null) 'address': address?.toJson(),
      if (withId) 'id': id,
      if (category != null) 'category': category,
    };
  }
}

class DsdUserAddress {
  String? country;
  String? state;
  String? city;

  DsdUserAddress({
    this.country,
    this.state,
    this.city,
  });

  factory DsdUserAddress.fromJson({required Map<String, dynamic> json}) {
    return DsdUserAddress(
      country: json['country'],
      state: json['state'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (city != null) 'city': city,
    };
  }
}
