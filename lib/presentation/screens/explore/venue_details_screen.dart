import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:player_connect/core/di/injection.dart';
import 'package:player_connect/presentation/bloc/venue_details/venue_details_bloc.dart';
import 'package:player_connect/presentation/widgets/booking_summary_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:player_connect/data/models/location_details_model.dart';


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

class _VenueDetailsScreenState extends State<VenueDetailsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay; // Still used for the currently selected day in the calendar
  Map<DateTime, List<TimeOfDay>> _selectedTimeSlots = {}; // Stores selected times for multiple days

  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page!.round();
          print('Current Page: $_currentPage, PageController.page: ${_pageController.page}'); // Debug print
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static const double _pricePerHalfHour = 10.0; // Hardcoded price for now

  List<TimeOfDay> _generateTimeSlots(TimeOfDay open, TimeOfDay close, DateTime selectedDate) {
    List<TimeOfDay> slots = [];
    DateTime now = DateTime.now();
    DateTime current = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, open.hour, open.minute);
    DateTime end = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, close.hour, close.minute);

    // Chỉ tạo slots cho giờ chẵn (không có phút lẻ)
    while (current.isBefore(end)) {
      // Chỉ thêm slot nếu là giờ chẵn (minute = 0)
      if (current.minute == 0) {
        // Kiểm tra nếu ngày được chọn là hôm nay, chỉ cho phép giờ sau thời điểm hiện tại
        bool isToday = selectedDate.year == now.year && 
                      selectedDate.month == now.month && 
                      selectedDate.day == now.day;
        
        if (!isToday || current.isAfter(now)) {
          slots.add(TimeOfDay.fromDateTime(current));
        }
      }
      current = current.add(const Duration(hours: 1)); // Tăng 1 giờ thay vì 30 phút
    }
    return slots;
  }

  List<ConsolidatedBooking> _consolidateBookings(LocationDetailsModel? locationDetails) {
    List<ConsolidatedBooking> consolidatedBookings = [];

    // Lấy fieldId thực từ LocationDetailsModel một cách an toàn
    String fieldId = '1'; // Giá trị mặc định
    if (locationDetails != null && 
        locationDetails.fieldTypes != null && 
        locationDetails.fieldTypes!.isNotEmpty &&
        locationDetails.fieldTypes!.first.fields != null &&
        locationDetails.fieldTypes!.first.fields!.isNotEmpty) {
      fieldId = locationDetails.fieldTypes!.first.fields!.first.id.toString();
    }

    _selectedTimeSlots.forEach((date, times) {
      if (times.isEmpty) return;

      // Sort times to ensure correct grouping
      times.sort((a, b) {
        final dtA = DateTime(date.year, date.month, date.day, a.hour, a.minute);
        final dtB = DateTime(date.year, date.month, date.day, b.hour, b.minute);
        return dtA.compareTo(dtB);
      });

      List<TimeOfDay> currentGroup = [times.first];

      for (int i = 1; i < times.length; i++) {
        final previousTime = currentGroup.last;
        final currentTime = times[i];

        final previousDateTime = DateTime(date.year, date.month, date.day, previousTime.hour, previousTime.minute);
        final currentDateTime = DateTime(date.year, date.month, date.day, currentTime.hour, currentTime.minute);

        // Check if current time is exactly 1 hour after the previous time
        if (currentDateTime.difference(previousDateTime).inHours == 1) {
          currentGroup.add(currentTime);
        } else {
          // End of a continuous block, consolidate and start new group
          final startTime = currentGroup.first;
          final endTime = TimeOfDay.fromDateTime(DateTime(date.year, date.month, date.day, currentGroup.last.hour, currentGroup.last.minute).add(const Duration(hours: 1)));
          final startDateTime = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
          final endDateTime = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
          final duration = endDateTime.difference(startDateTime);
          final numberOfHours = duration.inHours;
          final price = numberOfHours * (_pricePerHalfHour * 2); // Giá theo giờ

          consolidatedBookings.add(ConsolidatedBooking(
            date: date,
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            price: price,
            fieldId: fieldId, // Sử dụng fieldId thực
          ));
          currentGroup = [currentTime];
        }

      }

      // Consolidate the last group
      final startTime = currentGroup.first;
      final endTime = TimeOfDay.fromDateTime(DateTime(date.year, date.month, date.day, currentGroup.last.hour, currentGroup.last.minute).add(const Duration(hours: 1)));
      final startDateTime = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
      final endDateTime = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
      final duration = endDateTime.difference(startDateTime);
      final numberOfHours = duration.inHours;
      final price = numberOfHours * (_pricePerHalfHour * 2); // Giá theo giờ

      consolidatedBookings.add(ConsolidatedBooking(
        date: date,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        price: price,
        fieldId: fieldId, // Sử dụng fieldId thực
      ));
    });

    return consolidatedBookings;
  }



  void _showTimeSlotPicker(BuildContext context, DateTime day) {
    // Kiểm tra nếu ngày được chọn đã qua
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime selectedDay = DateTime(day.year, day.month, day.day);
    
    if (selectedDay.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể đặt lịch cho ngày đã qua'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final TimeOfDay openingTime = TimeOfDay(hour: 9, minute: 0); // Hardcoded for now
    final TimeOfDay closingTime = TimeOfDay(hour: 17, minute: 0); // Hardcoded for now
    final List<TimeOfDay> allTimeSlots = _generateTimeSlots(openingTime, closingTime, day);

    // Initialize tempSelectedTimes with existing selections for this day
    List<TimeOfDay> tempSelectedTimes = List.from(_selectedTimeSlots[day] ?? []);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Select Time Slot(s) for ${day.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allTimeSlots.length,
                      itemBuilder: (context, index) {
                        final time = allTimeSlots[index];
                        final isSelected = tempSelectedTimes.contains(time);
                        return CheckboxListTile(
                          title: Text(time.format(context)),
                          value: isSelected,
                          onChanged: (bool? value) {
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
                        Navigator.pop(context); // Close the bottom sheet
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

  Widget _buildBookingCard(ConsolidatedBooking booking, BuildContext context, int index) {
    print('Building booking card for price: ${booking.price}'); // Debug print
    return SizedBox(
      width: 300, // Fixed width for the card
      height: 300, // Fixed height for the card
      child: Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking ${index + 1}', // New title
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Date: ${booking.date.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Time: ${booking.startTime.format(context)}',
            ),
            if (booking.duration.inMinutes > 0)
              SizedBox(height: 8),
            if (booking.duration.inMinutes > 0)
              Text(
                'End Time: ${booking.endTime.format(context)}',
              ),
            SizedBox(height: 8),
            Text(
              'Duration: ${booking.duration.inHours} hours',
            ),
            SizedBox(height: 8),
            Text(
              'Price: \$${booking.price.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildModernBookingCard(ConsolidatedBooking booking, BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với số thứ tự
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Lượt ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.sports_tennis,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Thông tin ngày
            _buildInfoRow(
              Icons.calendar_today,
              'Ngày',
              booking.date.toLocal().toString().split(' ')[0],
              context,
            ),
            const SizedBox(height: 8),
            // Thông tin thời gian
            _buildInfoRow(
              Icons.access_time,
              'Thời gian',
              '${booking.startTime.format(context)} - ${booking.endTime.format(context)}',
              context,
            ),
            const SizedBox(height: 8),
            // Thông tin thời lượng
            _buildInfoRow(
              Icons.timer,
              'Thời lượng',
              '${booking.duration.inHours} giờ',
              context,
            ),
            const SizedBox(height: 12),
            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.grey.shade300,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Giá tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Giá:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    '${booking.price.toStringAsFixed(0)} VND',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Venue Details Slug: ${widget.slug}");
    return BlocProvider(
      create: (context) => getIt<VenueDetailsBloc>()..add(FetchVenueDetails(widget.slug)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Venue Details'),
        ),
        body: BlocBuilder<VenueDetailsBloc, VenueDetailsState>(
          builder: (context, state) {
            if (state is VenueDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is VenueDetailsLoaded) {
              final details = state.locationDetails;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Placeholder for an image
                    Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(details.name, style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          Text(details.address, style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 16),
                          const Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          if (details.reviews != null && details.reviews!.isNotEmpty)
                            ...details.reviews!.map((review) => ListTile(
                                  title: Text('Rating: ${review.rating}'),
                                  subtitle: Text(review.comment),
                                ))
                          else
                            const Text('No reviews yet.'),
                          const SizedBox(height: 24),
                          const Text('Select Date(s) and Time(s)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            calendarFormat: _calendarFormat,
                            selectedDayPredicate: (day) {
                              // Use _selectedTimeSlots to check if a day has selected times
                              return _selectedTimeSlots.containsKey(day);
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay; // update `_focusedDay` here as well
                              });
                              // Show time slot picker for the selected day
                              _showTimeSlotPicker(context, selectedDay);
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
                          // Display selected dates and times
                          Text(_selectedTimeSlots.isEmpty
                              ? 'No date(s) and time(s) selected'
                              : 'Selected: ${ _selectedTimeSlots.entries.map((entry) {
                                  final date = entry.key.toLocal().toString().split(' ')[0];
                                  final times = entry.value.map((time) => time.format(context)).join(', ');
                                  return '$date ($times)';
                                }).join('; ')}'),
                          const SizedBox(height: 24),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                            if (_selectedTimeSlots.isNotEmpty) {
                              final List<ConsolidatedBooking> bookings = _consolidateBookings(details);
                              double totalAmount = 0.0;
                              for (var booking in bookings) {
                                totalAmount += booking.price;
                              }
                              showDialog(
                                context: context,
                                builder: (context) => BookingSummaryDialog(
                                  bookings: bookings,
                                  totalAmount: totalAmount,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select at least one date and time slot.'),
                                ),
                              );
                            }
                          },
                              child: const Text('Book Now'),
                            ),
                          ),
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
}

class _PageIndicatorDots extends StatefulWidget {
  final int currentPage;
  final int itemCount;
  // Removed activeColor and inactiveColor as they will be hardcoded
  // final Color activeColor;
  // final Color inactiveColor;

  const _PageIndicatorDots({
    Key? key,
    required this.currentPage,
    required this.itemCount,
    // Removed activeColor and inactiveColor from constructor
    // required this.activeColor,
    // required this.inactiveColor,
  }) : super(key: key);

  @override
  State<_PageIndicatorDots> createState() => _PageIndicatorDotsState();
}

class _PageIndicatorDotsState extends State<_PageIndicatorDots> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.itemCount, (index) {
        return Container(
          key: ValueKey('dot_$index'), // Added a ValueKey
          width: widget.currentPage == index ? 10.0 : 8.0,
          height: widget.currentPage == index ? 10.0 : 8.0,
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.currentPage == index
                ? Colors.blue // Hardcoded active color
                : Colors.red, // Hardcoded inactive color
          ),
        );
      }),
    );
  }
}