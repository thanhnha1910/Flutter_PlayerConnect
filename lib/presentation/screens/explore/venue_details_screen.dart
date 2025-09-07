import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:player_connect/core/di/injection.dart';
import 'package:player_connect/presentation/bloc/venue_details/venue_details_bloc.dart';
import 'package:player_connect/presentation/widgets/booking_summary_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:player_connect/data/models/location_details_model.dart';
import 'package:player_connect/data/models/timeslot_model.dart';

class VenueDetailsScreen extends StatefulWidget {
  final String slug;

  const VenueDetailsScreen({super.key, required this.slug});

  @override
  State<VenueDetailsScreen> createState() => _VenueDetailsScreenState();
}

class ConsolidatedBooking {
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Duration duration;
  final double price;
  final String fieldId;
  final double totalAmount;

  ConsolidatedBooking({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.price,
    this.fieldId = '1', // Default field ID
  }) : totalAmount = price; // totalAmount is same as price
}

class _VenueDetailsScreenState extends State<VenueDetailsScreen>
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime?
  _selectedDay; // Still used for the currently selected day in the calendar
  final Map<DateTime, List<TimeOfDay>> _selectedTimeSlots =
  {}; // Stores selected times for multiple days

  late PageController _pageController;
  int _currentPage = 0;
  TabController? _tabController;
  FieldModel? _selectedField;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _initializeTabController(int length) {
    _tabController = TabController(length: length, vsync: this);
  }

  static const double _pricePerHalfHour = 10.0; // Hardcoded price for now

  List<TimeOfDay> _generateTimeSlots(TimeOfDay open, TimeOfDay close,
      DateTime selectedDate) {
    List<TimeOfDay> slots = [];
    DateTime now = DateTime.now();
    DateTime current = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, open.hour,
        open.minute);
    DateTime end = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, close.hour,
        close.minute);

    while (current.isBefore(end)) {
      if (current.minute == 0) {
        bool isToday = selectedDate.year == now.year &&
            selectedDate.month == now.month &&
            selectedDate.day == now.day;

        if (!isToday || current.isAfter(now)) {
          slots.add(TimeOfDay.fromDateTime(current));
        }
      }
      current = current.add(const Duration(hours: 1));
    }
    return slots;
  }

  List<ConsolidatedBooking> _consolidateBookings(
      LocationDetailsModel? locationDetails) {
    List<ConsolidatedBooking> consolidatedBookings = [];

    String fieldId = '1';
    if (locationDetails != null &&
        locationDetails.fieldTypes != null &&
        locationDetails.fieldTypes!.isNotEmpty &&
        locationDetails.fieldTypes!.first.fields != null &&
        locationDetails.fieldTypes!.first.fields!.isNotEmpty) {
      fieldId = locationDetails.fieldTypes!.first.fields!.first.id.toString();
    }

    _selectedTimeSlots.forEach((date, times) {
      if (times.isEmpty) return;

      times.sort((a, b) {
        final dtA =
        DateTime(date.year, date.month, date.day, a.hour, a.minute);
        final dtB =
        DateTime(date.year, date.month, date.day, b.hour, b.minute);
        return dtA.compareTo(dtB);
      });

      List<TimeOfDay> currentGroup = [times.first];

      for (int i = 1; i < times.length; i++) {
        final previousTime = currentGroup.last;
        final currentTime = times[i];

        final previousDateTime = DateTime(
            date.year, date.month, date.day, previousTime.hour,
            previousTime.minute);
        final currentDateTime = DateTime(
            date.year, date.month, date.day, currentTime.hour,
            currentTime.minute);

        if (currentDateTime
            .difference(previousDateTime)
            .inHours == 1) {
          currentGroup.add(currentTime);
        } else {
          final startTime = currentGroup.first;
          final endTime = TimeOfDay.fromDateTime(DateTime(date.year,
              date.month, date.day, currentGroup.last.hour,
              currentGroup.last.minute)
              .add(const Duration(hours: 1)));
          final startDateTime = DateTime(
              date.year, date.month, date.day, startTime.hour,
              startTime.minute);
          final endDateTime = DateTime(
              date.year, date.month, date.day, endTime.hour, endTime.minute);
          final duration = endDateTime.difference(startDateTime);
          final numberOfHours = duration.inHours;
          final price = numberOfHours * (_pricePerHalfHour * 2);

          consolidatedBookings.add(ConsolidatedBooking(
            date: date,
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            price: price,
            fieldId: fieldId,
          ));
          currentGroup = [currentTime];
        }
      }

      final startTime = currentGroup.first;
      final endTime = TimeOfDay.fromDateTime(DateTime(date.year, date.month,
          date.day, currentGroup.last.hour, currentGroup.last.minute)
          .add(const Duration(hours: 1)));
      final startDateTime = DateTime(
          date.year, date.month, date.day, startTime.hour, startTime.minute);
      final endDateTime =
      DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
      final duration = endDateTime.difference(startDateTime);
      final numberOfHours = duration.inHours;
      final price = numberOfHours * (_pricePerHalfHour * 2);

      consolidatedBookings.add(ConsolidatedBooking(
        date: date,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        price: price,
        fieldId: fieldId,
      ));
    });

    return consolidatedBookings;
  }

  String _buildSelectedTimesText(Map<DateTime, List<TimeOfDay>> selectedSlots) {
    if (selectedSlots.isEmpty) {
      return 'No date(s) and time(s) selected';
    }

    String result = 'Selected: ';
    selectedSlots.forEach((date, times) {
      if (times.isEmpty) return;

      times.sort((a, b) {
        final dtA = DateTime(date.year, date.month, date.day, a.hour, a.minute);
        final dtB = DateTime(date.year, date.month, date.day, b.hour, b.minute);
        return dtA.compareTo(dtB);
      });

      String dateString = '${date.year}-${date.month.toString().padLeft(
          2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result += '$dateString (';

      if (times.isNotEmpty) {
        TimeOfDay groupStart = times.first;
        TimeOfDay groupEnd = times.first;

        for (int i = 1; i < times.length; i++) {
          final prevTime = times[i - 1];
          final currentTime = times[i];

          final prevDateTime = DateTime(
              date.year, date.month, date.day, prevTime.hour, prevTime.minute);
          final currentDateTime = DateTime(
              date.year, date.month, date.day, currentTime.hour,
              currentTime.minute);

          if (currentDateTime
              .difference(prevDateTime)
              .inHours == 1) {
            groupEnd = currentTime;
          } else {
            final endTime = TimeOfDay.fromDateTime(DateTime(
                date.year, date.month, date.day, groupEnd.hour, groupEnd.minute)
                .add(const Duration(hours: 1)));
            result +=
            '${groupStart.format(context)} - ${endTime.format(context)}, ';
            groupStart = currentTime;
            groupEnd = currentTime;
          }
        }
        final endTime = TimeOfDay.fromDateTime(DateTime(
            date.year, date.month, date.day, groupEnd.hour, groupEnd.minute)
            .add(const Duration(hours: 1)));
        result += '${groupStart.format(context)} - ${endTime.format(context)}';
      }
      result += '); ';
    });

    return result;
  }

  void _showTimeSlotPicker(BuildContext context, DateTime day,
      FieldModel field) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime selectedDay = DateTime(day.year, day.month, day.day);

    if (selectedDay.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot book for a past date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Dispatch event to fetch available time slots for the selected field and date
    final bookings = _selectedField?.bookings
            ?.where((booking) =>
                booking.startTime?.year == day.year &&
                booking.startTime?.month == day.month &&
                booking.startTime?.day == day.day)
            .toList() ??
        [];

    List<TimeOfDay> tempSelectedTimes = List.from(
        _selectedTimeSlots[day] ?? []);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Select Time Slot(s) for ${day.toLocal().toString().split(' ')[0]}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _generateTimeSlots(
                        const TimeOfDay(hour: 9, minute: 0),
                        const TimeOfDay(hour: 17, minute: 0),
                        day,
                      ).length,
                      itemBuilder: (context, index) {
                        final time = _generateTimeSlots(
                          const TimeOfDay(hour: 9, minute: 0),
                          const TimeOfDay(hour: 17, minute: 0),
                          day,
                        )[index];
                        final isSelected = tempSelectedTimes.contains(time);
                        final isPast = day.isAtSameMomentAs(today) &&
                            (time.hour < now.hour ||
                                (time.hour == now.hour &&
                                    time.minute <= now.minute));

                        final isBooked = bookings.any((booking) =>
                            booking.startTime?.hour == time.hour &&
                            booking.startTime?.minute == time.minute);

                        return CheckboxListTile(
                          title: Text(
                            time.format(context),
                            style: TextStyle(
                              color: isBooked ? Colors.grey : null,
                              decoration: isBooked
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: isBooked
                              ? const Text('Booked',
                                  style: TextStyle(color: Colors.red))
                              : null,
                          value: isSelected,
                          onChanged: isPast || isBooked
                              ? null
                              : (bool? value) {
                                  setModalState(() {
                                    if (value == true) {
                                      tempSelectedTimes.add(time);
                                    } else {
                                      tempSelectedTimes.remove(time);
                                    }
                                  });
                                },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (tempSelectedTimes.isNotEmpty) {
                            _selectedTimeSlots[day] = tempSelectedTimes;
                          } else {
                            _selectedTimeSlots.remove(day);
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      getIt<VenueDetailsBloc>()
        ..add(FetchVenueDetails(widget.slug)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Venue Details'),
        ),
        body: BlocConsumer<VenueDetailsBloc, VenueDetailsState>(
          listener: (context, state) {
            if (state is VenueDetailsLoaded) {
              if (state.locationDetails.fieldTypes != null &&
                  state.locationDetails.fieldTypes!.isNotEmpty) {
                _initializeTabController(
                    state.locationDetails.fieldTypes!.length);
              }
            }
          },
          builder: (context, state) {
            if (state is VenueDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is VenueDetailsLoaded) {
              final details = state.locationDetails;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: details.fieldTypes?.first.fields?.first
                          .imageGallery ??
                          'https://via.placeholder.com/400x200',
                      placeholder: (context, url) =>
                          Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                      errorWidget: (context, url, error) =>
                          Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                                child: Icon(Icons.error, color: Colors.red)),
                          ),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(details.name,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(details.address,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyLarge),
                          const SizedBox(height: 16),
                          if (details.fieldTypes != null &&
                              details.fieldTypes!.isNotEmpty &&
                              _tabController != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Fields', style: Theme
                                    .of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                TabBar(
                                  controller: _tabController,
                                  isScrollable: true,
                                  tabs: details.fieldTypes!
                                      .map((fieldType) =>
                                      Tab(
                                          text: fieldType.name ??
                                              'Unnamed Type'))
                                      .toList(),
                                ),
                                SizedBox(
                                  height: 250, // Adjust height as needed
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: details.fieldTypes!
                                        .map((fieldType) =>
                                        _buildFieldList(fieldType.fields))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 24),
                          Visibility(
                            visible: _selectedField != null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Select Date(s) and Time(s)',
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                TableCalendar(
                                  firstDay: DateTime.utc(2020, 1, 1),
                                  lastDay: DateTime.utc(2030, 12, 31),
                                  focusedDay: _focusedDay,
                                  calendarFormat: _calendarFormat,
                                  selectedDayPredicate: (day) {
                                    return _selectedTimeSlots.containsKey(day);
                                  },
                                  onDaySelected: (selectedDay, focusedDay) {
                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay = focusedDay;
                                    });
                                    _showTimeSlotPicker(
                                        context, selectedDay, _selectedField!);
                                  },
                                  onFormatChanged: (format) {
                                    if (_calendarFormat != format) {
                                      setState(() {
                                        _calendarFormat = format;
                                      });
                                    }
                                  },
                                  onPageChanged: (focusedDay) {
                                    _focusedDay = focusedDay;
                                  },
                                ),
                                const SizedBox(height: 16),
                                Text(_buildSelectedTimesText(
                                    _selectedTimeSlots)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 15),
                                  textStyle: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)
                              ),
                              onPressed: () {
                                if (_selectedTimeSlots.isNotEmpty) {
                                  final List<ConsolidatedBooking> bookings =
                                  _consolidateBookings(details);
                                  double totalAmount = 0.0;
                                  for (var booking in bookings) {
                                    totalAmount += booking.price;
                                  }
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        BookingSummaryDialog(
                                          bookings: bookings,
                                          totalAmount: totalAmount,
                                        ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Please select at least one date and time slot.'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Book Now'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text('Reviews', style: Theme
                              .of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          if (details.reviews != null &&
                              details.reviews!.isNotEmpty)
                            ...details.reviews!.map((review) =>
                                Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0),
                                  child: ListTile(
                                    title: Text('Rating: ${review.rating}'),
                                    subtitle: Text(review.comment ?? ''),
                                  ),
                                ))
                          else
                            const Text('No reviews yet.'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is VenueDetailsError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Welcome to venue details!'));
          },
        ),
      ),
    );
  }

  Widget _buildFieldList(List<FieldModel>? fields) {
    if (fields == null || fields.isEmpty) {
      return const Center(child: Text('No fields available.'));
    }
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: fields.length,
      itemBuilder: (context, index) {
        final field = fields[index];
        return SizedBox(
          width: 250,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedField = field;
              });
            },
            child: Card(
              margin: const EdgeInsets.all(8.0),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                    imageUrl: field.thumbnailUrl ??
                        'https://via.placeholder.com/250x150',
                    placeholder: (context, url) =>
                        Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: const Center(
                              child: CircularProgressIndicator()),
                        ),
                    errorWidget: (context, url, error) =>
                        Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: const Center(child: Icon(
                              Icons.error, color: Colors.red)),
                        ),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(field.name ?? 'Unnamed Field',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(field.description ?? '', maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Text(field.hourlyRate?.toStringAsFixed(2) ?? 'N/A',
                            style: TextStyle(color: Theme
                                .of(context)
                                .primaryColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}