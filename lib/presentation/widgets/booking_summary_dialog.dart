import 'package:flutter/material.dart';
import 'package:player_connect/presentation/screens/explore/venue_details_screen.dart'; // Import ConsolidatedBooking

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

class _BookingSummaryDialogState extends State<BookingSummaryDialog> {
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
                  SizedBox(
                    height: 200, // Adjust height as needed
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.bookings.length,
                      itemBuilder: (context, index) {
                        return _buildBookingCard(widget.bookings[index], context);
                      },
                    ),
                  ),
                  SizedBox(height: 16), // Spacing between PageView and indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.bookings.length, (index) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            const Divider(),
            Text(
              'Total: \$${widget.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
          onPressed: () {
            // TODO: Implement actual booking confirmation logic
            Navigator.pop(context); // Close dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking confirmed!')),
            );
          },
          child: const Text('Confirm Booking'),
        ),
      ],
    );
  }

  Widget _buildBookingCard(ConsolidatedBooking booking, BuildContext context) {
    print('Building booking card for price: ${booking.price}'); // Debug print
    return SizedBox(
      width: 300, // Fixed width for the card
      height: 180, // Fixed height for the card
      child: Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${booking.date.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Time: ${booking.startTime.format(context)} - ${booking.endTime.format(context)}',
            ),
            SizedBox(height: 8),
            Text(
              'Duration: ${booking.duration.inMinutes} minutes',
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
}
