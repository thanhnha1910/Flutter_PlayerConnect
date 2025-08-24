// presentation/screens/payment/paypalwebview_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

class PayPalWebViewScreen extends StatefulWidget {
  final String approvalUrl;
  final String returnUrl;

  const PayPalWebViewScreen({
    super.key,
    required this.approvalUrl,
    required this.returnUrl,
  });

  @override
  State<PayPalWebViewScreen> createState() => _PayPalWebViewScreenState();
}

class _PayPalWebViewScreenState extends State<PayPalWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('PayPal WebView - Page started loading: $url');

            // Check if user returned from PayPal
            if (url.startsWith(widget.returnUrl)) {
              print('PayPal WebView - Success return URL detected');
              Navigator.pop(context, true);
              return;
            }

            // Check if user cancelled
            if (url.contains("cancel") || url.contains("cancelled")) {
              print('PayPal WebView - Cancel URL detected');
              Navigator.pop(context, false);
              return;
            }

            // Handle other PayPal callback URLs
            if (url.contains("paypal.com/checkoutnow/error")) {
              print('PayPal WebView - Error URL detected');
              setState(() {
                _errorMessage = 'Có lỗi xảy ra trong quá trình thanh toán';
              });
              Navigator.pop(context, false);
              return;
            }
          },
          onPageFinished: (String url) {
            print('PayPal WebView - Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('PayPal WebView - Resource error: ${error.description}');
            setState(() {
              _errorMessage = 'Lỗi tải trang: ${error.description}';
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            print('PayPal WebView - Navigation request: ${request.url}');

            // Allow all PayPal domains
            if (request.url.contains('paypal.com') ||
                request.url.contains('paypalobjects.com') ||
                request.url.startsWith(widget.returnUrl)) {
              return NavigationDecision.navigate;
            }

            // Block other external links
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  void _handleRefresh() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _controller.reload();
  }

  void _handleCancel() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hủy thanh toán'),
          content: const Text('Bạn có chắc chắn muốn hủy thanh toán không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, false); // Close webview with cancelled result
              },
              child: const Text('Có', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán PayPal"),
        backgroundColor: const Color(0xFF003087), // PayPal blue
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _handleCancel,
        ),
        actions: [
          if (_errorMessage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _handleRefresh,
              tooltip: 'Tải lại',
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          if (_isLoading)
            Container(
              height: 4,
              child: const LinearProgressIndicator(
                backgroundColor: Color(0xFF003087),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF009CDE)),
              ),
            ),

          // Error message
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: _handleRefresh,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),

          // WebView
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),

                // Loading overlay
                if (_isLoading)
                  Container(
                    color: Colors.white,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003087)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Đang tải PayPal...',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Vui lòng đợi trong giây lát',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom info bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Thanh toán được bảo mật bởi PayPal',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: _handleCancel,
                  child: const Text('Hủy', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}