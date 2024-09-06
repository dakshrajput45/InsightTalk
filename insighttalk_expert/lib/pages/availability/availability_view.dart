import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


import 'package:insighttalk_backend/apis/availablity/availablity_sdk.dart';
import 'package:insighttalk_backend/apis/expert/expert_apis.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/helper/toast.dart';
import 'package:insighttalk_backend/modal/modal_availablity.dart';

import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

final DsdExpertProfileController _dsdProfileController =
    DsdExpertProfileController();

class AvailabilityView extends StatefulWidget {
  const AvailabilityView({super.key});

  @override
  State<AvailabilityView> createState() => _AvailabilityViewState();
}

class _AvailabilityViewState extends State<AvailabilityView> {
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
  final DsdAvailablitySDK _availablitySDK = DsdAvailablitySDK();
  List<DateTime> selectedDates = [];
  DateTime today = DateTime.now();

  bool _loading = true;
  bool _sendData = false;


  late DateTime firstDay;
  late DateTime lastDay;
  DateTime focusedDay = DateTime.now();
  DateTime? currentEditingDate;
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();


  Map<DateTime, List<AvailabilitySlot>> dateWiseTimeslots = {};

  Future<void> getExpertAvailablity() async {
    try {
      String? expertId = _itUserAuthSDK.getUser()!.uid;
      DsdExpertAvailability? schedule =
          await _availablitySDK.getAvailability(expertId);

      // Ensure that the data is not null
      if (schedule != null && schedule.availability != null) {
        setState(() {
          dateWiseTimeslots = schedule.availability!;
          selectedDates = dateWiseTimeslots.keys.toList();
        });
      }
    } catch (e) {
      print('Error fetching availability: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    firstDay = DateTime(today.year, today.month, today.day);
    lastDay = DateTime(today.year, today.month + 1, today.day);
    currentEditingDate = focusedDay;
    getExpertAvailablity(); // Load data initially
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      // Check if the selected day has not been added to the selectedDates
      if (!selectedDates.contains(selectedDay)) {
        // Add the selected day to the list of selectedDates
        selectedDates.add(selectedDay);

        // Assign default availability slots for the new day
        dateWiseTimeslots[selectedDay] = [
          AvailabilitySlot(
            start: DateTime(
                selectedDay.year, selectedDay.month, selectedDay.day, 8, 0),
            end: DateTime(
                selectedDay.year, selectedDay.month, selectedDay.day, 10, 0),
          ),
          AvailabilitySlot(
            start: DateTime(
                selectedDay.year, selectedDay.month, selectedDay.day, 11, 0),
            end: DateTime(
                selectedDay.year, selectedDay.month, selectedDay.day, 13, 0),
          ),
          AvailabilitySlot(
            start: DateTime(
                selectedDay.year, selectedDay.month, selectedDay.day, 14, 0),
            end: DateTime(
                selectedDay.year, selectedDay.month, selectedDay.day, 16, 0),
          ),
        ];
      }
      // Set the currently selected day as the day to be edited
      currentEditingDate = selectedDay;

      // Update the focused day
      this.focusedDay = focusedDay;
    });
  }

  void removeTimeslot(DateTime date, int index) {
    setState(() {
      dateWiseTimeslots[date]?.removeAt(index);
    });
  }

  void addTimeslot(DateTime date) {
    setState(() {
      dateWiseTimeslots[date]?.add(
        AvailabilitySlot(
          start: DateTime(date.year, date.month, date.day, 8, 0),
          end: DateTime(date.year, date.month, date.day, 10, 0),
        ),
      );
    });
  }

  void removeDate(DateTime date) {
    setState(() {
      selectedDates.remove(date);
      dateWiseTimeslots.remove(date);
      currentEditingDate = selectedDates.isNotEmpty ? selectedDates.last : null;
    });
  }

  bool validateTimes(DateTime startTime, DateTime endTime) {
    return endTime.isAfter(startTime.add(const Duration(minutes: 30)));
  }

  Future<void> _selectTime(
      BuildContext context, bool isStartTime, int index) async {
    if (currentEditingDate == null ||
        dateWiseTimeslots[currentEditingDate!] == null) return;

    final DateTime selectedDate = currentEditingDate!;
    final AvailabilitySlot timeSlot = dateWiseTimeslots[selectedDate]![index];

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(isStartTime ? timeSlot.start : timeSlot.end),
    );
    if (picked != null) {
      final DateTime newTime = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, picked.hour, picked.minute);
      if (isStartTime) {
        if (validateTimes(newTime, timeSlot.end)) {
          setState(() {
            dateWiseTimeslots[selectedDate]![index] =
                AvailabilitySlot(start: newTime, end: timeSlot.end);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Start time must be at least 30 minutes before end time.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (validateTimes(timeSlot.start, newTime)) {
          setState(() {
            dateWiseTimeslots[selectedDate]![index] =
                AvailabilitySlot(start: timeSlot.start, end: newTime);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'End time must be at least 30 minutes after start time.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(
            child: CircularProgressIndicator()) // Center loading indicator
        : Scaffold(
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Manage Your Availability',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Select a date and customize your availability. Easily manage timeslots for each selected date and keep track of your schedule.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TableCalendar(
                      firstDay: firstDay,
                      lastDay: lastDay,
                      focusedDay: focusedDay,
                      selectedDayPredicate: (day) =>
                          selectedDates.contains(day),
                      onDaySelected: onDaySelected,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                      },
                      calendarBuilders: CalendarBuilders(
                        selectedBuilder: (context, date, _) {
                          return Container(
                            margin: const EdgeInsets.all(6.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: currentEditingDate == date
                                  ? Colors.blue
                                  : const Color.fromARGB(255, 56, 191, 245),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                        todayBuilder: (context, date, _) {
                          return Container(
                            margin: const EdgeInsets.all(6.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: date == focusedDay
                                  ? Colors.blue
                                  : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                      enabledDayPredicate: (day) {
                        return day.isAfter(
                                today.subtract(const Duration(days: 1))) &&
                            day.isBefore(lastDay.add(const Duration(days: 1)));
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (currentEditingDate != null &&
                      dateWiseTimeslots[currentEditingDate!] != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Timeslots for ${DateFormat('yMMMMd').format(currentEditingDate!)}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          ...dateWiseTimeslots[currentEditingDate!]!
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            AvailabilitySlot timeSlot = entry.value;
                            return ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        await _selectTime(context, true, index);
                                      },
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 10.0),
                                          labelText: 'From',
                                          border: OutlineInputBorder(),
                                        ),
                                        child: Text(
                                          '${timeSlot.start.hour}:${timeSlot.start.minute.toString().padLeft(2, '0')}',
                                          style: const TextStyle(height: 0.7),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        await _selectTime(
                                            context, false, index);
                                      },
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: 'To',
                                          border: OutlineInputBorder(),
                                        ),
                                        child: Text(
                                          '${timeSlot.end.hour}:${timeSlot.end.minute.toString().padLeft(2, '0')}',
                                          style: const TextStyle(height: 0.7),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      removeTimeslot(
                                          currentEditingDate!, index);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 50,
                                  width: 150,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 0),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromRGBO(173, 239, 255, 1),
                                    border: Border.all(
                                        color: Colors.blue, width: 2.0),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      addTimeslot(currentEditingDate!);
                                    },
                                    child: const Text(
                                      'Add TimeSlot',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  width: 150,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 0),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 255, 191, 186),
                                    border: Border.all(
                                        color: Colors.red, width: 2.0),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      removeDate(currentEditingDate!);
                                    },
                                    child: const Text(
                                      'Remove Date',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Save logic
                        final availability = DsdExpertAvailability(
                          expertId: _itUserAuthSDK.getUser()!.uid,
                          availability: dateWiseTimeslots.map((date, slots) {
                            return MapEntry(
                              date,
                              slots,
                            );
                          }),
                        );
                        setState(() {
                          _sendData = true;
                        });

                        _availablitySDK
                            .updateExpertAvailability(
                                expertId: _itUserAuthSDK.getUser()!.uid,
                                newAvailability: availability)
                            .then((value) {
                          setState(() {
                            _sendData = false;
                          });
                          DsdToastMessages.success(context,
                              text: "Time Slots Updated!");
                        });
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
          );
  }
}
