import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/booking_receipt_model.dart';
import '../../../data/repositories/booking_repository_impl.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/ai_recommendation_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/ai_recommendation/find_teammates_prompt.dart';
import '../../widgets/ai_recommendation/create_open_match_modal.dart';

class BookingReceiptScreen extends StatefulWidget {
  final String bookingId;

  const BookingReceiptScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<BookingReceiptScreen> createState() => _BookingReceiptScreenState();
}

class _BookingReceiptScreenState extends State<BookingReceiptScreen> {
  dynamic _bookingData;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isBatch = false;
  int _recommendedCount = 0;
  bool _hasOpenMatch = false;
  int? _openMatchId;
  List<dynamic> _recommendedPlayers = [];
  bool _isLoadingRecommendations = false;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    try {
      final bookingRepository = getIt<BookingRepository>();
      final result = await bookingRepository.getBookingDetails(widget.bookingId);
      
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = failure.message;
            });
          }
        },
        (bookingData) async {
          // Fetch recommended count for both single and batch bookings
          int recommendedCount = 0;
          String bookingIdForRecommendation = widget.bookingId;
          
          if (bookingData is BookingReceiptModel) {
            // For single booking, use the booking ID directly
            bookingIdForRecommendation = widget.bookingId;
          } else if (bookingData is BatchBookingReceiptModel && bookingData.bookings.isNotEmpty) {
            // For batch booking, use the first booking ID for recommendation
            bookingIdForRecommendation = bookingData.bookings.first.id.toString();
          }
          
          try {
            final aiService = getIt<AIRecommendationService>();
            
            // Auto-fetch recommendations data like FE does with useSWR
            setState(() {
              _isLoadingRecommendations = true;
            });
            
            final recommendationsResponse = await aiService.getTeammateRecommendations(bookingIdForRecommendation);
            recommendedCount = recommendationsResponse.recommendedPlayers.length;
            
            // Check if open match exists by getting open matches and filtering by bookingId
            bool hasOpenMatch = false;
            int? openMatchId;
            try {
              final openMatches = await aiService.getOpenMatches();
              // Convert bookingIdForRecommendation to int for comparison since match.bookingId is int?
              final bookingIdInt = int.tryParse(bookingIdForRecommendation);
              final matchingOpenMatch = openMatches.where((match) => match.bookingId == bookingIdInt).firstOrNull;
              hasOpenMatch = matchingOpenMatch != null;
              openMatchId = matchingOpenMatch?.id;
            } catch (e) {
              // If we can't get open matches, assume no open match exists
              hasOpenMatch = false;
              openMatchId = null;
            }
            
            if (mounted) {
              setState(() {
                _hasOpenMatch = hasOpenMatch;
                _openMatchId = openMatchId;
                _recommendedPlayers = recommendationsResponse.recommendedPlayers;
                _isLoadingRecommendations = false;
              });
            }
          } catch (e) {
            // Silently handle error, keep recommendedCount as 0
            print('Failed to fetch recommendations: $e');
            if (mounted) {
              setState(() {
                _isLoadingRecommendations = false;
              });
            }
          }
          
          if (mounted) {
            setState(() {
              _isLoading = false;
              _bookingData = bookingData;
              _isBatch = bookingData is BatchBookingReceiptModel;
              _recommendedCount = recommendedCount;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load booking details: $e';
        });
      }
    }
  }

  Future<void> _refreshRecommendedCount() async {
    String bookingIdForRecommendation = widget.bookingId;
    
    if (_bookingData is BookingReceiptModel) {
      bookingIdForRecommendation = widget.bookingId;
    } else if (_bookingData is BatchBookingReceiptModel && (_bookingData as BatchBookingReceiptModel).bookings.isNotEmpty) {
      bookingIdForRecommendation = (_bookingData as BatchBookingReceiptModel).bookings.first.id.toString();
    }
    
    try {
      final aiService = getIt<AIRecommendationService>();
      
      // Fetch full recommendations data like in initState
      setState(() {
        _isLoadingRecommendations = true;
      });
      
      final recommendationsResponse = await aiService.getTeammateRecommendations(bookingIdForRecommendation);
      final recommendedCount = recommendationsResponse.recommendedPlayers.length;
      
      // Also refresh hasOpenMatch status and openMatchId
      bool hasOpenMatch = false;
      int? openMatchId;
      try {
        final openMatches = await aiService.getOpenMatches();
        // Convert bookingIdForRecommendation to int for comparison since match.bookingId is int?
        final bookingIdInt = int.tryParse(bookingIdForRecommendation);
        final matchingOpenMatch = openMatches.where((match) => match.bookingId == bookingIdInt).firstOrNull;
        hasOpenMatch = matchingOpenMatch != null;
        openMatchId = matchingOpenMatch?.id;
      } catch (e) {
        hasOpenMatch = false;
        openMatchId = null;
      }
      
      if (mounted) {
        setState(() {
          _recommendedCount = recommendedCount;
          _hasOpenMatch = hasOpenMatch;
          _openMatchId = openMatchId;
          _recommendedPlayers = recommendationsResponse.recommendedPlayers;
          _isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      print('Failed to refresh recommendations: $e');
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
      }
    }
  }

  void _showCreateOpenMatchModal(BookingReceiptModel booking) {
    // Convert BookingReceiptModel to BookingModel for the modal
    final bookingModel = BookingModel(
      id: booking.id,
      fieldId: booking.fieldId ?? 0, // Provide default if null
      fieldName: booking.fieldName ?? 'Unknown Field',
      startTime: booking.startTime,
      endTime: booking.endTime,
      totalPrice: booking.totalPrice ?? 0.0,
      status: booking.status,
      createdAt: DateTime.now(), // Use current time as fallback
      updatedAt: DateTime.now(),
    );
    
    showDialog(
      context: context,
      builder: (context) => CreateOpenMatchModal(
        bookingDetails: bookingModel,
        onSuccess: (openMatch) {
          // Refresh recommended count after creating open match
          _refreshRecommendedCount();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Booking Receipt'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildReceiptView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadBookingDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptView() {
    if (_bookingData == null) {
      return const Center(child: Text('No booking data available'));
    }

    if (_isBatch) {
      return _buildBatchReceiptView(_bookingData as BatchBookingReceiptModel);
    } else {
      return _buildSingleReceiptView(_bookingData as BookingReceiptModel);
    }
  }

  Widget _buildBatchReceiptView(BatchBookingReceiptModel batchBooking) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Batch Booking Confirmed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${batchBooking.totalBookings} bookings confirmed',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Batch Summary Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Batch Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Total Bookings', '${batchBooking.totalBookings}'),
                  _buildDetailRow('Field', batchBooking.bookings.first.fieldName ?? 'N/A'),
                  _buildDetailRow('Location', batchBooking.bookings.first.locationName ?? 'N/A'),
                  const Divider(height: 24),
                  _buildDetailRow(
                    'Total Amount',
                    '\$${batchBooking.totalAmount.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Individual Bookings
          const Text(
            'Individual Bookings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...batchBooking.bookings.map((booking) => _buildBookingCard(booking)).toList(),
          
          const SizedBox(height: 24),
          
          // Find Teammates Prompt for batch booking with Refresh Button
          if (batchBooking.bookings.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Find Teammates',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _isLoadingRecommendations ? null : _refreshRecommendedCount,
                      icon: _isLoadingRecommendations 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      tooltip: 'Refresh recommendations',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FindTeammatesPrompt(
                  bookingId: batchBooking.bookings.first.id.toString(),
                  recommendedCount: _recommendedCount,
                  hasOpenMatch: _hasOpenMatch,
                  openMatchId: _openMatchId?.toString(),
                  recommendedPlayers: _recommendedPlayers,
                  isLoadingRecommendations: _isLoadingRecommendations,
                  onCreateOpenMatch: () => _showCreateOpenMatchModal(batchBooking.bookings.first),
                  onOpenMatchCreated: _refreshRecommendedCount,
                ),
              ],
            ),
          
          const SizedBox(height: 32),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSingleReceiptView(BookingReceiptModel booking) {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Booking Confirmed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Booking ID: ${booking.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Booking Details Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Field', booking.fieldName ?? 'N/A'),
                  _buildDetailRow('Date', _formatDate(booking.startTime)),
                  _buildDetailRow('Time', booking.timeRange),
                  _buildDetailRow('Duration', '${booking.duration.inMinutes} minutes'),
                  _buildDetailRow('Status', booking.statusDisplay),
                  const Divider(height: 24),
                  _buildDetailRow(
                    'Total Amount',
                    '\$${(booking.totalPrice ?? 0.0).toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Payment Information Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Payment Method', 'PayPal'),
                  _buildDetailRow('Payment Status', 'Completed'),
                  _buildDetailRow('Transaction Date', _formatDateTime(booking.startTime)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Find Teammates Prompt with Refresh Button
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Find Teammates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoadingRecommendations ? null : _refreshRecommendedCount,
                    icon: _isLoadingRecommendations 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    tooltip: 'Refresh recommendations',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FindTeammatesPrompt(
                bookingId: widget.bookingId,
                recommendedCount: _recommendedCount,
                hasOpenMatch: _hasOpenMatch,
                openMatchId: _openMatchId?.toString(),
                recommendedPlayers: _recommendedPlayers,
                isLoadingRecommendations: _isLoadingRecommendations,
                onCreateOpenMatch: () => _showCreateOpenMatchModal(booking),
                onOpenMatchCreated: _refreshRecommendedCount,
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Action Buttons
          _buildActionButtons(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.green[700] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('EEEE, MMMM d, yyyy').format(dateTime);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(dateTime);
  }

  Widget _buildBookingCard(BookingReceiptModel booking) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Booking Confirmed',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Booking ID: ${booking.id}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon')),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            label: const Text('Back to Home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}