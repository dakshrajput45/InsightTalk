import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insighttalk_frontend/pages/expert/expert_profile_view.dart';
import 'package:insighttalk_frontend/router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExpertCard extends StatelessWidget {
  final String profilePhoto;
  final String expertId;
  final String name;
  String? description;
  final double rating;

  ExpertCard({
    required this.profilePhoto,
    required this.expertId,
    required this.name,
    this.description,
    required this.rating,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(
        routeNames.expertprofileview,
        pathParameters: {'expertId': expertId},
      ),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: AspectRatio(
          aspectRatio: 13 / 16,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: Device.screenType == ScreenType.mobile ? 4.sh : 50,
                  backgroundImage: NetworkImage(profilePhoto),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: Device.screenType == ScreenType.mobile
                              ? 16.sp
                              : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: 7.0,
                      ),
                      Text(
                        description!,
                        style: TextStyle(
                          fontSize: Device.screenType == ScreenType.mobile
                              ? 14.sp
                              : 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color.fromARGB(255, 44, 184, 240),
                            size: 20.0,
                          ),
                          const SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              color: Color.fromARGB(255, 44, 184, 240),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
