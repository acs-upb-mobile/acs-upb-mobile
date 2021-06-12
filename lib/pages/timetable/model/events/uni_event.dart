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
  homework,
  project,
  other
}

extension UniEventTypeExtension on UniEventType {
  String toLocalizedString() {
    switch (this) {
      case UniEventType.lecture:
        return S.current.uniEventTypeLecture;
      case UniEventType.lab:
        return S.current.uniEventTypeLab;
      case UniEventType.seminar:
        return S.current.uniEventTypeSeminar;
      case UniEventType.sports:
        return S.current.uniEventTypeSports;
      case UniEventType.semester:
        return S.current.uniEventTypeSemester;
      case UniEventType.holiday:
        return S.current.uniEventTypeHoliday;
      case UniEventType.examSession:
        return S.current.uniEventTypeExamSession;
      case UniEventType.homework:
        return S.current.uniEventTypeHomework;
      case UniEventType.project:
        return S.current.uniEventTypeProject;
      default:
        return S.current.uniEventTypeOther;
    }
  }

  static List<UniEventType> get classTypes => [
        UniEventType.lecture,
        UniEventType.lab,
        UniEventType.seminar,
        UniEventType.sports
      ];

  static List<UniEventType> get assignmentsTypes => [
        UniEventType.homework,
        UniEventType.project,
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
      case 'homework':
        return UniEventType.homework;
      case 'project':
        return UniEventType.project;
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
      case UniEventType.homework:
        return Colors.cyan;
      case UniEventType.project:
        return Colors.teal;
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

  String get info {
    return generateInstances().first.dateString;
  }

  Iterable<UniEventInstance> generateInstances(
      {DateInterval intersectingInterval, bool hidden = false}) sync* {
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
      hidden: hidden,
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
    this.grade,
    this.penalties,
    this.hidden,
  })  : color = color ?? mainEvent?.color,
        super(id: id, start: start, end: end);

  final UniEvent mainEvent;
  final String title;

  final Color color;
  final String location;
  final String info;
  final double grade;
  final double penalties;
  final bool hidden;

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

  String get dateString => getDateString(useRelativeDayFormat: false);

  String get relativeDateString => getDateString(useRelativeDayFormat: true);

  String getDateString({bool useRelativeDayFormat}) {
    final LocalDateTime end = this.end.clockTime.equals(LocalTime(00, 00, 00))
        ? this.end.subtractDays(1)
        : this.end;

    String string =
        useRelativeDayFormat && start.calendarDate.equals(LocalDate.today())
            ? S.current.labelToday
            : useRelativeDayFormat &&
                    start.calendarDate.subtractDays(1).equals(LocalDate.today())
                ? S.current.labelTomorrow
                : start.calendarDate.toString('dddd, dd MMMM');
    final String endString =
        useRelativeDayFormat && end.calendarDate.equals(LocalDate.today())
            ? S.current.labelToday
            : useRelativeDayFormat &&
                    end.calendarDate.subtractDays(1).equals(LocalDate.today())
                ? S.current.labelTomorrow
                : end.calendarDate.toString('dddd, dd MMMM');

    if (!start.clockTime.equals(LocalTime(00, 00, 00))) {
      string += ' • ${start.clockTime.toString('HH:mm')}';
    }
    if (start.calendarDate != end.calendarDate) {
      string += ' - $endString';
    }
    if (!end.clockTime.equals(LocalTime(00, 00, 00))) {
      if (start.calendarDate != end.calendarDate) {
        string += ' • ';
      } else {
        string += '-';
      }
      string += end.clockTime.toString('HH:mm');
    }
    return string;
  }
}
