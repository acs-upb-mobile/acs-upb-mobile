import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rrule/rrule.dart';

mixin Localizable {
  String toLocalizedString();
}

class LocaleProvider {
  LocaleProvider._();

  static String defaultLocale = 'en';
  static List<String> supportedLocales = ['en', 'ro'];
  static Map<String, RruleL10n> rruleL10ns;

  static String get localeString {
    final languagePref = prefService.get<String>('language');
    if (languagePref == 'auto') {
      final systemLocale = Intl.defaultLocale.substring(0, 2);
      if (supportedLocales.contains(systemLocale)) {
        return systemLocale;
      } else {
        return defaultLocale;
      }
    } else {
      return languagePref;
    }
  }

  static Locale localeFromString(String preferenceString) {
    switch (preferenceString) {
      case 'auto':
        return localeFromString(Intl.defaultLocale);
      case 'ro':
        return const Locale('ro', 'RO');
      case 'en':
        return const Locale('en', 'US');
      default:
        return localeFromString(defaultLocale);
    }
  }

  static Locale get locale {
    return localeFromString(localeString);
  }

  static RruleL10n get rruleL10n => rruleL10ns[localeString];
}
