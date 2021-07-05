import 'package:flutter/material.dart';

extension ThemeExtension on ThemeData {
  TextStyle chipTextStyle({@required bool selected}) => TextStyle(
        color: selected
            ? brightness == Brightness.light
                ? accentColor
                : Colors.white
            : textTheme.bodyText2.color,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      );

  Color get formIconColor {
    switch (brightness) {
      case Brightness.dark:
        return Colors.white70;
      case Brightness.light:
        return Colors.black45;
      default:
        return iconTheme.color;
    }
  }
}
