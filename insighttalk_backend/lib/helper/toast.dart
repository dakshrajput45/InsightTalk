import 'package:flutter/material.dart';

class DsdToastMessages {
  static success(BuildContext context, {required String text}) {
    var snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(
        text,
      ),
      showCloseIcon: true,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Text capitaliseText({required String text}) {
    return Text(text.substring(0, 1).toUpperCase() + text.substring(1));
  }
}