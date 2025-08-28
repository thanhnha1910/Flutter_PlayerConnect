import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:player_connect/presentation/screens/explore/venue_details_screen.dart'; // Import ConsolidatedBooking
import '../../data/models/booking_request_model.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../core/di/injection.dart';
import '../screens/booking_receipt/booking_receipt_screen.dart';
import '../widgets/paypal_webview_handler.dart';

class BookingSummaryDialog extends StatefulWidget {
  final List<ConsolidatedBooking> bookings;
  final double totalAmount;

  const BookingSummaryDialog({
    Key? key,
    required this.bookings,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<BookingSummaryDialog> createState() => _BookingSummaryDialogState();
}

class _BookingSummaryDialogState extends State<BookingSummaryDialog>
    with TickerProviderStateMixin {
  CarouselSliderController _carouselController = CarouselSliderController();
  int _currentPage = 0;
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _canScrollPrev = false;
  bool _canScrollNext = false;
  final FocusNode _carouselFocusNode = FocusNode();
  String? _firstBookingId; // Add instance variable for firstBookingId

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    _updateNavigationState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _carouselFocusNode.dispose();
    super.dispose();
  }

  void _updateNavigationState() {
    setState(() {
      _canScrollPrev = _currentPage > 0;
      _canScrollNext = _currentPage < widget.bookings.length - 1;
    });
  }

  void _scrollToPrevious() {
    if (_canScrollPrev) {
      _carouselController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToNext() {
    if (_canScrollNext) {
      _carouselController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _scrollToPrevious();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _scrollToNext();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Booking Summary'),
      content: Container(
        width: 300, // Fixed width for the AlertDialog content
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.bookings.isEmpty)
              const Text('No bookings selected.')
            else if (widget.bookings.length == 1)
              _buildBookingCard(widget.bookings.first, context)
            else
              Column(
                children: [
                  // Enhanced Carousel with Navigation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Focus(
                      focusNode: _carouselFocusNode,
                      onKeyEvent: (node, event) {
                        _handleKeyEvent(event);
                        return KeyEventResult.handled;
                      },
                      child: Semantics(
                        label: 'Booking carousel, ${widget.bookings.length} items',
                        hint: 'Use arrow keys or navigation buttons to browse bookings',
                        child: Stack(
                          children: [
                            LayoutBuilder(
                               builder: (context, constraints) {
                                 // Responsive height based on screen size
                                 double carouselHeight = constraints.maxWidth < 600 ? 200 : 220;
                                 double cardMargin = constraints.maxWidth < 400 ? 2.0 : 5.0;
                                 
                                 return CarouselSlider.builder(
                                   carouselController: _carouselController,
                                   itemCount: widget.bookings.length,
                                   itemBuilder: (context, index, realIndex) {
                                     final isActive = index == _currentPage;
                                     return AnimatedContainer(
                                       duration: const Duration(milliseconds: 400),
                                       curve: Curves.easeOutCubic,
                                       width: MediaQuery.of(context).size.width,
                                       margin: EdgeInsets.symmetric(horizontal: cardMargin),
                                       transform: Matrix4.identity()
                                         ..scale(isActive ? 1.0 : 0.95)
                                         ..translate(0.0, isActive ? 0.0 : 5.0),
                                       child: AnimatedOpacity(
                                         duration: const Duration(milliseconds: 300),
                                         opacity: isActive ? 1.0 : 0.8,
                                         child: _buildBookingCard(widget.bookings[index], context),
                                       ),
                                     );
                                   },
                                   options: CarouselOptions(
                                     height: carouselHeight,
                                     viewportFraction: constraints.maxWidth < 600 ? 0.95 : 1.0,
                                     enableInfiniteScroll: false,
                                     enlargeCenterPage: false,
                                     autoPlay: false,
                                     scrollPhysics: const BouncingScrollPhysics(),
                                     pageSnapping: true,
                                     onPageChanged: (index, reason) {
                                       setState(() {
                                         _currentPage = index;
                                       });
                                       _updateNavigationState();
                                       // Page change handled by carousel
                                     },
                                   ),
                                 );
                               },
                             ),
                            // Previous Button with enhanced animations
                             if (widget.bookings.length > 1)
                               Positioned(
                                 left: -12,
                                 top: 0,
                                 bottom: 0,
                                 child: Center(
                                   child: AnimatedScale(
                                     scale: _canScrollPrev ? 1.0 : 0.8,
                                     duration: const Duration(milliseconds: 300),
                                     curve: Curves.elasticOut,
                                     child: AnimatedOpacity(
                                       opacity: _canScrollPrev ? 1.0 : 0.3,
                                       duration: const Duration(milliseconds: 200),
                                       child: Container(
                                         width: 40,
                                         height: 40,
                                         decoration: BoxDecoration(
                                           color: _canScrollPrev 
                                               ? Theme.of(context).primaryColor
                                               : Colors.grey,
                                           shape: BoxShape.circle,
                                           boxShadow: _canScrollPrev ? [
                                             BoxShadow(
                                               color: Theme.of(context).primaryColor.withOpacity(0.3),
                                               blurRadius: 8,
                                               offset: const Offset(0, 4),
                                               spreadRadius: 1,
                                             ),
                                           ] : [],
                                         ),
                                         child: IconButton(
                                           onPressed: _canScrollPrev ? _scrollToPrevious : null,
                                           icon: AnimatedRotation(
                                             turns: _canScrollPrev ? 0.0 : 0.1,
                                             duration: const Duration(milliseconds: 200),
                                             child: const Icon(
                                               Icons.chevron_left,
                                               color: Colors.white,
                                               size: 24,
                                             ),
                                           ),
                                           tooltip: 'Previous booking',
                                           splashRadius: 20,
                                         ),
                                       ),
                                     ),
                                   ),
                                 ),
                               ),
                            // Next Button with enhanced animations
                             if (widget.bookings.length > 1)
                               Positioned(
                                 right: -12,
                                 top: 0,
                                 bottom: 0,
                                 child: Center(
                                   child: AnimatedScale(
                                     scale: _canScrollNext ? 1.0 : 0.8,
                                     duration: const Duration(milliseconds: 300),
                                     curve: Curves.elasticOut,
                                     child: AnimatedOpacity(
                                       opacity: _canScrollNext ? 1.0 : 0.3,
                                       duration: const Duration(milliseconds: 200),
                                       child: Container(
                                         width: 40,
                                         height: 40,
                                         decoration: BoxDecoration(
                                           color: _canScrollNext 
                                               ? Theme.of(context).primaryColor
                                               : Colors.grey,
                                           shape: BoxShape.circle,
                                           boxShadow: _canScrollNext ? [
                                             BoxShadow(
                                               color: Theme.of(context).primaryColor.withOpacity(0.3),
                                               blurRadius: 8,
                                               offset: const Offset(0, 4),
                                               spreadRadius: 1,
                                             ),
                                           ] : [],
                                         ),
                                         child: IconButton(
                                           onPressed: _canScrollNext ? _scrollToNext : null,
                                           icon: AnimatedRotation(
                                             turns: _canScrollNext ? 0.0 : -0.1,
                                             duration: const Duration(milliseconds: 200),
                                             child: const Icon(
                                               Icons.chevron_right,
                                               color: Colors.white,
                                               size: 24,
                                             ),
                                           ),
                                           tooltip: 'Next booking',
                                           splashRadius: 20,
                                         ),
                                       ),
                                     ),
                                   ),
                                 ),
                               ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Enhanced Carousel indicators with improved design and accessibility
                  if (widget.bookings.length > 1)
                    Semantics(
                      label: 'Booking indicators',
                      hint: 'Tap to navigate to specific booking',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_currentPage + 1} / ${widget.bookings.length}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ...List.generate(widget.bookings.length, (index) {
                            final isActive = _currentPage == index;
                            return GestureDetector(
                              onTap: () {
                                _carouselController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Semantics(
                                label: 'Go to booking ${index + 1}',
                                button: true,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  width: isActive ? 24.0 : 8.0,
                                  height: 8.0,
                                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    color: isActive
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.withOpacity(0.4),
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                ],
              ),
            const Divider(),
            Text(
              'Total: \$${widget.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      )),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleBookingConfirmation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Pay with PayPal'),
        ),
      ],
    );
  }

  Widget _buildBookingCard(ConsolidatedBooking booking, BuildContext context) {
    return SizedBox(
      width: 300, // Fixed width for the card
      height: 180, // Fixed height for the card
      child: Semantics(
        label: 'Booking for ${booking.date.toLocal().toString().split(' ')[0]}',
        hint: 'Time: ${booking.startTime.format(context)} to ${booking.endTime.format(context)}, Price: \$${booking.price.toStringAsFixed(2)}',
        child: Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Date: ${booking.date.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Time: ${booking.startTime.format(context)} - ${booking.endTime.format(context)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Duration: ${booking.duration.inMinutes} minutes',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Price: \$${booking.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleBookingConfirmation() async {
    // Validate bookings before proceeding
    if (!_validateBookings()) {
      return;
    }

    // Check network connectivity
    if (!await _checkNetworkConnectivity()) {
      setState(() {
        _errorMessage = 'No internet connection. Please check your network and try again.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookingRepository = getIt<BookingRepository>();
      
      // Create the first booking to get the real paymentUrl from backend
      final firstBooking = widget.bookings.first;
      final firstBookingRequest = BookingRequestModel(
        fieldId: int.parse(firstBooking.fieldId),
        fromTime: DateTime.utc(
          firstBooking.date.year,
          firstBooking.date.month,
          firstBooking.date.day,
          firstBooking.startTime.hour,
          firstBooking.startTime.minute,
        ),
        toTime: DateTime.utc(
          firstBooking.date.year,
          firstBooking.date.month,
          firstBooking.date.day,
          firstBooking.endTime.hour,
          firstBooking.endTime.minute,
        ),
      );

      // Create the first booking to get paymentUrl
      final firstBookingResult = await bookingRepository.createBooking(firstBookingRequest);
      
      String? paymentUrl;
      
      // Handle the result properly
      final result = firstBookingResult.fold(
        (failure) {
          print('DEBUG: Booking creation failed: ${failure.toString()}');
          setState(() {
            _errorMessage = 'Failed to create booking: ${failure.toString()}';
            _isLoading = false;
          });
          return null; // Return null to indicate failure
        },
        (response) {
          paymentUrl = response.paymentUrl;
          _firstBookingId = response.bookingId.toString(); // Use instance variable
          print('DEBUG: Booking creation successful');
          print('DEBUG: Full response: ${response.toString()}');
          print('DEBUG: Payment URL from backend: $paymentUrl');
          print('DEBUG: Booking ID: $_firstBookingId');
          print('DEBUG: Response status: ${response.status}');
          print('DEBUG: Response message: ${response.message}');
          print('DEBUG: Response requires payment: ${response.requiresPayment}');
          return response; // Return the response
        },
      );

      // If booking creation failed, return early
      if (result == null) {
        return;
      }

      if (paymentUrl == null || paymentUrl!.isEmpty) {
        print('DEBUG: Payment URL is null or empty: $paymentUrl');
        setState(() {
          _errorMessage = 'Failed to get payment URL from server';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });

      print('DEBUG: About to close dialog and navigate to PayPal WebView');
      print('DEBUG: Final payment URL: $paymentUrl');
      
      // Close the current dialog
      Navigator.of(context).pop();
      
      print('DEBUG: Dialog closed, now navigating to PayPal WebView');
      
      // Navigate to PayPal with the real payment URL from backend
      try {
        print('DEBUG: Creating PayPalWebViewHandler with URL: $paymentUrl');
        final result = Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              print('DEBUG: PayPalWebViewHandler builder called');
              return PayPalWebViewHandler(
                paymentUrl: paymentUrl!,
                amount: widget.totalAmount,
                onPaymentSuccess: (paymentId) async {
              // Create remaining bookings after successful payment
              try {
                if (widget.bookings.length > 1) {
                  final remainingBookings = widget.bookings.skip(1).toList();
                  
                  List<BookingRequestModel> remainingBookingRequests = remainingBookings.map((booking) {
                    return BookingRequestModel(
                      fieldId: int.parse(booking.fieldId),
                      fromTime: DateTime.utc(
                        booking.date.year,
                        booking.date.month,
                        booking.date.day,
                        booking.startTime.hour,
                        booking.startTime.minute,
                      ),
                      toTime: DateTime.utc(
                        booking.date.year,
                        booking.date.month,
                        booking.date.day,
                        booking.endTime.hour,
                        booking.endTime.minute,
                      ),
                    );
                  }).toList();

                  // Submit remaining bookings
                  final results = await Future.wait(
                    remainingBookingRequests.map((request) => bookingRepository.createBooking(request))
                  );

                  // Check if all remaining bookings were successful
                  bool allSuccessful = results.every((result) => result.isRight());
                  
                  if (!allSuccessful) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Some bookings failed to create. Please contact support.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
                
                // Navigate to booking receipt with the first booking ID
                if (_firstBookingId != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => BookingReceiptScreen(
                        bookingId: _firstBookingId!,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Payment successful! Booking completed.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment successful but some bookings failed: ${e.toString()}'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            onPaymentError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment failed: $error'),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.of(context).pop();
            },
            onPaymentCancel: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment cancelled'),
                  backgroundColor: Colors.grey,
                ),
              );
              Navigator.of(context).pop();
            },
              );
            },
          ),
        );
        print('DEBUG: Navigation to PayPalWebViewHandler completed');
      } catch (e) {
        print('DEBUG: Error navigating to PayPalWebViewHandler: $e');
        setState(() {
          _errorMessage = 'Failed to open payment page: ${e.toString()}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initiate payment: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  bool _validateBookings() {
    if (widget.bookings.isEmpty) {
      setState(() {
        _errorMessage = 'No bookings selected.';
      });
      return false;
    }
    return true;
  }

  Future<bool> _checkNetworkConnectivity() async {
    // Simple connectivity check - in a real app you might use connectivity_plus package
    try {
      // This is a placeholder - implement actual network check
      return true;
    } catch (e) {
      return false;
    }
  }
}
