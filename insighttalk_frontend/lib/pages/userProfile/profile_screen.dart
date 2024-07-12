import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insighttalk_frontend/router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _categories = [];
  final TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          // leading: IconButton(
          //     onPressed: () {},
          //     icon: const Icon(Icons.arrow_back_ios_new_rounded)),
          title: const Text(
            "Profile",
            textAlign: TextAlign.center,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Photo Section
                Center(
                  child: Stack(
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/blank_profile_pic.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // Handle profile photo edit action
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Personal Details Section
                const Text(
                  'Personal Details',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'User Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Handle forgot password action
                  },
                  child: const Text('Forgot Password?'),
                ),
                const SizedBox(height: 20),

                // Address Details Section
                const Text(
                  'Address Details',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'City',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'State',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Country',
                  ),
                ),
                const SizedBox(height: 20),

                // Add Category Section
                const Text(
                  'Add Category',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    hintText: 'Add Category',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        final category = _categoryController.text;
                        if (category.isNotEmpty &&
                            !_categories.contains(category)) {
                          setState(() {
                            _categories.add(category);
                            _categoryController.clear();
                          });
                        }
                      },
                    ),
                  ),
                  onFieldSubmitted: (value) {
                    if (value.isNotEmpty && !_categories.contains(value)) {
                      setState(() {
                        _categories.add(value);
                        _categoryController.clear();
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  children: _categories.map((category) {
                    return Chip(
                      label: Text(category),
                      onDeleted: () {
                        setState(() {
                          _categories.remove(category);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Handle save action
                        context.goNamed(routeNames.experts);
                      }
                    },
                    child: const Text('Save'),
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
