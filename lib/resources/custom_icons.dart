import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomIcons {
  CustomIcons._();

  static const _kFontFam = 'CustomIcons';
  static const _kFontPkg = null;

  // Custom font icons (see [CONTRIBUTING.md] for more info)
  static const IconData book =
      IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  // ignore: constant_identifier_names
  static const IconData github_brands =
      IconData(0xe803, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  // ignore: constant_identifier_names
  static const IconData edit_slash =
      IconData(0xe804, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  static const IconData filter =
      IconData(0xf0b0, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  static const Icon valid =
      Icon(Icons.check_circle_outlined, color: Colors.green);
  static const Icon invalid = Icon(Icons.cancel_outlined, color: Colors.red);

  // Transparent icon to be used as a placeholder
  static const Icon empty =
      Icon(Icons.cancel_outlined, color: Color(0x00000000));

  static Color formIconColor(ThemeData themeData) {
    switch (themeData.brightness) {
      case Brightness.dark:
        return Colors.white70;
      case Brightness.light:
        return Colors.black45;
      default:
        return themeData.iconTheme.color;
    }
  }
}
