import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../data/models/booking_request_model.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../core/di/injection.dart';

class PayPalWebViewHandler extends StatefulWidget {
  final String? paymentUrl;
  final double? amount;
  final Function(String paymentId) onPaymentSuccess;
  final Function(String error) onPaymentError;
  final VoidCallback? onPaymentCancel;

  const PayPalWebViewHandler({
    Key? key,
    this.paymentUrl,
    this.amount,
    required this.onPaymentSuccess,
    required this.onPaymentError,
    this.onPaymentCancel,
  }) : super(key: key);

  @override
  State<PayPalWebViewHandler> createState() => _PayPalWebViewHandlerState();
}

class _PayPalWebViewHandlerState extends State<PayPalWebViewHandler> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('DEBUG: PayPalWebViewHandler initState called');
    print('DEBUG: Payment URL received: ${widget.paymentUrl}');
    _initializeWebView();
  }

  void _initializeWebView() {
    // Use provided paymentUrl or generate demo URL with amount
    final urlToLoad = widget.paymentUrl ?? _generatePayPalUrl();

    print('DEBUG: Initializing WebView with URL: $urlToLoad');
    print('DEBUG: Creating WebViewController...');

    if (urlToLoad.isEmpty) {
      print('DEBUG: ERROR - URL is empty!');
      setState(() {
        _errorMessage = 'Payment URL is empty';
        _isLoading = false;
      });
      return;
    }

    // Only initialize if not already initialized
    if (_controller == null) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'FlutterPayment',
          onMessageReceived: (JavaScriptMessage message) {
            print('DEBUG: JavaScript message received: ${message.message}');
            try {
              final data = json.decode(message.message);
              if (data['status'] == 'success') {
                String finalPaymentId =
                    data['paymentId'] ??
                    data['token'] ??
                    'FLUTTER_PAYMENT_${DateTime.now().millisecondsSinceEpoch}';
                _handlePaymentSuccess('flutter_callback', finalPaymentId);
              } else if (data['status'] == 'error') {
                String errorMessage = data['message'] ?? 'Payment failed';
                widget.onPaymentError(errorMessage);
                Navigator.pop(context);
              }
            } catch (e) {
              print('DEBUG: Error parsing JavaScript message: $e');
            }
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (progress == 100) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onPageStarted: (String url) {
              print('DEBUG: Page started loading: $url'); // Debug log
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (String url) {
              print('DEBUG: Page finished loading: $url'); // Debug log
              setState(() {
                _isLoading = false;
              });

              // Check for Flutter callback pages and extract JavaScript data
              if (url.contains('192.168.6.156:1444/api/payment/flutter/')) {
                print(
                  'DEBUG: Flutter callback page detected, checking for JavaScript data',
                );
                _controller!.runJavaScript('''
                if (window.flutterPaymentResult) {
                  FlutterPayment.postMessage(JSON.stringify(window.flutterPaymentResult));
                }
                ''');
              }

              // Handle custom scheme URLs that might not trigger onNavigationRequest
              if (url.startsWith('playerconnect://')) {
                print(
                  'DEBUG: Handling custom scheme URL in onPageFinished: $url',
                );
                _handleUrlChange(url);
              }
            },
            onWebResourceError: (WebResourceError error) {
              print(
                'DEBUG: Web resource error: ${error.description}',
              ); // Debug log
              setState(() {
                _isLoading = false;
                _errorMessage =
                    'Failed to load payment page: ${error.description}';
              });
            },
            onNavigationRequest: (NavigationRequest request) {
              print(
                'DEBUG: Navigation request to: ${request.url}',
              ); // Debug log
              _handleUrlChange(request.url);
              return NavigationDecision.navigate;
            },
          ),
        );

      print('DEBUG: WebViewController created successfully');
      print('DEBUG: Loading URL: $urlToLoad');

      try {
        _controller!.loadRequest(Uri.parse(urlToLoad));
        print('DEBUG: loadRequest called successfully');
      } catch (e) {
        print('DEBUG: Error loading URL: $e');
        setState(() {
          _errorMessage = 'Failed to load payment URL: $e';
          _isLoading = false;
        });
      }
    }
  }

  String _generatePayPalUrl() {
    // This is a simplified PayPal URL generation for fallback
    // In a real app, you should always use paymentUrl from backend
    final amount = widget.amount ?? 0.0;
    return 'https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=DEMO_TOKEN&amount=$amount';
  }

  void _handleUrlChange(String url) {
    print('DEBUG: Handling URL change: $url'); // Debug log

    // Check for Flutter HTTP callback success patterns
    if (url.contains('192.168.6.156:1444/api/payment/flutter/success')) {
      print('DEBUG: Flutter HTTP success callback detected'); // Debug log

      // Extract parameters from URL
      try {
        Uri uri = Uri.parse(url);
        String? bookingId = uri.queryParameters['bookingId'];
        String? tournamentId = uri.queryParameters['tournamentId'];
        String? paymentId = uri.queryParameters['paymentId'];
        String? token = uri.queryParameters['token'];
        String? payerID = uri.queryParameters['PayerID'];
        String? type = uri.queryParameters['type'];

        print(
          'DEBUG: Payment success details - type: $type, bookingId: $bookingId, tournamentId: $tournamentId, paymentId: $paymentId, token: $token, payerID: $payerID',
        );

        // Use paymentId or token as the payment identifier
        String finalPaymentId =
            paymentId ??
            token ??
            'FLUTTER_PAYMENT_${DateTime.now().millisecondsSinceEpoch}';
        _handlePaymentSuccess(url, finalPaymentId);
      } catch (e) {
        print('DEBUG: Error parsing HTTP callback URL: $e');
        widget.onPaymentError('Error processing payment callback: $e');
        Navigator.pop(context);
      }
      return;
    }

    // Check for Flutter HTTP callback error patterns
    if (url.contains('192.168.6.156:1444/api/payment/flutter/error')) {
      print('DEBUG: Flutter HTTP error callback detected'); // Debug log

      try {
        Uri uri = Uri.parse(url);
        String? error = uri.queryParameters['error'];
        String? message = uri.queryParameters['message'];

        print(
          'DEBUG: Payment error details - error: $error, message: $message',
        );

        String errorMessage = message?.replaceAll('-', ' ') ?? 'Payment failed';
        widget.onPaymentError(errorMessage);
        Navigator.pop(context);
      } catch (e) {
        print('DEBUG: Error parsing error URL: $e');
        widget.onPaymentError('Payment failed');
        Navigator.pop(context);
      }
      return;
    }

    // Check for Flutter custom scheme success patterns (legacy support)
    if (url.startsWith('playerconnect://payment/success')) {
      print(
        'DEBUG: Flutter custom scheme success pattern matched (legacy)',
      ); // Debug log

      // Extract parameters from URL
      try {
        Uri uri = Uri.parse(url);
        String? bookingId = uri.queryParameters['bookingId'];
        String? tournamentId = uri.queryParameters['tournamentId'];
        String? paymentId = uri.queryParameters['paymentId'];
        String? token = uri.queryParameters['token'];
        String? payerID = uri.queryParameters['PayerID'];

        print(
          'DEBUG: Payment success details - bookingId: $bookingId, tournamentId: $tournamentId, paymentId: $paymentId, token: $token, payerID: $payerID',
        );

        // Use paymentId or token as the payment identifier
        String finalPaymentId =
            paymentId ??
            token ??
            'FLUTTER_PAYMENT_${DateTime.now().millisecondsSinceEpoch}';
        _handlePaymentSuccess(url, finalPaymentId);
      } catch (e) {
        print('DEBUG: Error parsing custom scheme URL: $e');
        widget.onPaymentError('Error processing payment callback: $e');
        Navigator.pop(context);
      }
      return;
    }

    // Check for Flutter custom scheme error patterns (legacy support)
    if (url.startsWith('playerconnect://payment/error')) {
      print(
        'DEBUG: Flutter custom scheme error pattern matched (legacy)',
      ); // Debug log

      try {
        Uri uri = Uri.parse(url);
        String? error = uri.queryParameters['error'];
        String? message = uri.queryParameters['message'];

        print(
          'DEBUG: Payment error details - error: $error, message: $message',
        );

        String errorMessage = message?.replaceAll('-', ' ') ?? 'Payment failed';
        widget.onPaymentError(errorMessage);
        Navigator.pop(context);
      } catch (e) {
        print('DEBUG: Error parsing error URL: $e');
        widget.onPaymentError('Payment failed');
        Navigator.pop(context);
      }
      return;
    }

    // Check for web frontend success patterns (fallback)
    if (url.contains('/booking/receipt/') && url.contains('status=success')) {
      print('DEBUG: Web frontend booking success pattern matched'); // Debug log
      _handlePaymentSuccess(url);
    } else if (url.contains('/tournament/receipt/') &&
        url.contains('status=success')) {
      print(
        'DEBUG: Web frontend tournament success pattern matched',
      ); // Debug log
      _handlePaymentSuccess(url);
    } else if (url.contains('/payment/cancel') ||
        url.contains('cancel=true') ||
        url.contains('status=cancel')) {
      print('DEBUG: Cancel pattern matched'); // Debug log
      _handlePaymentCancel();
    } else if (url.contains('/payment/error') ||
        url.contains('error=true') ||
        url.contains('status=error')) {
      print('DEBUG: Error pattern matched'); // Debug log
      _handlePaymentError();
    } else {
      print('DEBUG: No pattern matched for URL: $url'); // Debug log
    }
  }

  Future<void> _handlePaymentSuccess(
    String url, [
    String? providedPaymentId,
  ]) async {
    try {
      String paymentId;

      if (providedPaymentId != null) {
        // Use the provided payment ID from custom scheme
        paymentId = providedPaymentId;
      } else {
        // Extract payment details from URL parameters (fallback for web patterns)
        final uri = Uri.parse(url);
        paymentId =
            uri.queryParameters['paymentId'] ??
            uri.queryParameters['token'] ??
            'DEMO_PAYMENT_${DateTime.now().millisecondsSinceEpoch}';
      }

      print('DEBUG: Processing payment success with paymentId: $paymentId');

      // Call the success callback
      widget.onPaymentSuccess(paymentId);

      // Note: Don't call Navigator.pop() here as the success callback
      // will handle navigation (e.g., to receipt screen)
    } catch (e) {
      print('DEBUG: Error in _handlePaymentSuccess: $e');
      widget.onPaymentError('Error processing payment: $e');
      Navigator.pop(context);
    }
  }

  void _handlePaymentCancel() {
    if (widget.onPaymentCancel != null) {
      widget.onPaymentCancel!();
    }
    Navigator.pop(context);
  }

  void _handlePaymentError() {
    widget.onPaymentError('Payment failed. Please try again.');
    Navigator.pop(context);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              widget.onPaymentError(message);
              Navigator.pop(context); // Close WebView
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPal Payment'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (widget.onPaymentCancel != null) {
              widget.onPaymentCancel!();
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                        _controller =
                            null; // Reset controller before reinitializing
                      });
                      _initializeWebView();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_controller != null)
            WebViewWidget(controller: _controller!),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
