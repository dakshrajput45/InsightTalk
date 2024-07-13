import 'package:flutter/material.dart';

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
      child: AspectRatio(
          aspectRatio: 14 / 16,
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
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 7.0,
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
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
