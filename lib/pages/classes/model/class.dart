import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

enum ShortcutType { main, classbook, resource, other }

extension ShortcutTypeExtension on ShortcutType {
  String toLocalizedString() {
    switch (this) {
      case ShortcutType.main:
        return S.current.shortcutTypeMain;
      case ShortcutType.classbook:
        return S.current.shortcutTypeClassbook;
      case ShortcutType.resource:
        return S.current.shortcutTypeResource;
      default:
        return S.current.shortcutTypeOther;
    }
  }
}

class Shortcut {
  Shortcut({this.type, this.name, this.link, this.ownerUid});

  final ShortcutType type;
  final String name;
  final String link;
  final String ownerUid;
}

class ClassHeader {
  ClassHeader({this.id, this.name, this.acronym, this.category});

  final String id;
  final String name;
  final String acronym;
  final String category;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is ClassHeader) {
      return other.id == id;
    }
    return false;
  }
}

class Class {
  Class(
      {@required this.header,
      List<Shortcut> shortcuts,
      this.grading,
      this.gradingLastUpdated})
      : shortcuts = shortcuts ?? [];

  ClassHeader header;
  final List<Shortcut> shortcuts;
  final Map<String, double> grading;
  final DateTime gradingLastUpdated;
}
