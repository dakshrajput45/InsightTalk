import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AvailabilityView extends StatefulWidget {
  const AvailabilityView({super.key});

  @override
  State<AvailabilityView> createState() => _AvailabilityViewState();
}

class _AvailabilityViewState extends State<AvailabilityView> {
  List<DateTime> selectedDates = [];
  DateTime today = DateTime.now();

  late DateTime firstDay;
  late DateTime lastDay;
  DateTime focusedDay = DateTime.now();

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

  @override
  void initState() {
    super.initState();
    firstDay = DateTime(today.year, today.month, today.day);
    lastDay = DateTime(today.year, today.month + 1, today.day);
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (selectedDay.isAfter(today.subtract(const Duration(days: 1)))) {
      setState(() {
        if (selectedDates.contains(selectedDay)) {
          selectedDates.remove(selectedDay);
        } else {
          selectedDates.add(selectedDay);
        }
      });
    }
  }

  bool validateTimes(DateTime startTime, DateTime endTime) {
    return endTime.isAfter(startTime.add(const Duration(minutes: 30)));
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime, String day,
      Map<String, DateTime> timeSlot) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          isStartTime ? timeSlot['start']! : timeSlot['end']!),
    );
    if (picked != null) {
      final DateTime newTime = DateTime(
          timeSlot['start']!.year,
          timeSlot['start']!.month,
          timeSlot['start']!.day,
          picked.hour,
          picked.minute);
      if (isStartTime) {
        if (validateTimes(newTime, timeSlot['end']!)) {
          setState(() {
            timeSlot['start'] = newTime;
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
        if (validateTimes(timeSlot['start']!, newTime)) {
          setState(() {
            timeSlot['end'] = newTime;
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Manage Your Availability',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Select dates and customize your availability schedule for each day to manage your time efficiently.',
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
              selectedDayPredicate: (day) => selectedDates.contains(day),
              onDaySelected: (selectedDay, newFocusedDay) {
                onDaySelected(selectedDay, newFocusedDay);
                setState(() {
                  focusedDay = newFocusedDay;
                });
              },
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, date, events) {
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
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
                return day.isAfter(today.subtract(const Duration(days: 1))) &&
                    day.isBefore(lastDay.add(const Duration(days: 1)));
              },
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Weekly Time Schedule',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: days.keys.map((String day) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: days[day],
                          onChanged: (bool? value) {
                            setState(() {
                              days[day] = value!;
                              if (value) {
                                if (selectedTimes[day]!.isEmpty) {
                                  selectedTimes[day]!.add({
                                    'start': DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                      8,
                                      0,
                                    ),
                                    'end': DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                      20,
                                      0,
                                    ),
                                  });
                                }
                              } else {
                                selectedTimes[day]!.clear();
                              }
                            });
                          },
                        ),
                        Expanded(
                          child:
                              Text(day, style: const TextStyle(fontSize: 16)),
                        ),
                        if (!days[day]!)
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Unavailable',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (days[day]!)
                      Column(
                        children: [
                          ...selectedTimes[day]!.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, DateTime> timeSlot = entry.value;
                            return ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        await _selectTime(
                                            context, true, day, timeSlot);
                                      },
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 10.0),
                                          labelText: 'From',
                                          border: OutlineInputBorder(),
                                        ),
                                        child: Text(
                                          '${timeSlot['start']?.hour}:${timeSlot['start']?.minute.toString().padLeft(2, '0')}',
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
                                            context, false, day, timeSlot);
                                      },
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: 'To',
                                          border: OutlineInputBorder(),
                                        ),
                                        child: Text(
                                          '${timeSlot['end']?.hour}:${timeSlot['end']?.minute.toString().padLeft(2, '0')}',
                                          style: const TextStyle(height: 0.7),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                        index == 0 ? Icons.add : Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        if (index == 0) {
                                          selectedTimes[day]!.add({
                                            'start': DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              DateTime.now().day,
                                              8,
                                              0,
                                            ),
                                            'end': DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              DateTime.now().day,
                                              20,
                                              0,
                                            ),
                                          });
                                        } else {
                                          selectedTimes[day]!.removeAt(index);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
