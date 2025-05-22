import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/vnpay_service.dart';
import '../config/vnpay_config.dart';

class VNPayWebView extends StatefulWidget {
  final String paymentUrl;

  const VNPayWebView({Key? key, required this.paymentUrl}) : super(key: key);

  @override
  State<VNPayWebView> createState() => _VNPayWebViewState();
}

class _VNPayWebViewState extends State<VNPayWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  final String _returnUrl = VNPayConfig.returnUrl;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Navigating to: ${request.url}');
            // Kiểm tra URL return từ VNPay
            if (request.url.startsWith(_returnUrl)) {
              print('Return URL detected: ${request.url}');
              final status = VNPayService.getResponseStatus(request.url);
              print('Payment status: $status');
              Navigator.pop(context, status);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, 'cancelled');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toán VNPay'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, 'cancelled'),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
