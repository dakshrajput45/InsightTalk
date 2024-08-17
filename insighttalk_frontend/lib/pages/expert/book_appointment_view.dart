import 'package:flutter/material.dart';
import 'package:insighttalk_backend/apis/expert/expert_apis.dart';
import 'package:insighttalk_backend/modal/modal_expert.dart';
import 'package:intl/intl.dart';

class BookAppointmentView extends StatefulWidget {
  final String expertId;
  const BookAppointmentView({required this.expertId, super.key});

  @override
  State<BookAppointmentView> createState() => _BookAppointmentViewState();
}

class _BookAppointmentViewState extends State<BookAppointmentView> {
  final DsdExpertApis _dsdExpertApis = DsdExpertApis();
  DsdExpert? expertData;
  List<DateTime> availableDates = [
    DateTime(2024, 8, 18),
    DateTime(2024, 8, 22),
    DateTime(2024, 8, 24),
    DateTime(2024, 8, 25),
    DateTime(2024, 9, 1),
  ];
  TextEditingController reasonController = TextEditingController();
  List<DateTime> availableTimeSlots = [];
  Future<void> getExpertData() async {
    try {
      DsdExpert? fetchedExpertData =
          await _dsdExpertApis.fetchExpertById(expertId: widget.expertId);

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
    getExpertData();
  }

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
                      child:
                          expertData != null && expertData!.profileImage != null
                              ? Image.network(
                                  expertData!.profileImage!,
                                  fit: BoxFit.cover,
                                  width: 170,
                                  height: 170,
                                )
                              : Image.network(
                                  'https://imgv3.fotor.com/images/blog-cover-image/10-profile-picture-ideas-to-make-you-stand-out.jpg',
                                  fit: BoxFit.cover,
                                  width: 170,
                                  height: 170,
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
                          expertData?.expertName ?? 'Unknown Expert',
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          expertData?.expertise ?? 'Unknown',
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
              const CategorySelector(),
              const SizedBox(
                height: 20,
              ),
              const Text("Select Date & Time",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(
                height: 20,
              ),
              DateTimeSelector(),
              const SizedBox(
                height: 20,
              ),
              const Text("Specify Reason",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(
                height: 10,
              ),
              TextField(
                decoration:
                    const InputDecoration(icon: Icon(Icons.note_alt_outlined)),
                controller: reasonController,
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey),
                    ),
                    Text("₹ 60.00", style: TextStyle(fontSize: 20)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
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
        ));
  }
}

class CategorySelector extends StatefulWidget {
  const CategorySelector({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  // List of categories
  List<String> categories = [
    'Category 1',
    'Category 2',
    'Category 3',
    'Category 4',
    'Category 5',
    'Category 6',
    'Category 7',
    'Category 8'
  ];

  int selectedIndex = -1;

  String selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: List.generate(categories.length, (index) {
          return GestureDetector(
            onTap: () {
              if (selectedIndex == index) {
                setState(() {
                  selectedIndex = -1;
                  selectedCategory = '';
                });
              } else {
                setState(() {
                  selectedIndex = index;
                  selectedCategory = categories[index];
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selectedIndex == index
                    ? const Color.fromRGBO(173, 239, 255, 1)
                    : Colors.white,
                border: selectedIndex == index
                    ? Border.all(color: Colors.blue, width: 2.0)
                    : Border.all(color: Colors.grey, width: 2.0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categories[index],
                style: selectedIndex == index
                    ? const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.w500)
                    : const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500), // Text color
              ),
            ),
          );
        }),
      ),
    );
  }
}

class DateTimeSelector extends StatefulWidget {
  @override
  _DateTimeSelectorState createState() => _DateTimeSelectorState();
}

class _DateTimeSelectorState extends State<DateTimeSelector> {
  List<DateTime> availableDates = [
    DateTime(2024, 8, 18),
    DateTime(2024, 8, 19),
    DateTime(2024, 8, 20),
    DateTime(2024, 8, 21),
  ];
  List<String> availableTimes = [
    '09:00 AM',
    '11:00 AM',
    '02:00 PM',
    '04:00 PM'
  ];

  DateTime? selectedDate;
  String? selectedTime;
  DateTime? selectedDateTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 6.0,
          children: List.generate(availableDates.length, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedDate = availableDates[index];
                  selectedTime = null;
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
                              color: Colors.blue, fontWeight: FontWeight.w500)
                          : const TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      DateFormat('d/M/y').format(availableDates[index]),
                      style: selectedDate == availableDates[index]
                          ? const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.w500)
                          : const TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8.0,
          children: List.generate(availableTimes.length, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedTime = availableTimes[index];
                  selectedDateTime = DateFormat('yyyy-MM-dd hh:mm a').parse(
                    '${DateFormat('yyyy-MM-dd').format(selectedDate!)} ${availableTimes[index]}',
                  );
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedTime == availableTimes[index]
                      ? const Color.fromRGBO(173, 239, 255, 1)
                      : Colors.white,
                  border: selectedTime == availableTimes[index]
                      ? Border.all(color: Colors.blue, width: 2.0)
                      : Border.all(color: Colors.grey, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  availableTimes[index],
                  style: selectedTime == availableTimes[index]
                      ? const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w500)
                      : const TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        if (selectedDateTime != null)
          Center(
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.blue,
                ),
                Text(
                  'Appointment: ${DateFormat('E, yyyy-MM-dd | hh:mm a').format(selectedDateTime!)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
