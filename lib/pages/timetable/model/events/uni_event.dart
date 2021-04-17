import 'dart:core';

import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/classes/model/class.dart';
import 'package:acs_upb_mobile/pages/timetable/model/academic_calendar.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

enum UniEventType {
  lecture,
  lab,
  seminar,
  sports,
  semester,
  holiday,
  examSession,
  other
}

extension UniEventTypeExtension on UniEventType {
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case UniEventType.lecture:
        return S.of(context).uniEventTypeLecture;
      case UniEventType.lab:
        return S.of(context).uniEventTypeLab;
      case UniEventType.seminar:
        return S.of(context).uniEventTypeSeminar;
      case UniEventType.sports:
        return S.of(context).uniEventTypeSports;
      case UniEventType.semester:
        return S.of(context).uniEventTypeSemester;
      case UniEventType.holiday:
        return S.of(context).uniEventTypeHoliday;
      case UniEventType.examSession:
        return S.of(context).uniEventTypeExamSession;
      default:
        return S.of(context).uniEventTypeOther;
    }
  }

  static List<UniEventType> get classTypes => [
        UniEventType.lecture,
        UniEventType.lab,
        UniEventType.seminar,
        UniEventType.sports,
        UniEventType.examSession
      ];

  static UniEventType fromString(String string) {
    switch (string) {
      case 'lab':
        return UniEventType.lab;
      case 'lecture':
        return UniEventType.lecture;
      case 'seminar':
        return UniEventType.seminar;
      case 'sports':
        return UniEventType.sports;
      case 'semester':
        return UniEventType.semester;
      case 'holiday':
        return UniEventType.holiday;
      case 'examSession':
        return UniEventType.examSession;
      default:
        return UniEventType.other;
    }
  }

  Color get color {
    switch (this) {
      case UniEventType.lecture:
        return Colors.pinkAccent;
      case UniEventType.lab:
        return Colors.blueAccent;
      case UniEventType.seminar:
        return Colors.orangeAccent;
      case UniEventType.sports:
        return Colors.greenAccent;
      case UniEventType.semester:
        return Colors.transparent;
      case UniEventType.holiday:
        return Colors.yellow;
      case UniEventType.examSession:
        return Colors.red;
      default:
        return Colors.white;
    }
  }
}

class UniEvent {
  const UniEvent({
    @required this.start,
    @required this.duration,
    @required this.id,
    this.name,
    this.location,
    this.color,
    this.type,
    this.classHeader,
    this.calendar,
    this.relevance,
    this.degree,
    this.addedBy,
    bool editable,
  }) : editable = editable ?? true;

  final String id;
  final Color color;
  final UniEventType type;
  final LocalDateTime start;
  final Period duration;
  final String name;
  final String location;
  final ClassHeader classHeader;
  final AcademicCalendar calendar;
  final String degree;
  final List<String> relevance;
  final String addedBy;
  final bool editable;

  Iterable<UniEventInstance> generateInstances(
      {DateInterval intersectingInterval}) sync* {
    final LocalDateTime end = start.add(duration);
    if (intersectingInterval != null) {
      if (end.calendarDate < intersectingInterval.start ||
          start.calendarDate > intersectingInterval.end) return;
    }

    yield UniEventInstance(
      id: id,
      title: name,
      mainEvent: this,
      color: color,
      start: start,
      end: start.add(duration),
      location: location,
    );
  }
}

class UniEventInstance extends Event {
  UniEventInstance({
    @required String id,
    @required this.title,
    @required this.mainEvent,
    @required LocalDateTime start,
    @required LocalDateTime end,
    Color color,
    this.location,
    this.info,
  })  : color = color ?? mainEvent?.color,
        super(id: id, start: start, end: end);

  final UniEvent mainEvent;
  final String title;

  final Color color;
  final String location;
  final String info;

  @override
  bool operator ==(dynamic other) =>
      super == other &&
      color == other.color &&
      location == other.location &&
      mainEvent == other.mainEvent &&
      title == other.title;

  @override
  int get hashCode =>
      hashList([super.hashCode, color, location, mainEvent, title]);
}
