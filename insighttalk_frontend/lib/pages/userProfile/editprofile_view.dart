import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:insighttalk_backend/apis/category/category_apis.dart';
import 'package:insighttalk_backend/modal/category.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/modal/modal_user.dart';
import 'package:insighttalk_frontend/pages/userProfile/editprofile_controller.dart';
import 'package:insighttalk_frontend/router.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:insighttalk_backend/helper/toast.dart';
import 'package:insighttalk_backend/helper/Dsd_dob_validator.dart';
import 'package:insighttalk_backend/apis/userApis/user_details_api.dart';

final DsdProfileController _dsdProfileController = DsdProfileController();

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _categories = [];
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _categoryFocusNode = FocusNode();
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
  final DsdUserDetailsApis _dsdUserApis = DsdUserDetailsApis();
  final DsdDobValidator _dsdDobValidator = DsdDobValidator();
  DateTime? dateOfBirth;
  File? _imageFile;
  String? _imageUrl;
  bool? firstTime = false;

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () async {
                  File? Img = await _pickImage(ImageSource.gallery);
                  if (Img != null) {
                    await _uploadImageToFirebase(Img);
                  }
                  Navigator.pop(context);
                  print("pick to ho gya");
                },
              ),
              ListTile(
                leading: Icon(Icons.link),
                title: Text('Upload from link'),
                onTap: () async {
                  Navigator.pop(context);
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Upload from link',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: _urlController,
                                decoration: InputDecoration(
                                    hintText: 'Enter image URL'),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Upload'),
                                    onPressed: () {
                                      setState(() {
                                        _imageUrl = _urlController.text;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File?> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: source);
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);
        return _imageFile;
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _uploadImageToFirebase(Img) async {
    if (Img == null) {
      print('No image selected.');
      return;
    }
    try {
      if (!await Img!.exists()) {
        print('Image file does not exist at path: ${_imageFile!.path}');
        return;
      }

      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images')
          .child('${Path.basename(_imageFile!.path)}');

      // Upload the file to Firebase Storage
      final uploadTask = ref.putFile(Img!);
      await uploadTask;
      final downloadURL = await ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadURL;
      });
      print('File uploaded successfully. Download URL: $_imageUrl');
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  Future<void> selectedDOB() async {
    var dob = await _dsdDobValidator.selectDOB(
        context, dateOfBirth ?? DateTime.now());
    if (dob != null && dob != DateTime.now()) {
      setState(() {
        dateOfBirth = dob;
        _dobController.text = DateFormat("MM/dd/yyy").format(dateOfBirth!);
      });
    }
  }

  List<String> _availableCategories = [];
  @override
  void initState() {
    super.initState();
    _fetchCategories();
    getUserData();
  }

  Future<void> _fetchCategories() async {
    try {
      List<DsdCategory> categories =
          await _dsdProfileController.fetchAllCategories();
      setState(() {
        _availableCategories = categories
            .map((category) => category.categoryTitle!)
            .whereType<String>()
            .toList();
      });
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<void> getUserData() async {
    try {
      String userId = _itUserAuthSDK.getUser()!.uid;
      DsdUser? fetchedUserData =
          await _dsdUserApis.fetchUserById(userId: userId);
      setState(() {
        _userNameController.text = fetchedUserData?.userName ?? '';
        _dobController.text = fetchedUserData?.dateOfBirth != null
            ? DateFormat("MM/dd/yyyy").format(fetchedUserData!.dateOfBirth!)
            : '';
        _cityController.text = fetchedUserData?.address?.city ?? '';
        _stateController.text = fetchedUserData?.address?.state ?? '';
        _countryController.text = fetchedUserData?.address?.country ?? '';

        // Populate categories
        _categories.addAll(fetchedUserData?.category ?? []);
        firstTime = true;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Edit Profile",
            textAlign: TextAlign.center,
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: _imageUrl != null
                                  ? NetworkImage(_imageUrl!)
                                  : const NetworkImage(
                                          'https://imgv3.fotor.com/images/blog-cover-image/10-profile-picture-ideas-to-make-you-stand-out.jpg')
                                      as ImageProvider,
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
                            decoration: const BoxDecoration(
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
                                _openImagePicker(context);
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
                    controller: _userNameController,
                    decoration: const InputDecoration(
                      hintText: 'User Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                        hintText: 'MM/DD/YY',
                        labelText: 'Date of Birth',
                        prefixIcon: const Icon(Icons.calendar_month_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        )),
                    onTap: () async {
                      if (_itUserAuthSDK.getUser() != null) {
                        await selectedDOB();
                      }
                    },
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
                    controller: _cityController,
                    decoration: const InputDecoration(
                      hintText: 'City',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      hintText: 'State',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      hintText: 'Country',
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Add Category Section
                  const Text(
                    'Add Category',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TypeAheadField<String>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _categoryController,
                      focusNode: _categoryFocusNode,
                      decoration: const InputDecoration(
                        hintText: 'Search Category',
                      ),
                    ),
                    suggestionsCallback: (pattern) {
                      return _availableCategories.where((item) =>
                          item.toLowerCase().startsWith(pattern.toLowerCase()));
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      if (!_categories.contains(suggestion)) {
                        setState(() {
                          _categories.add(suggestion);
                          _availableCategories.remove(suggestion);
                        });
                      }
                      _categoryController.clear();
                      _categoryFocusNode.unfocus();
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
                            _availableCategories.add(category);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Handle save action
                          await _dsdProfileController
                              .updateUser(
                            user: DsdUser(
                              userName: _userNameController.value.text.trim(),
                              email: _itUserAuthSDK.getUser()!.email,
                              dateOfBirth: dateOfBirth,
                              address: DsdUserAddress(
                                country: _countryController.value.text.trim(),
                                state: _stateController.value.text.trim(),
                                city: _cityController.value.text.trim(),
                              ),
                              category: _categories,
                              profileImage: _imageUrl != null
                                  ? _imageUrl
                                  : "https://imgv3.fotor.com/images/blog-cover-image/10-profile-picture-ideas-to-make-you-stand-out.jpg",
                            ),
                            userId: _itUserAuthSDK.getUser()!.uid,
                          )
                              .then((value) {
                            DsdToastMessages.success(context,
                                text: "Profile updated successfully!");
                          });
                          await updateCategories(
                              _categories, _itUserAuthSDK.getUser()!.uid);
                          if (firstTime == true) {
                            Navigator.pop(context);
                          } else {
                            context.goNamed(routeNames.experts);
                          }
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
      ),
    );
  }
}

Future<void> updateCategories(
    List<String> categoryTitles, String userId) async {
  try {
    await Future.forEach(categoryTitles, (categoryTitle) async {
      print(categoryTitle);
      await _dsdProfileController.updateUserIdInCategory(
        categoryTitle: categoryTitle,
        userId: userId,
      );
    });
    print('All categories updated successfully.');
  } catch (e) {
    print('Error updating categories: $e');
    // Handle error as needed
  }
}
