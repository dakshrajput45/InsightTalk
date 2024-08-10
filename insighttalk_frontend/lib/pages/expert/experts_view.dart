import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/apis/userApis/user_details_api.dart';
import 'package:insighttalk_backend/modal/modal_category.dart';
import 'package:insighttalk_backend/modal/modal_expert.dart';
import 'package:insighttalk_frontend/pages/expert/expert_card.dart';
import 'package:insighttalk_frontend/pages/expert/expert_controller.dart';
import 'package:insighttalk_frontend/pages/userProfile/editprofile_controller.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExpertsView extends StatefulWidget {
  const ExpertsView({super.key});

  @override
  State<ExpertsView> createState() => _ExpertsViewState();
}

class _ExpertsViewState extends State<ExpertsView> {
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
  final DsdExpertController _dsdExpertController = DsdExpertController();
  final DsdUserDetailsApis _dsdUserApis = DsdUserDetailsApis();
  List<DsdCategory>? popularCategory = [];
  List<DsdCategory>? _userCategory = [];

  final List<Map<String, dynamic>> imageList = [
    {"image_path": "assets/ads/ad_image1.jpg"},
    {"image_path": "assets/ads/ad_image2.jpg"},
    {"image_path": "assets/ads/ad_image3.jpg"},
  ];

  Future<void> fetchTopCategory() async {
    try {
      List<DsdCategory>? result =
          await _dsdExpertController.fetchPopularCategories();
      setState(() {
        popularCategory = result;
      });
    } catch (e) {
      rethrow;
    }
  }

  List<DsdCategory>? categories = [];

  Future<void> getCategory() async {
    try {
      String userId = _itUserAuthSDK.getUser()!.uid;
      List<DsdCategory>? fetchedCategories =
          await _dsdUserApis.fetchUserCategories(userId: userId);

      setState(() {
        _userCategory = fetchedCategories;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTopCategory();
    getCategory();
  }

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
            height: 20,
          ),
          SizedBox(
            height: 17.sw,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  popularCategory!.length > 5 ? 5 : popularCategory?.length,
              itemBuilder: (context, index) {
                final category = popularCategory?[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.network(
                            category!.categoryImage!,
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
                  // Event Handler for Carousel when tapped
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
          // // Expert Card Section
          // const CategoryCardSection(category: "Top Experts"),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _userCategory!
                .where((category) => category.experts!.isNotEmpty)
                .map((category) {
              return CategoryCardSection(category: category.categoryTitle!);
            }).toList(),
          )
        ]),
      ),
    );
  }
}

class CategoryCardSection extends StatefulWidget {
  final String category;
  const CategoryCardSection({required this.category, super.key});

  @override
  _CategoryCardSectionState createState() => _CategoryCardSectionState();
}

class _CategoryCardSectionState extends State<CategoryCardSection> {
  final DsdProfileController _dsdProfileController = DsdProfileController();
  List<DsdExpert> expertData = [];

  @override
  void initState() {
    super.initState();
    getExperts(categoryTitle: widget.category);
  }

  Future<void> getExperts({required String categoryTitle}) async {
    try {
      List<DsdExpert>? data = await _dsdProfileController.fetchExpertData(
          categoryId: categoryTitle);
      setState(() {
        expertData = data!;
      });
    } catch (e) {
      rethrow;
    }
  }

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
              Text(
                widget.category,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              itemCount: expertData.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final expert = expertData[index];
                return ExpertCard(
                  profilePhoto: expert.profileImage!,
                  name: expert.expertName!,
                  description: expert.expertise!,
                  rating: expert.averageRating,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
