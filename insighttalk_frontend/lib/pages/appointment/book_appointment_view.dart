import 'dart:ffi';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';

import 'package:insighttalk_backend/apis/expert/expert_apis.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/modal/modal_expert.dart';
import 'package:insighttalk_frontend/pages/appointment/appointment_controller.dart';
import 'package:insighttalk_frontend/router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class BookAppointmentView extends StatefulWidget {
  final DsdExpert expertData;
  const BookAppointmentView({required this.expertData, super.key});

  @override
  State<BookAppointmentView> createState() => _BookAppointmentViewState();
}

class _BookAppointmentViewState extends State<BookAppointmentView> {
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
  String selectedCategory = '';
  int selectedDuration = 0;
  double price = 0.00;
  Timestamp? appointmentTime;
  final int _maxCharacters = 500;

  final DsdAppointmentController _dsdAppointmentController =
      DsdAppointmentController();
  List<DateTime> availableDates = [
    DateTime(2024, 8, 18),
    DateTime(2024, 8, 22),
    DateTime(2024, 8, 24),
    DateTime(2024, 8, 25),
    DateTime(2024, 9, 1),
  ];
  TextEditingController _reasonController = TextEditingController();
  List<DateTime> availableTimeSlots = [];
  // Future<void> getExpertData() async {
  //   try {
  //     DsdExpert? fetchedExpertData =
  //         await _dsdExpertApis.fetchExpertById(expertId: widget.expertId);

  //     setState(() {
  //       expertData = fetchedExpertData;

  //       print(expertData!.category![1]);
  //     });
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // _loadData();
  }

  // Future<void> _loadData() async {
  //   await getExpertData();

  //   if (mounted) {
  //     setState(() {
  //       _loading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointment',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.0)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: CachedNetworkImage(
                      imageUrl: widget.expertData.profileImage!,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.cover,
                      width: 140,
                      height: 140,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.expertData.expertName ?? 'Unknown Expert',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        widget.expertData.expertise ?? 'Unknown',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Color.fromARGB(255, 44, 184, 240),
                            size: 20.0,
                          ),
                          SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            '0.0',
                            style: TextStyle(
                              color: Color.fromARGB(255, 44, 184, 240),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("Select Category",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(
              height: 10,
            ),
            CategorySelector(
              categories: widget.expertData.category!,
              onCategorySelected: (category) {
                setState(() {
                  selectedCategory = category; // Update selected category
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("Select Duration",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(
              height: 10,
            ),
            DurationSelector(
              durations: const [20, 40, 60],
              onDurationSelected: (selectedDuration) {
                setState(() {
                  selectedDuration = selectedDuration;
                  (selectedDuration != 0)
                      ? price = (selectedDuration * 5) - 40.00
                      : price = 0.00;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),

            const Text("Select Date and Time",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(
              height: 10,
            ),
            DateTimeSelector(
              availability: widget.expertData.availability,
              onAppointmentSelected: (Timestamp appointmentTimestamp) {
                appointmentTime = appointmentTimestamp;
              },
            ),

            const SizedBox(
              height: 20,
            ),
            const Text("Specify Reason",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              maxLines: 2,
              inputFormatters: [
                LengthLimitingTextInputFormatter(500),
              ],
              controller: _reasonController,
              decoration: InputDecoration(
                icon: const Icon(Icons.note_alt_outlined),
                suffixIcon: Builder(
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 45.0, right: 10.0),
                      child: Text(
                        '${_reasonController.text.length}/$_maxCharacters',
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
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 4.0,
        elevation: 10.0,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey),
                  ),
                  Text("₹ $price", style: const TextStyle(fontSize: 20)),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  String userId = _itUserAuthSDK.getUser()!.uid;
                  await _dsdAppointmentController.createAppointment(
                      userId,
                      widget.expertData.id!,
                      Timestamp.now(),
                      _reasonController.text,
                      [selectedCategory],
                      60,
                      "20 min");
                  _showBookingConfirmationDialog();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 10.0),
                  textStyle: const TextStyle(fontSize: 22),
                ),
                child: const Text("Booking"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissal by clicking outside the dialog
      builder: (BuildContext context) {
        // Delay to automatically dismiss the dialog and navigate to the new page
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop(); // Dismiss the dialog
          // Navigate to the new page after the dialog is dismissed
          context.goNamed(routeNames.experts);
        });

        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie animation
              Lottie.asset(
                'assets/lottie/booking_success.json', // Path to your Lottie animation file
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 20),
              // Confirmation message
              const Text(
                'Appointment Booked',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategorySelector extends StatefulWidget {
  final List<String> categories;
  final ValueChanged<String>
      onCategorySelected; // Callback for category selection

  const CategorySelector({
    super.key,
    required this.categories,
    required this.onCategorySelected, // Accept the callback in the constructor
  });

  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  int selectedIndex = -1;
  String selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: List.generate(
          widget.categories.length,
          (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (selectedIndex == index) {
                    selectedIndex = -1;
                    selectedCategory = '';
                  } else {
                    selectedIndex = index;
                    selectedCategory = widget.categories[index];
                  }
                  widget.onCategorySelected(
                      selectedCategory); // Notify parent of selection
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? const Color.fromRGBO(
                          173,
                          239,
                          255,
                          1,
                        )
                      : Colors.white,
                  border: selectedIndex == index
                      ? Border.all(
                          color: Colors.blue,
                          width: 2.0,
                        )
                      : Border.all(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.categories[index],
                  style: selectedIndex == index
                      ? const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        )
                      : const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ), // Text color
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DurationSelector extends StatefulWidget {
  final List<int> durations;
  final ValueChanged<int> onDurationSelected; // Callback for duration selection

  const DurationSelector({
    super.key,
    required this.durations,
    required this.onDurationSelected, // Accept the callback in the constructor
  });

  @override
  _DurationSelectorState createState() => _DurationSelectorState();
}

class _DurationSelectorState extends State<DurationSelector> {
  int selectedIndex = -1;
  int selectedDuration = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: List.generate(
          widget.durations.length,
          (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (selectedIndex == index) {
                    selectedIndex = -1;
                    selectedDuration = 0;
                  } else {
                    selectedIndex = index;
                    selectedDuration = widget.durations[index];
                  }
                  widget.onDurationSelected(
                      selectedDuration); // Notify parent of selection
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? const Color.fromRGBO(
                          173,
                          239,
                          255,
                          1,
                        )
                      : Colors.white,
                  border: selectedIndex == index
                      ? Border.all(
                          color: Colors.blue,
                          width: 2.0,
                        )
                      : Border.all(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.durations[index]} min',
                  style: selectedIndex == index
                      ? const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        )
                      : const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ), // Text color
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DateTimeSelector extends StatefulWidget {
  final Map<DateTime, List<Map<String, DateTime>>>? availability;
  final Function(Timestamp)? onAppointmentSelected;

  const DateTimeSelector(
      {super.key,
      required this.availability,
      required this.onAppointmentSelected});

  @override
  _DateTimeSelectorState createState() => _DateTimeSelectorState();
}

class _DateTimeSelectorState extends State<DateTimeSelector> {
  DateTime? selectedDate;
  String? selectedTimeLabel;
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;

  String formatTimeSlot(DateTime start, DateTime end) {
    final startTime = DateFormat('h:mm a').format(start);
    final endTime = DateFormat('h:mm a').format(end);
    return '$startTime - $endTime';
  }

  DateTime combineDateAndTime(DateTime date, DateTime time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> availableDates = widget.availability?.keys.toList() ?? [];
    List<Map<String, DateTime>> availableTimes =
        selectedDate != null ? widget.availability![selectedDate!] ?? [] : [];

    return Column(children: [
      if (widget.availability == null || widget.availability!.isEmpty)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Currently, there are no available appointment slots. Please contact support or check back later for updates.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
      else
        Column(
          children: [
            Wrap(
              spacing: 6.0,
              children: List.generate(availableDates.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedDate == availableDates[index]) {
                        selectedDate = null;
                        selectedTimeLabel = null;
                        selectedStartTime = null;
                        selectedEndTime = null;
                      } else {
                        selectedDate = availableDates[index];
                        selectedTimeLabel = null;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedDate == availableDates[index]
                          ? const Color.fromRGBO(173, 239, 255, 1)
                          : Colors.white,
                      border: selectedDate == availableDates[index]
                          ? Border.all(color: Colors.blue, width: 2.0)
                          : Border.all(color: Colors.grey, width: 2.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('EEE').format(availableDates[index]),
                          style: selectedDate == availableDates[index]
                              ? const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500)
                              : const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                        ),
                        Text(
                          DateFormat('d/M/y').format(availableDates[index]),
                          style: selectedDate == availableDates[index]
                              ? const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500)
                              : const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            if (selectedDate != null)
              Column(
                children: [
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8.0,
                    children: List.generate(availableTimes.length, (index) {
                      DateTime startTime = availableTimes[index]['start']!;
                      DateTime endTime = availableTimes[index]['end']!;

                      String timeSlot = formatTimeSlot(startTime, endTime);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTimeLabel = timeSlot;
                            selectedStartTime = startTime;
                            selectedEndTime = endTime;

                            DateTime appointmentStartTime =
                                combineDateAndTime(selectedDate!, startTime);

                            // Convert DateTime to Firestore Timestamp
                            Timestamp appointmentTimestamp =
                                Timestamp.fromDate(appointmentStartTime);

                            if (widget.onAppointmentSelected != null) {
                              widget
                                  .onAppointmentSelected!(appointmentTimestamp);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selectedTimeLabel == timeSlot
                                ? const Color.fromRGBO(173, 239, 255, 1)
                                : Colors.white,
                            border: selectedTimeLabel == timeSlot
                                ? Border.all(color: Colors.blue, width: 2.0)
                                : Border.all(color: Colors.grey, width: 2.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            timeSlot,
                            style: selectedTimeLabel == timeSlot
                                ? const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500)
                                : const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (selectedStartTime != null && selectedEndTime != null)
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.blue,
                  ),
                  Text(
                    'Appointment: ${DateFormat('E, yyyy-MM-dd').format(selectedDate!)} | ${formatTimeSlot(selectedStartTime!, selectedEndTime!)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
          ],
        )
    ]);
  }
}
