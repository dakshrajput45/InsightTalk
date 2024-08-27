import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insighttalk_backend/apis/category/category_apis.dart';
import 'package:insighttalk_backend/apis/chat/chat_api.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/apis/userApis/user_details_api.dart';
import 'package:insighttalk_backend/modal/modal_category.dart';
import 'package:insighttalk_backend/modal/modal_user.dart';
import 'package:insighttalk_frontend/pages/expert/expert_controller.dart';
import 'package:insighttalk_frontend/pages/userProfile/editprofile_controller.dart';
import 'package:insighttalk_frontend/router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
  final DsdProfileController _dsdProfileController = DsdProfileController();
  final DsdChatApis _dsdChatApis = DsdChatApis();
  bool _loading = true;
  List<DsdCategory>? categories = [];
  DsdUser? userData;

  @override
  void initState() {
    super.initState();
    _loadData(); // Load data in a separate method
  }

  Future<void> _loadData() async {
    await getUserData();
    await loadProfileImage();

    setState(() {
      _loading = false;
    });
  }

  Future<void> getUserData() async {
    try {
      ProfileData data = await _dsdProfileController.getProfileData();
      setState(() {
        categories = data.categories;
        userData = data.user;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadProfileImage() async {
    if (userData?.profileImage != null) {
      await precacheImage(NetworkImage(userData!.profileImage!), context);
    }
  }

  var defaultImage =
      "https://imgv3.fotor.com/images/blog-cover-image/10-profile-picture-ideas-to-make-you-stand-out.jpg";
  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 40, left: 16, bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade200,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: CachedNetworkImage(
                        imageUrl: userData?.profileImage ?? defaultImage,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(right: 2.sh, bottom: 8.sh),
                      child: PopupMenuButton<String>(
                        onSelected: (String value) async {
                          // Handle menu item selection
                          switch (value) {
                            case 'Edit Profile':
                              context.goNamed(routeNames.editprofileview);
                              break;
                            case 'Settings':
                              // Navigate to settings page
                              break;
                            case 'Logout':
                              // Perform logout
                              _itUserAuthSDK.signOut();
                              context.goNamed(routeNames.login);
                              break;
                            case 'create chat room':
                              await _dsdChatApis.createChatRoom(
                                  "g5aIvBvX3TgkhAue0cKOKdTrU1r1", "g5aIvBvX3TgkhAue0cKOKdTrU1r1");
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return {'Edit Profile', 'Settings', 'Logout', 'create chat room'}
                              .map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(
                                choice,
                                style: TextStyle(
                                  fontSize: 2.sh,
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
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${userData?.userName}",
                        style: TextStyle(fontSize: 4.sh, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${userData?.address?.city}, ${userData?.address?.state}, ${userData?.address?.country}",
                        style: TextStyle(
                          fontSize: 2.sh,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  height: 12,
                ),
                if (categories!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12.0),
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
                        return GestureDetector(
                          onTap: () async {
                            final categoryTitle = category.categoryTitle!;
                            context.push('/expertsOfCategory/$categoryTitle');
                          },
                          child: Card(
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
                                    style: TextStyle(
                                      fontSize: 1.3.sh,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
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
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
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
                          textAlign: TextAlign.center,
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

  @override
  void dispose() {
    // Cancel timers, close streams, etc.
    super.dispose();
  }
}
