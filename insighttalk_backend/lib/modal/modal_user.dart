import 'package:cloud_firestore/cloud_firestore.dart';

class DsdUser {
  String? id;
  String? userName;
  String? email;
  DateTime? dateOfBirth;
  DsdUserAddress? address;
  List<String>? category;
  String? profileImage; 

  DsdUser({
    this.userName,
    this.id,
    this.email,
    this.address,
    this.dateOfBirth,
    this.category,
    this.profileImage,
  });

  factory DsdUser.fromJson({
    required Map<String, dynamic> json,
    required String id,
  }) {
    try {
      return DsdUser(
        id: id,
        userName: json['userName'],
        email: json['email'],
        dateOfBirth: (json['dateOfBirth'] != null) ? (json['dateOfBirth'] as Timestamp).toDate() : DateTime.now(),
        category: List<String>.from(json['category'] ?? []),
        address: json['address'] != null
            ? DsdUserAddress.fromJson(json: json['address'])
            : null,
        profileImage: json['profileImage'], // Parse profile image URL
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
      if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      if (withId) 'id': id,
      if (category != null) 'category': category,
      if (profileImage != null) 'profileImage': profileImage, // Include profile image URL in JSON output
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
    this.city, String? profileImage,
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