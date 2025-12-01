import 'package:flutter/material.dart';

class CustomProgressDialog {
  final BuildContext context;
  bool _isShowing = false;

  CustomProgressDialog(this.context);

  void show() {
    if (!_isShowing) {
      _isShowing = true;
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  void close() {
    if (_isShowing) {
      _isShowing = false;
      Navigator.of(context).pop();
    }
  }
}
