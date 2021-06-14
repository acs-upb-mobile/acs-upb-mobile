import 'package:flutter/material.dart';

Color primaryColor = const Color(0xFF4DB5E4);
Color accentColor = const Color(0xFF43ACCD);

var lightThemeData = ThemeData(
  brightness: Brightness.light,
  accentColor: accentColor,
// The following two lines are meant to remove the splash effect
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  accentTextTheme: ThemeData().accentTextTheme.apply(
      fontFamily: 'Montserrat',
      bodyColor: accentColor,
      displayColor: accentColor),
  toggleableActiveColor: accentColor,
  fontFamily: 'Montserrat',
  primaryColor: primaryColor,
);

var darkThemeData = ThemeData(
  brightness: Brightness.dark,
  accentColor: accentColor,
// The following two lines are meant to remove the splash effect
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  accentTextTheme: ThemeData().accentTextTheme.apply(
      fontFamily: 'Montserrat',
      bodyColor: accentColor,
      displayColor: accentColor),
  toggleableActiveColor: accentColor,
  fontFamily: 'Montserrat',
  primaryColor: primaryColor,
);
