import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:insighttalk_frontend/pages/expert/expert_card.dart';

class ExpertsView extends StatefulWidget {
  const ExpertsView({super.key});

  @override
  State<ExpertsView> createState() => _ExpertsViewState();
}

class _ExpertsViewState extends State<ExpertsView> {
  final List<String> _popularCategory = [
    'DSA',
    'Flutter',
    'Politics',
    'React',
    'Cricket',
    'DSA2',
    'Flutter2',
    'Politics2',
    'React2',
    'Cricket2',
  ];
  final List<String> _userCategory = [
    'DSA',
    'Flutter',
    'Politics',
    'React',
  ];
  final List<Map<String, dynamic>> imageList = [
    {"image_path": "assets/ads/ad_image1.jpg"},
    {"image_path": "assets/ads/ad_image2.jpg"},
    {"image_path": "assets/ads/ad_image3.jpg"},
  ];

  final CarouselController _carouselController = CarouselController();

  int _currentCarouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Popular Categories
          const Text(
            'Popular Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  _popularCategory.length > 5 ? 5 : _popularCategory.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  margin: const EdgeInsets.all(3),
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    child: Text(_popularCategory[index],
                        style: const TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // AdCarousel Section

          Stack(
            children: [
              InkWell(
                onTap: () {
                  //Event Handler for Carousel when tapped
                },
                child: CarouselSlider(
                  items: imageList
                      .map((item) => AspectRatio(
                            aspectRatio: 16 / 9,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                item['image_path'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ))
                      .toList(),
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    scrollPhysics: const BouncingScrollPhysics(),
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    viewportFraction: 1,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentCarouselIndex = index;
                      });
                    },
                  ),
                ),
              ),
              Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imageList.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () =>
                            _carouselController.animateToPage(entry.key),
                        child: Container(
                          width: _currentCarouselIndex == entry.key ? 17 : 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 3.0),
                          decoration: BoxDecoration(
                            color: _currentCarouselIndex == entry.key
                                ? Colors.blue
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }).toList(),
                  ))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          // Expert Card Section
        ]),
      ),
    );
  }
}

class CategoryCardSection extends StatelessWidget {
  const CategoryCardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.275,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Top Experts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "See all",
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
          const SizedBox(height: 5.0),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return const ExpertCard(
                  profilePhoto: "assets/images/blank_profile_pic.jpg",
                  name: "Deepanshu Sharma",
                  description: "Software Developer",
                  rating: 5.0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
