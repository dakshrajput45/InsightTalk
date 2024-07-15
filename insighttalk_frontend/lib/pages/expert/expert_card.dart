import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExpertCard extends StatelessWidget {
  final String profilePhoto;
  final String name;
  final String description;
  final double rating;

  const ExpertCard(
      {required this.profilePhoto,
      required this.name,
      required this.description,
      required this.rating,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Device.screenType == ScreenType.mobile
          ? AspectRatio(
              aspectRatio: 13 / 16,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 10.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 4.sh,
                      backgroundImage: AssetImage(profilePhoto),
                    ),
                    SizedBox(
                      height: 0.4.sh,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                              fontSize: 15.5.sp, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 1.sw,
                        ),
                        Text(
                          description,
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 7.0,
                        ),
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
                                  color: Color.fromARGB(255, 44, 184, 240)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ))
          : AspectRatio(
              aspectRatio: 13 / 16,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(profilePhoto),
                    ),
                    const SizedBox(
                      height: 7.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 7.0,
                        ),
                        Text(
                          description,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 7.0,
                        ),
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
                                  color: Color.fromARGB(255, 44, 184, 240)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              )),
    );
  }
}
