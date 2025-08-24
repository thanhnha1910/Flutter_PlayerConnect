import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:player_connect/core/di/injection.dart';
import 'package:player_connect/presentation/bloc/booking/booking_bloc.dart';
import 'package:player_connect/presentation/bloc/payment/payment_bloc.dart';
import 'package:player_connect/presentation/bloc/venue_details/venue_details_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../payment/paypalwebview_screen.dart';

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

  ConsolidatedBooking({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.price,
  });
}

class _VenueDetailsScreenState extends State<VenueDetailsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<TimeOfDay>> _selectedTimeSlots = {};
  Map<DateTime, List<TimeOfDay>> _availableTimeSlots = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  static const double _pricePerHalfHour = 10.0;

  List<TimeOfDay> _generateTimeSlots(TimeOfDay open, TimeOfDay close) {
    List<TimeOfDay> slots = [];
    DateTime now = DateTime.now();
    DateTime current = DateTime(now.year, now.month, now.day, open.hour, open.minute);
    DateTime end = DateTime(now.year, now.month, now.day, close.hour, close.minute);

    while (current.isBefore(end)) {
      slots.add(TimeOfDay.fromDateTime(current));
      current = current.add(const Duration(minutes: 30));
    }
    return slots;
  }

  List<ConsolidatedBooking> _consolidateBookings(double pricePerHalfHour) {
    List<ConsolidatedBooking> consolidatedBookings = [];

    _selectedTimeSlots.forEach((date, times) {
      if (times.isEmpty) return;

      // Sort times
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

        // Check if times are consecutive (30 minutes apart)
        if (currentDateTime.difference(previousDateTime).inMinutes == 30) {
          currentGroup.add(currentTime);
        } else {
          // Process the current group and start a new one
          _addBookingFromGroup(consolidatedBookings, date, currentGroup, pricePerHalfHour);
          currentGroup = [currentTime];
        }
      }

      // Process the last group
      _addBookingFromGroup(consolidatedBookings, date, currentGroup, pricePerHalfHour);
    });

    return consolidatedBookings;
  }

  void _addBookingFromGroup(List<ConsolidatedBooking> bookings, DateTime date,
      List<TimeOfDay> group, double pricePerHalfHour) {
    if (group.isEmpty) return;

    final startTime = group.first;
    final endTime = TimeOfDay.fromDateTime(
        DateTime(date.year, date.month, date.day, group.last.hour, group.last.minute)
            .add(const Duration(minutes: 30)));

    final startDateTime = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
    final endDateTime = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
    final duration = endDateTime.difference(startDateTime);
    final numberOfHalfHours = duration.inMinutes / 30;
    final price = numberOfHalfHours * pricePerHalfHour;

    bookings.add(ConsolidatedBooking(
      date: date,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      price: price,
    ));
  }

  Future<void> _showBookingSummaryDialog(BuildContext parentContext, int fieldId,
      String fieldName, double pricePerHalfHour) async {
    final List<ConsolidatedBooking> bookings = _consolidateBookings(pricePerHalfHour);
    double totalAmount = bookings.fold(0.0, (sum, booking) => sum + booking.price);

    if (bookings.isEmpty) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một khung giờ!')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: const Text('Xác nhận đặt sân',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sân: $fieldName',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      if (bookings.length == 1)
                        _buildBookingCard(bookings.first, parentContext, 0)
                      else
                        SizedBox(
                          height: 280,
                          child: CarouselSlider.builder(
                            itemCount: bookings.length,
                            itemBuilder: (BuildContext context, int index, int realIndex) {
                              return _buildBookingCard(bookings[index], parentContext, index);
                            },
                            options: CarouselOptions(
                              height: 280,
                              viewportFraction: 1.0,
                              enableInfiniteScroll: bookings.length > 1,
                              enlargeCenterPage: true,
                            ),
                          ),
                        ),
                      const Divider(thickness: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng cộng:',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('\$${totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(dialogContext, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Xác nhận đặt sân'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && !_isLoading) {
      await _processBookings(parentContext, fieldId, bookings);
    }
  }

  Future<void> _processBookings(BuildContext context, int fieldId,
      List<ConsolidatedBooking> bookings) async {
    setState(() => _isLoading = true);

    try {
      // Create bookings sequentially to avoid conflicts
      for (var booking in bookings) {
        final startDateTime = DateTime(
          booking.date.year,
          booking.date.month,
          booking.date.day,
          booking.startTime.hour,
          booking.startTime.minute,
        );
        final endDateTime = DateTime(
          booking.date.year,
          booking.date.month,
          booking.date.day,
          booking.endTime.hour,
          booking.endTime.minute,
        );

        context.read<BookingBloc>().add(
          CreateBookingEvent(
            fieldId: fieldId,
            startTime: startDateTime,
            endTime: endDateTime,
            totalPrice: booking.price,
            notes: 'Đặt sân qua ứng dụng',
          ),
        );

        // Small delay to prevent overwhelming the server
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showTimeSlotPicker(BuildContext context, DateTime day, List<TimeOfDay> availableSlots) {
    if (availableSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có khung giờ nào khả dụng cho ngày này!')),
      );
      return;
    }

    List<TimeOfDay> tempSelectedTimes = List.from(_selectedTimeSlots[day] ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Chọn khung giờ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Ngày: ${day.day}/${day.month}/${day.year}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        if (tempSelectedTimes.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Đã chọn: ${tempSelectedTimes.length} khung giờ',
                              style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: availableSlots.length,
                      itemBuilder: (context, index) {
                        final time = availableSlots[index];
                        final isSelected = tempSelectedTimes.contains(time);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.green : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: CheckboxListTile(
                            title: Text(
                              time.format(context),
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? Colors.green[700] : null,
                              ),
                            ),
                            subtitle: Text('30 phút - \$${_pricePerHalfHour.toStringAsFixed(2)}'),
                            value: isSelected,
                            activeColor: Colors.green,
                            onChanged: (bool? value) {
                              setModalState(() {
                                if (value == true) {
                                  tempSelectedTimes.add(time);
                                } else {
                                  tempSelectedTimes.remove(time);
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
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

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(tempSelectedTimes.isNotEmpty
                                      ? 'Đã chọn ${tempSelectedTimes.length} khung giờ'
                                      : 'Đã bỏ chọn tất cả khung giờ'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(tempSelectedTimes.isNotEmpty
                                ? 'Xác nhận (${tempSelectedTimes.length})'
                                : 'Xác nhận'),
                          ),
                        ),
                      ],
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '\$${booking.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              _buildInfoRow(Icons.calendar_today, 'Ngày',
                  '${booking.date.day}/${booking.date.month}/${booking.date.year}'),
              _buildInfoRow(Icons.access_time, 'Giờ bắt đầu',
                  booking.startTime.format(context)),
              _buildInfoRow(Icons.access_time_outlined, 'Giờ kết thúc',
                  booking.endTime.format(context)),
              _buildInfoRow(Icons.timer, 'Thời lượng',
                  '${booking.duration.inMinutes} phút'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTimeSlotsDisplay() {
    if (_selectedTimeSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey),
            SizedBox(width: 8),
            Text('Chưa chọn ngày và giờ nào'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Khung giờ đã chọn:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ..._selectedTimeSlots.entries.map((entry) {
          final date = entry.key;
          final times = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: times.map((time) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      time.format(context),
                      style: TextStyle(fontSize: 12, color: Colors.green[700]),
                    ),
                  )).toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<VenueDetailsBloc>()..add(FetchVenueDetails(widget.slug)),
        ),
        BlocProvider(
          create: (context) => getIt<BookingBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<PaymentBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết sân'),
          elevation: 0,
        ),
        body: BlocListener<BookingBloc, BookingState>(
          listener: (context, bookingState) {
            if (bookingState is BookingCreated) {
              // Initiate payment after successful booking
              context.read<PaymentBloc>().add(
                InitiatePaymentEvent(
                  payableId: bookingState.booking.id,
                  payableType: "BOOKING",
                  amount: bookingState.booking.totalPrice.toInt(),
                ),
              );
            } else if (bookingState is BookingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi đặt sân: ${bookingState.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocListener<PaymentBloc, PaymentState>(
            listener: (context, paymentState) async {
              if (paymentState is PaymentInitiated) {
                // Navigate to PayPal WebView
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PayPalWebViewScreen(
                      approvalUrl: paymentState.approvalUrl,
                      returnUrl: "http://localhost:1444/api/payment/success",
                    ),
                  ),
                );

                if (result == true) {
                  // Check payment status after return
                  context.read<PaymentBloc>().add(
                    GetPaymentStatusEvent(paymentState.paymentId),
                  );
                }
              } else if (paymentState is PaymentStatusLoaded) {
                final isSuccess = paymentState.payment.status.toLowerCase() == 'success';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isSuccess
                        ? 'Thanh toán thành công: \$${paymentState.payment.total}'
                        : 'Thanh toán ${paymentState.payment.status}: \$${paymentState.payment.total}'),
                    backgroundColor: isSuccess ? Colors.green : Colors.orange,
                  ),
                );

                if (isSuccess) {
                  // Clear selected time slots after successful payment
                  setState(() {
                    _selectedTimeSlots.clear();
                  });
                }
              } else if (paymentState is PaymentFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi thanh toán: ${paymentState.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<VenueDetailsBloc, VenueDetailsState>(
              builder: (context, state) {
                if (state is VenueDetailsLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Đang tải thông tin sân...'),
                      ],
                    ),
                  );
                } else if (state is VenueDetailsLoaded) {
                  final details = state.locationDetails;
                  final fieldId = details.fields?.isNotEmpty == true ? details.fields![0].id : 0;
                  final fieldName = details.name;
                  final pricePerHalfHour = details.fields?.isNotEmpty == true
                      ? details.fields![0].pricePerHour / 2
                      : _pricePerHalfHour;

                  if (fieldId == 0 || details.fields == null || details.fields!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Không có sân nào khả dụng tại địa điểm này.'),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Venue Image
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.green[400]!, Colors.green[600]!],
                            ),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sports_soccer, size: 60, color: Colors.white),
                                SizedBox(height: 8),
                                Text(
                                  'Hình ảnh sân',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Venue Info
                              Text(details.name,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(details.address,
                                        style: Theme.of(context).textTheme.bodyLarge),
                                  ),
                                ],
                              ),

                              // Price Info
                              if (details.fields?.isNotEmpty == true)
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.attach_money, color: Colors.green),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Giá: \$${pricePerHalfHour.toStringAsFixed(2)}/30 phút',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const Divider(),

                              // Reviews Section
                              const Text('Đánh giá',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              if (details.reviews != null && details.reviews!.isNotEmpty)
                                ...details.reviews!.map((review) => Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ...List.generate(5, (index) => Icon(
                                            index < review.rating ? Icons.star : Icons.star_border,
                                            color: Colors.amber,
                                            size: 16,
                                          )),
                                          const SizedBox(width: 8),
                                          Text('${review.rating}/5'),
                                        ],
                                      ),
                                      if (review.comment.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(review.comment),
                                        ),
                                    ],
                                  ),
                                ))
                              else
                                const Text('Chưa có đánh giá nào.'),

                              const SizedBox(height: 20),

                              // Calendar Section
                              const Text('Chọn ngày và giờ',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),

                              // Calendar Widget
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TableCalendar(
                                  firstDay: DateTime.now(),
                                  lastDay: DateTime.now().add(const Duration(days: 30)),
                                  focusedDay: _focusedDay,
                                  calendarFormat: _calendarFormat,
                                  selectedDayPredicate: (day) {
                                    return isSameDay(_selectedDay, day);
                                  },
                                  onDaySelected: (selectedDay, focusedDay) {
                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay = focusedDay;
                                    });

                                    // Generate available time slots for the selected day
                                    final availableSlots = _generateTimeSlots(
                                      const TimeOfDay(hour: 6, minute: 0),
                                      const TimeOfDay(hour: 22, minute: 0),
                                    );
                                    _availableTimeSlots[selectedDay] = availableSlots;

                                    // Show time slot picker
                                    _showTimeSlotPicker(context, selectedDay, availableSlots);
                                  },
                                  onFormatChanged: (format) {
                                    setState(() {
                                      _calendarFormat = format;
                                    });
                                  },
                                  onPageChanged: (focusedDay) {
                                    _focusedDay = focusedDay;
                                  },
                                  calendarStyle: CalendarStyle(
                                    outsideDaysVisible: false,
                                    weekendTextStyle: const TextStyle(color: Colors.red),
                                    selectedDecoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    todayDecoration: BoxDecoration(
                                      color: Colors.green[200],
                                      shape: BoxShape.circle,
                                    ),
                                    markerDecoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  headerStyle: const HeaderStyle(
                                    formatButtonVisible: true,
                                    titleCentered: true,
                                    formatButtonShowsNext: false,
                                    formatButtonDecoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                    ),
                                    formatButtonTextStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  eventLoader: (day) {
                                    return _selectedTimeSlots[day] ?? [];
                                  },
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Selected time slots display
                              _buildSelectedTimeSlotsDisplay(),

                              const SizedBox(height: 20),

                              // Book button
                              if (_selectedTimeSlots.isNotEmpty)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : () {
                                      _showBookingSummaryDialog(
                                        context,
                                        fieldId,
                                        fieldName,
                                        pricePerHalfHour,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                        : const Text(
                                      'Đặt sân ngay',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is VenueDetailsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Lỗi: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<VenueDetailsBloc>().add(
                              FetchVenueDetails(widget.slug),
                            );
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Text('Không có dữ liệu'),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}