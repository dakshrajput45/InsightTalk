import 'package:flutter/material.dart';

class TTextFieldFormTheme {
  TTextFieldFormTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorStyle: const TextStyle(color: Colors.white),
    fillColor: Color.fromRGBO(245, 245, 245, 1),
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.grey,
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(10), // Color for enabled state
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.black,
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(10), // Color for focused state
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.red,
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(10), // Color for error state
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.redAccent,
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(10), // Color for focused error state
    ),
  );
}
