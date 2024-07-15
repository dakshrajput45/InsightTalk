import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/apis/userApis/user_details_api.dart';
import 'package:insighttalk_backend/modal/category.dart';
import 'package:insighttalk_backend/modal/modal_user.dart';
import 'package:insighttalk_frontend/router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
  final DsdUserDetailsApis _dsdUserApis = DsdUserDetailsApis();
  List<DsdCategory>? categories = [];
  DsdUser? userData;

  Future<void> getCategory() async {
    try {
      String userId = _itUserAuthSDK.getUser()!.uid;
      List<DsdCategory>? fetchedCategories =
          await _dsdUserApis.fetchUserCategories(userId: userId);

      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> getUserData() async {
    try {
      String userId = _itUserAuthSDK.getUser()!.uid;
      DsdUser? fetchedUserData =
          await _dsdUserApis.fetchUserById(userId: userId);

      setState(() {
        userData = fetchedUserData;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getCategory();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(

            children: [
              Container(
                height: 120,
                width: 120,
                margin: const EdgeInsets.only(top: 40, left: 30, bottom: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  image: DecorationImage(
                    image: userData != null && userData!.profileImage != null
                        ? NetworkImage(userData!
                            .profileImage!) // Safe to use ! here after null check
                        : NetworkImage(
                            'https://imgv3.fotor.com/images/blog-cover-image/10-profile-picture-ideas-to-make-you-stand-out.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 30, bottom: 30),
                child: PopupMenuButton<String>(
                  onSelected: (String value) {
                    // Handle menu item selection
                    switch (value) {
                      case 'Edit Profile':
                        context.pushNamed(routeNames.editprofileview);
                        break;
                      case 'Settings':
                        // Navigate to settings page
                        break;
                      case 'Logout':
                        // Perform logout
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return {'Edit Profile', 'Settings', 'Logout'}
                        .map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(
                          choice,
                          style: const TextStyle(
                            fontSize: 24.0,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  icon: Icon(
                    Icons.more_vert,
                    size: 4.sh,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${userData?.userName}",
                  style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "${userData?.address?.city},${userData?.address?.state},${userData?.address?.country}",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30.0),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Categories",
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          if (categories != null && categories!.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: categories!.length,
                itemBuilder: (context, index) {
                  final category = categories![index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Image.network(
                              category.categoryImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            category.categoryTitle!,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  Text(
                    "No Categories Selected Please Add Some",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          Center(
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Text(
                    'Get personalized solutions from experts!',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Connect with knowledgeable experts to solve your queries quickly and effectively',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.blueGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
