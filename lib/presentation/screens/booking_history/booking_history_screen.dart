import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/user/user_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/booking_history_model.dart';
import 'package:intl/intl.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<UserBloc>().add(LoadUserBookings());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Booking History'),
        backgroundColor: AppTheme.primaryAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.upcoming),
              text: 'Sắp tới',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'Đã qua',
            ),
          ],
        ),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state is UserError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    'Error loading booking history',
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    state.message,
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserBloc>().add(LoadUserBookings());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is UserBookingsLoaded) {
            final bookings = state.bookings;
            
            if (bookings.isEmpty) {
              return _buildEmptyState();
            }
            
            // Phân tách bookings thành upcoming và past
            final now = DateTime.now();
            final upcomingBookings = bookings.where((booking) {
              return booking.bookingDate.isAfter(now) || 
                     booking.bookingDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
            }).toList();
            
            final pastBookings = bookings.where((booking) {
              return booking.bookingDate.isBefore(DateTime(now.year, now.month, now.day));
            }).toList();
            
            return TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(upcomingBookings, isUpcoming: true),
                _buildBookingList(pastBookings, isUpcoming: false),
              ],
            );
          }
          
          return const Center(
            child: Text('Loading booking history...'),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Không có lịch sử đặt sân',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Lịch sử đặt sân của bạn sẽ hiển thị ở đây',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<BookingHistoryModel> bookings, {required bool isUpcoming}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.upcoming : Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              isUpcoming ? 'Không có lịch sắp tới' : 'Không có lịch sử',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              isUpcoming 
                  ? 'Bạn chưa có lịch đặt sân nào sắp tới'
                  : 'Bạn chưa có lịch sử đặt sân nào',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserBloc>().add(LoadUserBookings());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking, isUpcoming: isUpcoming);
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingHistoryModel booking, {required bool isUpcoming}) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isUpcoming 
              ? Border.all(color: AppTheme.primaryAccent.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.fieldName,
                      style: AppTheme.headingSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      if (isUpcoming)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'SẮP TỚI',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primaryAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isUpcoming) const SizedBox(width: AppTheme.spacingS),
                      _buildStatusChip(booking.status),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: AppTheme.spacingXS),
                Expanded(
                  child: Text(
                    booking.locationName,
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              children: [
                Icon(
                  Icons.sports_soccer,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: AppTheme.spacingXS),
                Text(
                  booking.sportType ?? 'Unknown Sport',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: AppTheme.spacingXS),
                Text(
                  DateFormat('MMM dd, yyyy').format(booking.bookingDate),
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: AppTheme.spacingXS),
                Text(
                  booking.timeSlot ?? 'Time not available',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${booking.price?.toStringAsFixed(2) ?? '0.00'}',
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.primaryAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (booking.notes != null && booking.notes!.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _showNotesDialog(booking.notes!);
                        },
                        icon: const Icon(Icons.note),
                        iconSize: 20,
                      ),
                    if (isUpcoming && booking.status.toLowerCase() == 'confirmed')
                      TextButton.icon(
                        onPressed: () {
                          _showCancelDialog(booking);
                        },
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('Hủy'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      )
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'confirmed':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case 'cancelled':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      case 'completed':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTheme.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showNotesDialog(String notes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ghi chú đặt sân'),
        content: Text(notes),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BookingHistoryModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đặt sân'),
        content: Text('Bạn có chắc chắn muốn hủy đặt sân "${booking.fieldName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement cancel booking functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng hủy đặt sân sẽ được triển khai sau'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hủy đặt sân'),
          ),
        ],
      ),
    );
  }
}