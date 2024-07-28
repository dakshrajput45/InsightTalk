import 'package:flutter/material.dart';
import 'package:insighttalk_backend/modal/modal_expert.dart';
import 'package:insighttalk_frontend/pages/expert/expert_card.dart';
import 'package:insighttalk_frontend/pages/userProfile/editprofile_controller.dart';

class CategoryExperts extends StatefulWidget {
  final String categoryTitle;

  const CategoryExperts({super.key, required this.categoryTitle});

  @override
  State<CategoryExperts> createState() => _CategoryExpertsState();
}

class _CategoryExpertsState extends State<CategoryExperts> {
  final DsdProfileController _dsdProfileController = DsdProfileController();
  List<DsdExpert> expertData = [];

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
  void initState() {
    super.initState();
    getExperts(categoryTitle: widget.categoryTitle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Experts"),
      ),
      body: GridView.builder(
        padding:
            const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 50),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 20,
        ),
        itemCount: expertData.length,
        itemBuilder: (BuildContext context, int index) {
          DsdExpert expert = expertData[index];
          return ExpertCard(
            profilePhoto: expert.profileImage!,
            name: expert.expertName!,
            description: expert.expertise!,
            rating: expert.averageRating,
          );
        },
      ),
    );
  }
}
