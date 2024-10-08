import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:insighttalk_backend/apis/expert/expert_apis.dart';
import 'package:insighttalk_backend/helper/toast.dart';
import 'package:insighttalk_backend/modal/modal_category.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/modal/modal_expert.dart';
import 'package:insighttalk_expert/pages/expertProfile/edit_expert_profile_controller.dart';
import 'package:insighttalk_expert/router.dart';
import 'package:insighttalk_backend/helper/Dsd_dob_validator.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

final DsdExpertProfileController _dsdProfileController =
    DsdExpertProfileController();

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _categories = [];
  final TextEditingController _expertNameController = TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _categoryFocusNode = FocusNode();
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
  final DsdExpertApis _dsdExpertApis = DsdExpertApis();
  final TextEditingController _dobController = TextEditingController();
  final DsdDobValidator _dsdDobValidator = DsdDobValidator();
  final int _maxCharacters = 2000;
  DateTime? dateOfBirth;
  File? _imageFile;
  String? _imageUrl;
  bool? firstTime = false;
  bool _isLoading = false;

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

  List<String> _availableCategories = [];

  bool validateTimes(DateTime startTime, DateTime endTime) {
    return endTime.isAfter(startTime.add(const Duration(minutes: 30)));
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

  Future<void> getExpertData() async {
    try {
      String expertId = _itUserAuthSDK.getUser()!.uid;
      DsdExpert? fetchedExpertData =
          await _dsdExpertApis.fetchExpertById(expertId: expertId);
      setState(() {
        _imageUrl = fetchedExpertData?.profileImage ?? '';
        _expertNameController.text = fetchedExpertData?.expertName ?? '';
        _expertiseController.text = fetchedExpertData?.expertise ?? '';
        _aboutController.text = fetchedExpertData?.about ?? '';
        _dobController.text = fetchedExpertData?.dateOfBirth != null
            ? DateFormat("MM/dd/yyyy").format(fetchedExpertData!.dateOfBirth!)
            : '';
        _cityController.text = fetchedExpertData?.address?.city ?? '';
        _stateController.text = fetchedExpertData?.address?.state ?? '';
        _countryController.text = fetchedExpertData?.address?.country ?? '';

        // Populate categories
        _categories.addAll(fetchedExpertData?.category ?? []);
        firstTime = true;
      });
    } catch (e) {
      rethrow;
    }
  }

  bool _sendData = false;
  @override
  void initState() {
    super.initState();
    _fetchCategories();
    getExpertData();
  }

  var defaultImage =
      "https://imgv3.fotor.com/images/blog-cover-image/10-profile-picture-ideas-to-make-you-stand-out.jpg";

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
                    controller: _expertNameController,
                    decoration: const InputDecoration(
                      hintText: 'Expert Name',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _expertiseController,
                    decoration: const InputDecoration(
                      hintText: 'Expertise',
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
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _aboutController,
                    maxLines: 5,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(2000),
                    ],
                    decoration: InputDecoration(
                      labelText: 'About You',
                      hintText: 'Write about yourself here',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 10.0),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon: Builder(
                        builder: (BuildContext context) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(top: 110.0, right: 10.0),
                            child: Text(
                              '${_aboutController.text.length}/$_maxCharacters',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Update the state to refresh suffixIcon
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
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
                          await _dsdProfileController.deleteExperIdCategory(
                              categoryTitle: category,
                              expertId: _itUserAuthSDK.getUser()!.uid);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(
                    height: 20,
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
                          var token =
                              await FirebaseMessaging.instance.getToken();
                          // Handle save action
                          await _dsdProfileController
                              .updateExpert(
                            expert: DsdExpert(
                                id: _itUserAuthSDK.getUser()!.uid,
                                expertName:
                                    _expertNameController.value.text.trim(),
                                email: _itUserAuthSDK.getUser()!.email,
                                expertise:
                                    _expertiseController.value.text.trim(),
                                dateOfBirth: dateOfBirth,
                                about: _aboutController.value.text,
                                address: DsdExpertAddress(
                                  country: _countryController.value.text.trim(),
                                  state: _stateController.value.text.trim(),
                                  city: _cityController.value.text.trim(),
                                ),
                                category: _categories,
                                profileImage: _imageUrl ??
                                    "https://imgv3.fotor.com/images/blog-cover-image/10-profile-picture-ideas-to-make-you-stand-out.jpg",
                                fcmToken: token),
                            expertId: _itUserAuthSDK.getUser()!.uid,
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
                            // ignore: use_build_context_synchronously
                            context.goNamed(routeNames.expertprofile);
                          } else {
                            // ignore: use_build_context_synchronously
                            context.goNamed(routeNames.appointment);
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
    List<String> categoryTitles, String expertId) async {
  try {
    await Future.forEach(categoryTitles, (categoryTitle) async {
      await _dsdProfileController.updateExpertIdInCategory(
        categoryTitle: categoryTitle,
        expertId: expertId,
      );
    });
  } catch (e) {
    rethrow;
    // Handle error as needed
  }
}
