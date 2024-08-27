import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insighttalk_backend/apis/expert/expert_apis.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/modal/modal_category.dart';
import 'package:insighttalk_backend/modal/modal_expert.dart';
import 'package:insighttalk_expert/router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExpertProfileView extends StatefulWidget {
  const ExpertProfileView({super.key});

  @override
  State<ExpertProfileView> createState() => _ExpertProfileViewState();
}

class _ExpertProfileViewState extends State<ExpertProfileView> {
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
  final DsdExpertApis _dsdExpertApis = DsdExpertApis();
  List<DsdCategory>? categories = [];
  DsdExpert? expertData;
  bool _loading = true;

  List<String> reviews = [
    "Great session, learned a lot from the expert. Highly recommend!",
    "The expert was very knowledgeable and helpful. Will book again.",
    "Amazing insights and practical advice. Truly appreciated the session.",
    "Very patient and explained everything in detail. Excellent experience.",
    "The session exceeded my expectations. Will definitely return for more advice.",
  ];

  Future<void> getCategory() async {
    try {
      String expertId = _itUserAuthSDK.getUser()!.uid;
      List<DsdCategory>? fetchedCategories =
          await _dsdExpertApis.fetchExpertCategories(expertId: expertId);

      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getExpertData() async {
    try {
      String expertId = _itUserAuthSDK.getUser()!.uid;
      DsdExpert? fetchedExpertData =
          await _dsdExpertApis.fetchExpertById(expertId: expertId);

      setState(() {
        expertData = fetchedExpertData;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await getCategory();
    await getExpertData();
    setState(() {
      _loading = false;
    });
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
            padding: EdgeInsets.all(3.sw),
            child: CustomPaint(
              painter: PolkaDotPainter(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  margin: const EdgeInsets.only(
                                      top: 10, left: 16, bottom: 10),
                                  decoration: BoxDecoration(
                                    shape:
                                        BoxShape.circle, // Set shape to circle
                                    color: Colors.grey.shade200,
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: CachedNetworkImage(
                                    imageUrl: expertData?.profileImage ??
                                        defaultImage,
                                    placeholder: (context, url) => const Center(
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 4.sh),
                                  child: PopupMenuButton<String>(
                                    onSelected: (String value) {
                                      // Handle menu item selection
                                      switch (value) {
                                        case 'Edit Profile':
                                          context
                                              .goNamed(routeNames.editprofile);
                                          break;
                                        case 'Settings':
                                          // Navigate to settings page
                                          break;
                                        case 'Logout':
                                          // Perform logout
                                          _itUserAuthSDK.signOut();
                                          context.goNamed(routeNames.login);
                                          break;
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return {
                                        'Edit Profile',
                                        'Settings',
                                        'Logout'
                                      }.map((String choice) {
                                        return PopupMenuItem<String>(
                                          value: choice,
                                          child: Text(
                                            choice,
                                            style: TextStyle(
                                              fontSize: 1.9.sh,
                                            ),
                                          ),
                                        );
                                      }).toList();
                                    },
                                    icon: Icon(
                                      Icons.more_vert,
                                      size: 3.sh,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "${expertData?.expertName}".toUpperCase(),
                            style: TextStyle(
                                fontSize: 2.8.sh,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "(" "${expertData?.expertise}" ")",
                            style: TextStyle(
                                fontSize: 2.3.sh,
                                fontWeight: FontWeight.w500,
                                color:
                                    const Color.fromARGB(255, 255, 255, 255)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                          horizontal: 1.5.sw, vertical: 1.sw),
                      padding: EdgeInsets.all(3.sw),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.0, color: Colors.grey),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "About",
                            style: TextStyle(
                                fontSize: 3.sh, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 2.sh),
                          Text(
                            "${expertData?.about}",
                            style: TextStyle(
                              fontSize: 2.sh,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Categories",
                            style: TextStyle(
                                fontSize: 2.3.sh, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (categories != null && categories!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Number of columns
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                          ),
                          itemCount: categories!.length,
                          itemBuilder: (context, index) {
                            final category = categories![index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
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
                                        fontSize: 1.9.sh,
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
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Reviews",
                        style: TextStyle(
                            fontSize: 2.3.sh, fontWeight: FontWeight.w500),
                      ),
                    ),
                    ...List.generate(reviews.length, (index) {
                      final review = reviews[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                review,
                                style: TextStyle(fontSize: 2.sh),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ]),
            ),
          );
  }
}

class PolkaDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade400
      ..style = PaintingStyle.fill;

    double y = -56.sh;
    double x = size.width / 2;
    canvas.drawCircle(Offset(x, y), 82.sh, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
