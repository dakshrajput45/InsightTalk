// theme.dart
import 'package:flutter/material.dart';
import 'package:insighttalk_frontend/themes/widgets_theme/text_form_field_widget.dart';

final ThemeData appTheme = ThemeData(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0)),
      backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF2C98F0)),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  ),
  inputDecorationTheme: TTextFieldFormTheme.lightInputDecorationTheme,
  useMaterial3: false,
);
