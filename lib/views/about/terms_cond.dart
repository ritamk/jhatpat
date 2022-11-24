import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: WebView(
          initialUrl: "https://jhatpat.app/terms-condition",
          zoomEnabled: false,
          // onPageFinished: (String text) =>
          //     setState(() => _loading = false),
          // onWebResourceError: (WebResourceError error) =>
          //     setState(() => _error = true),
        ),
      ),
    );
  }
}
