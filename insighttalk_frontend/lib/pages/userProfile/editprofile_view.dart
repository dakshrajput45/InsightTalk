import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:insighttalk_backend/modal/modal_category.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
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
import 'package:path_provider/path_provider.dart';

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
  bool _isLoading = true;
  bool _sendData = false;

  Future<void> _openImagePicker(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });

      File? img;
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from gallery'),
                  onTap: () async {
                    img = await _pickImage(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Upload from link'),
                  onTap: () async {
                    Navigator.pop(context);
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Container(
                            padding: const EdgeInsets.all(16),
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
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _urlController,
                                  decoration: const InputDecoration(
                                      hintText: 'Enter image URL'),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Upload'),
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

      // Check if an image was picked and upload it to Firebase
      if (img != null) {
        await _uploadImageToFirebase(img!);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      // Reset isLoading to false once the process is complete
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<File?> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: source);
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);
        // Compress the image before uploading
        _imageFile = await _compressImage(File(pickedImage.path));
        return _imageFile;
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<File> _compressImage(File imageFile) async {
    try {
      // Read the image from the file
      final img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

      if (image == null) {
        throw Exception("Failed to decode the image.");
      }

      // Resize and compress the image to reduce its size (optional)
      final img.Image resizedImage = img.copyResize(
        image,
        width: 600, // Resize to a width of 600px, adjust as needed
      );

      // Compress the image (quality between 0 to 100)
      final List<int> compressedImageBytes = img.encodeJpg(resizedImage,
          quality: 80); // Adjust the quality as needed

      // Save the compressed image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final compressedImageFile =
          File('${tempDir.path}/compressed_${path.basename(imageFile.path)}');
      await compressedImageFile.writeAsBytes(compressedImageBytes);

      return compressedImageFile;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _uploadImageToFirebase(File img) async {
    try {
      if (!await img.exists()) {
        return;
      }

      // Upload the file to Firebase Storage
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images')
          .child(path.basename(img.path));

      final uploadTask = ref.putFile(img);
      await uploadTask;
      final downloadURL = await ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadURL;
      });
    } catch (e) {
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
    _loadData();
  }

  Future<void> _loadData() async {
    _fetchCategories();
    getUserData();
    setState(() {
      _isLoading = false;
    });
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
      rethrow;
    }
  }

  Future<void> getUserData() async {
    try {
      String userId = _itUserAuthSDK.getUser()!.uid;
      DsdUser? fetchedUserData =
          await _dsdUserApis.fetchUserById(userId: userId);
      setState(() {
        _imageUrl = fetchedUserData?.profileImage ?? '';
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
      rethrow;
    }
  }

  var defaultImage =
      "https://imgv3.fotor.com/images/blog-cover-image/10-profile-picture-ideas-to-make-you-stand-out.jpg";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: firstTime!
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.goNamed(routeNames.userprofile);
                  },
                )
              : null,
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
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Photo Section
                  Center(
                    child: Stack(
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: _imageUrl ?? defaultImage,
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
                            width: 120,
                            height: 120,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () async {
                              await _openImagePicker(context);
                            },
                            child: CircleAvatar(
                              key: ValueKey(_isLoading),
                              backgroundColor: Colors.blue,
                              child: _isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
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
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                        hintText: 'MM/DD/YY',
                        labelText: 'Date of Birth',
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
                        onDeleted: () async {
                          setState(() {
                            _categories.remove(category);
                            _availableCategories.add(category);
                          });
                          await _dsdProfileController.deleteUserIdInCategory(
                              categoryTitle: category,
                              userId: _itUserAuthSDK.getUser()!.uid);
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
                        setState(() {
                          _sendData = true;
                        });
                        if (_formKey.currentState?.validate() ?? false) {
                          //get fcm token
                          var token =
                              await FirebaseMessaging.instance.getToken();
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
                                profileImage: _imageUrl ??
                                    "https://imgv3.fotor.com/images/blog-cover-image/10-profile-picture-ideas-to-make-you-stand-out.jpg",
                                fcmToken: token),
                            userId: _itUserAuthSDK.getUser()!.uid,
                          )
                              .then((value) {
                            setState(() {
                              _sendData = false;
                            });
                            DsdToastMessages.success(context,
                                text: "Profile updated successfully!");
                          });
                          await updateCategories(
                              _categories, _itUserAuthSDK.getUser()!.uid);
                          if (firstTime == true) {
                            context.goNamed(routeNames.userprofile);
                          } else {
                            context.goNamed(routeNames.experts);
                          }
                        }
                      },
                      child: _sendData
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save'),
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
      await _dsdProfileController.updateUserIdInCategory(
        categoryTitle: categoryTitle,
        userId: userId,
      );
    });
  } catch (e) {
    rethrow;
    // Handle error as needed
  }
}
