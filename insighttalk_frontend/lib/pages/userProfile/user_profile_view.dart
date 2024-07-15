import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insighttalk_backend/apis/category/category_apis.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/apis/userApis/user_details_api.dart';
import 'package:insighttalk_backend/modal/category.dart';
import 'package:insighttalk_frontend/router.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
  final DsdUserDetailsApis _dsdUserApis = DsdUserDetailsApis();

  Future<void> getCategory() async {
  try {
    String userId = _itUserAuthSDK.getUser()!.uid; // Assuming getUser() returns a user object with uid
    List<DsdCategory>? categories = await _dsdUserApis.fetchUserCategories(userId: userId);
    if (categories != null) {
      print('Fetched categories: $categories');
    } else {
      print('Categories not found or error occurred.');
    }
    } catch (e) {
    print('Error fetching categories: $e');
  }
}
void initState() {
    super.initState();
    getCategory(); // Fetch categories when the widget is initialized
  }
  String _imageUrl =
      "https://imgv3.fotor.com/images/blog-cover-image/10-profile-picture-ideas-to-make-you-stand-out.jpg";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 120,
          width: 120,
          margin: EdgeInsets.only(top: 40, left: 30, bottom: 10),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            image: DecorationImage(
              image: NetworkImage(_imageUrl) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tom Billa",
                style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
              ),
              Text(
                "Billa Land, State, India",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
