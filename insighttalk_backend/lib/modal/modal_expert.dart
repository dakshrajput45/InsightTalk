import 'package:cloud_firestore/cloud_firestore.dart';

class DsdExpert {
  String? id;
  String? expertName;
  String? email;
  String? expertise;
  String? about;
  String? fcmToken;
  DateTime? dateOfBirth;
  DsdExpertAddress? address;
  List<String>? category;
  String? profileImage; // Changed to store a single image URL
  int? sumOfRatings; // Sum of all ratings
  int? numberOfRatings; // Number of ratings
  Map<DateTime, List<Map<String, DateTime>>>? availability;

  DsdExpert({
    this.expertName,
    this.id,
    this.email,
    this.expertise,
    this.dateOfBirth,
    this.about,
    this.address,
    this.category,
    this.profileImage,
    this.fcmToken,
    this.numberOfRatings = 0,
    this.sumOfRatings = 0,
    this.availability,
  });

  factory DsdExpert.fromJson({
    required Map<String, dynamic> json,
    required String id,
  }) {
    try {
      return DsdExpert(
        id: id,
        expertName: json['expertName'],
        email: json['email'],
        expertise: json['expertise'],
        fcmToken: json['fcmToken'],
        dateOfBirth: (json['dateOfBirth'] != null)
            ? (json['dateOfBirth'] as Timestamp).toDate()
            : DateTime.now(),
        about: json['about'],
        category: List<String>.from(json['category'] ?? []),
        address: json['address'] != null
            ? DsdExpertAddress.fromJson(json: json['address'])
            : null,
        profileImage: json['profileImage'], // Parse profile image URL
        sumOfRatings: json['sumOfRatings'] ?? 0, // Parse sum of ratings
        numberOfRatings:
            json['numberOfRatings'] ?? 0, // Parse number of ratings
        availability: (json['availability'] as Map<String, dynamic>?)?.map(
          (date, slots) => MapEntry(
            (date as Timestamp).toDate(),
            (slots as List).map((slot) {
              return (slot as Map<String, dynamic>).map(
                (timeType, time) => MapEntry(
                  timeType,
                  (time as Timestamp).toDate(),
                ),
              );
            }).toList(),
          ),
        ),
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Map<String, dynamic> toJson({bool withId = false}) {
    return {
      if (expertName != null) 'expertName': expertName,
      if (email != null) 'email': email,
      if (address != null) 'address': address?.toJson(),
      if (expertise != null) 'expertise': expertise,
      if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      if (about != null) 'about': about,
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (withId) 'id': id,
      if (category != null) 'category': category,
      if (profileImage != null)
        'profileImage':
            profileImage, // Include profile image URL in JSON output
      if (sumOfRatings != null)
        'sumOfRatings': sumOfRatings, // Include sum of ratings in JSON output
      if (numberOfRatings != null)
        'numberOfRatings':
            numberOfRatings, // Include number of ratings in JSON output
      'availability': availability?.map((date, slots) {
        return MapEntry(
          Timestamp.fromDate(date),
          slots.map((slot) {
            return slot.map((timeType, time) {
              return MapEntry(timeType, Timestamp.fromDate(time));
            });
          }).toList(),
        );
      }),
    };
  }

  double get averageRating {
    if (numberOfRatings == 0) return 0.0;
    return sumOfRatings! / (numberOfRatings! * 5);
  }
}

class DsdExpertAddress {
  String? country;
  String? state;
  String? city;

  DsdExpertAddress({
    this.country,
    this.state,
    this.city,
    String? profileImage,
  });

  factory DsdExpertAddress.fromJson({required Map<String, dynamic> json}) {
    return DsdExpertAddress(
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
