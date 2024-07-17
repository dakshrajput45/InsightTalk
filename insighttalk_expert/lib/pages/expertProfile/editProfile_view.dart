import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:insighttalk_expert/router.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _categories = [];
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final FocusNode _categoryFocusNode = FocusNode();
  final List<String> _availableCategories = [
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

  final Map<String, bool> days = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  final Map<String, List<Map<String, DateTime>>> selectedTimes = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now();

  bool validateTimes(DateTime startTime, DateTime endTime) {
    return endTime.isAfter(startTime.add(const Duration(minutes: 30)));
  }

  Future<void> _showTimePickerSpinner(
      BuildContext context, bool isStartTime) async {
    DateTime tempTime = DateTime.now();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isStartTime ? 'Select Start Time' : 'Select End Time'),
          content: TimePickerSpinner(
            is24HourMode: false,
            normalTextStyle:
                const TextStyle(fontSize: 22, color: Colors.black54),
            highlightedTextStyle:
                const TextStyle(fontSize: 22, color: Colors.black),
            spacing: 50,
            itemHeight: 60,
            isForce2Digits: true,
            onTimeChange: (time) {
              setState(() {
                tempTime = time;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (isStartTime) {
                    _startTime = tempTime;
                  } else {
                    _endTime = tempTime;
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool _isHidden = true;
  void _showpassword() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Profile",
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
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/search.png'),
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
                    controller: _emailAddressController,
                    decoration: const InputDecoration(
                      hintText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    obscureText: _isHidden,
                    controller: _passwordController,
                    decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_isHidden
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: _showpassword,
                        )),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Handle change password action
                      },
                      child: const Text('Change Password'),
                    ),
                  ),
                  const SizedBox(height: 10),

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
                    height: 20,
                  ),
                  const Text(
                    'Add Availability',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: days.keys.map((String day) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            title: Text(day),
                            value: days[day],
                            onChanged: (bool? value) async {
                              _startTime = DateTime.now();
                              _endTime = DateTime.now();
                              await _showTimePickerSpinner(context, true);
                              await _showTimePickerSpinner(context, false);

                              if (validateTimes(_startTime, _endTime)) {
                                setState(() {
                                  days[day] = value!;
                                  selectedTimes[day]!.add({
                                    'start': _startTime,
                                    'end': _endTime,
                                  });
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'End time should be at least 30 minutes after start time.'),
                                  ),
                                );
                              }
                            },
                          ),
                          if (days[day]!)
                            Column(
                              children: [
                                ...selectedTimes[day]!.map((timeSlot) {
                                  return ListTile(
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              await _showTimePickerSpinner(
                                                  context, true);
                                              setState(() {
                                                timeSlot['start'] = _startTime;
                                              });
                                            },
                                            child: InputDecorator(
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 0,
                                                        horizontal: 10.0),
                                                labelText: 'From',
                                                border: OutlineInputBorder(),
                                              ),
                                              child: Text(
                                                '${timeSlot['start']?.hour}:${timeSlot['start']?.minute.toString().padLeft(2, '0')}',
                                                style: const TextStyle(
                                                    height: 0.7),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              await _showTimePickerSpinner(
                                                  context, false);
                                              setState(() {
                                                timeSlot['end'] = _endTime;
                                              });
                                            },
                                            child: InputDecorator(
                                              decoration: const InputDecoration(
                                                labelText: 'To',
                                                border: OutlineInputBorder(),
                                              ),
                                              child: Text(
                                                '${timeSlot['end']?.hour}:${timeSlot['end']?.minute.toString().padLeft(2, '0')}',
                                                style: const TextStyle(
                                                    height: 0.7),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            setState(() {
                                              selectedTimes[day]!
                                                  .remove(timeSlot);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                Center(
                                  child: SizedBox(
                                    height: 50,
                                    width: 200,
                                    child: TextButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () async {
                                        _startTime = DateTime.now();
                                        _endTime = DateTime.now();
                                        await _showTimePickerSpinner(
                                            context, true);
                                        await _showTimePickerSpinner(
                                            context, false);

                                        if (validateTimes(
                                            _startTime, _endTime)) {
                                          setState(() {
                                            selectedTimes[day]!.add({
                                              'start': _startTime,
                                              'end': _endTime,
                                            });
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'End time should be at least 30 minutes after start time.'),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Center(
                                        child: Row(children: [
                                          Icon(Icons.add),
                                          Text('Add Time Slot')
                                        ]),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
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
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Handle save action
                          context.goNamed(routeNames.appointment);
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
