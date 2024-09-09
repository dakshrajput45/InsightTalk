import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:insighttalk_backend/apis/appointment/appointment_apis.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/modal/modal_appointment.dart';
import 'package:insighttalk_expert/pages/appointment/appointment_controller.dart';

class AppointmentTabView extends StatefulWidget {
  final DateTimeFilter dateTimeFilter;

  const AppointmentTabView({super.key, required this.dateTimeFilter});

  @override
  State<AppointmentTabView> createState() => _AppointmentTabViewState();
}

class _AppointmentTabViewState extends State<AppointmentTabView> {
  bool _isLoading = true;
  final List<DsdAppointment> _appointments = [];
  String? profileImage;
  String? userName;
  StreamSubscription? appointmentStream;
  DocumentSnapshot<Object?>? _lastSnapShot;
  final DsdAppointmentController _dsdAppointmentController = DsdAppointmentController();
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();

  var defaultImage =
      "https://imgv3.fotor.com/images/blog-cover-image/10-profile-picture-ideas-to-make-you-stand-out.jpg";

  @override
  void initState() {
    super.initState();
    loadData(
      dateFilter: widget.dateTimeFilter,
    );
  }

  void _showAppointmentDetails(BuildContext context, DsdAppointment appointment) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController linkController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Appointment Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Reason: ${appointment.reason ?? 'No reason provided'}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Link:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    hintText: 'Please enter a Google Meet link',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a link';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: const TextStyle(fontSize: 14),
                    minimumSize: const Size(100, 40),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      String link = linkController.text;
                      print("${appointment.id!} ${appointment.userId} ${appointment.expertId}");
                      await _dsdAppointmentController.updateConfirmation(
                          appointment.id!, link, appointment.userId!, appointment.expertId!);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            margin: const EdgeInsets.only(top: 16),
            child: (_appointments.isNotEmpty)
                ? ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var appointment = _appointments[index];
                      return Container(
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: InkWell(
                          onTap: () {
                            if (!appointment.confirmation! &&
                                widget.dateTimeFilter != DateTimeFilter.past) {
                              _showAppointmentDetails(context, appointment);
                            }
                          },
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(8),
                                margin: EdgeInsets.zero,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        if (appointment.category != null)
                                          ...appointment.category!.asMap().entries.map((entry) {
                                            int index = entry.key;
                                            String category = entry.value;

                                            // Determine the color based on the index
                                            Color bgColor =
                                                (index % 2 == 0) ? Colors.grey : Colors.blue;

                                            Color textColor =
                                                (index % 2 == 0) ? Colors.black : Colors.white;

                                            return labelBuilder(
                                              context,
                                              category,
                                              bgColor: bgColor,
                                              textColor: textColor,
                                            );
                                          }),
                                      ],
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        radius: 28,
                                        foregroundImage: CachedNetworkImageProvider(
                                            appointment.profileImage ?? defaultImage),
                                        backgroundColor:
                                            Theme.of(context).colorScheme.surfaceContainerHigh,
                                        child: Icon(
                                          Icons.person,
                                          color: Theme.of(context).colorScheme.tertiary,
                                        ),
                                      ),
                                      title: Text(
                                        appointment.name!,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_month_outlined,
                                                size: 18,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.7),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                appointment.appointmentTime!.toDate().toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withOpacity(0.7)),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.alarm,
                                                size: 18,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.7),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                appointment.duration!.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withOpacity(0.7)),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      isThreeLine: true,
                                      trailing: PopupMenuButton(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          size: 18,
                                        ),
                                        splashRadius: 18,
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            child: ListTile(
                                                onTap: () {
                                                  // Navigator.pop(context);
                                                  // _cancelAppointment(appointment);
                                                },
                                                leading: const Icon(
                                                  Icons.cancel_outlined,
                                                ),
                                                title: const Text(
                                                  "Cancel",
                                                )),
                                          ),
                                          const PopupMenuItem(
                                            child: ListTile(
                                                leading: Icon(
                                                  Icons.help_outline,
                                                ),
                                                title: Text(
                                                  "Help",
                                                )),
                                          ),
                                        ],
                                        surfaceTintColor: Theme.of(context).colorScheme.surface,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ButtonStyle(
                                              backgroundColor: WidgetStatePropertyAll<Color>(
                                                Theme.of(context).colorScheme.secondary,
                                              ),
                                            ),
                                            onPressed: () {
                                              print(widget.dateTimeFilter);
                                              if (!appointment.confirmation! &&
                                                  widget.dateTimeFilter != DateTimeFilter.past) {
                                                _showAppointmentDetails(context, appointment);
                                              }
                                            },
                                            label: !appointment.confirmation!
                                                ? const Text(
                                                    "Confirm Meeting",
                                                    style: TextStyle(fontSize: 18),
                                                  )
                                                : const Text(
                                                    'Click to join Meeting',
                                                    style: TextStyle(fontSize: 18),
                                                  ),
                                            icon: const Icon(
                                              Icons.done_all,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: _appointments.length,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 100,
                          color: Colors.blue,
                        ),
                        Text(getNoAppointmentTitle(widget.dateTimeFilter)),
                      ],
                    ),
                  ),
          );
  }

  Future<void> loadData({
    DateTime? endDateTime,
    required DateTimeFilter dateFilter,
    bool hardReset = false,
    bool showLoader = true,
  }) async {
    try {
      if (hardReset) {
        _appointments.clear();
        _lastSnapShot = null;
      }
      if (showLoader) {
        setState(() {
          _isLoading = true;
        });
      }
      var (appointments, lastSnapshot) = await _dsdAppointmentController.fetchAppointments(
        dateFilter: dateFilter,
        uid: _itUserAuthSDK.getUser()!.uid,
        startAfter: _lastSnapShot,
      );

      for (var appointment in appointments) {
        String? profileImage;
        String? userName;
        (profileImage, userName) =
            await _dsdAppointmentController.fetchUserById(appointment.userId!);

        appointment.name = userName;
        appointment.profileImage = profileImage;
      }
      _appointments.addAll(appointments);
      _lastSnapShot = lastSnapshot;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('error while fetching appointment: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    appointmentStream?.cancel();
  }
}

Widget labelBuilder(BuildContext context, String text, {Color? bgColor, Color? textColor}) {
  return Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: bgColor ?? Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: textColor ?? Colors.black, // Default text color if not provided
      ),
    ),
  );
}

String getNoAppointmentTitle(DateTimeFilter date) {
  switch (date) {
    case DateTimeFilter.past:
      return 'There are no previous appointments';
    case DateTimeFilter.today:
      return 'There are no appointments for today';
    case DateTimeFilter.future:
      return 'Your upcoming appointments will appear here';
    default:
      return 'There are no appointments yet';
  }
}
