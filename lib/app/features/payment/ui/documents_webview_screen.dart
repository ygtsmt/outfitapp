// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/generated/l10n.dart';

class DocumentsWebViewScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;
  const DocumentsWebViewScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<DocumentsWebViewScreen> createState() => _DocumentsWebViewScreenState();
}

class _DocumentsWebViewScreenState extends State<DocumentsWebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              hasError = true;
              errorMessage = error.description;
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_getPdfUrl()));
  }

  String _getPdfUrl() {
    // Ensure the URL is properly formatted for PDF viewing
    String url = widget.pdfUrl;

    // If it's a direct PDF URL, wrap it in a Google Docs viewer for better compatibility
    if (url.toLowerCase().endsWith('.pdf')) {
      // Use Google Docs viewer for better PDF compatibility
      return 'https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}&embedded=true';
    }

    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading)
              Container(
                color: context.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: context.baseColor,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppLocalizations.of(context).loadingPdf,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.gray3,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            if (hasError)
              Container(
                color: context.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.h,
                        color: context.red,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppLocalizations.of(context).errorLoadingPdf,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        errorMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            hasError = false;
                            isLoading = true;
                          });
                          controller.reload();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.baseColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(AppLocalizations.of(context).retry),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
