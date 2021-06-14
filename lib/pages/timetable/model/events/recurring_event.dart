//import 'package:acs_upb_mobile/pages/classes/model/class.dart';
//import 'package:acs_upb_mobile/pages/timetable/model/academic_calendar.dart';
//import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
//import 'package:acs_upb_mobile/resources/locale_provider.dart';
//import 'package:acs_upb_mobile/resources/utils.dart';
//import 'package:flutter/material.dart';
//import 'package:rrule/rrule.dart';
//import 'package:time_machine/time_machine.dart';
//
//class RecurringUniEvent extends UniEvent {
//  const RecurringUniEvent({
//    @required this.rrule,
//    @required LocalDateTime start,
//    @required Period duration,
//    @required String id,
//    List<String> relevance,
//    String degree,
//    String name,
//    String location,
//    Color color,
//    UniEventType type,
//    ClassHeader classHeader,
//    AcademicCalendar calendar,
//    String addedBy,
//    bool editable,
//  })  : assert(rrule != null),
//        super(
//            name: name,
//            location: location,
//            start: start,
//            duration: duration,
//            degree: degree,
//            relevance: relevance,
//            id: id,
//            color: color,
//            type: type,
//            classHeader: classHeader,
//            calendar: calendar,
//            addedBy: addedBy,
//            editable: editable);
//
//  final RecurrenceRule rrule;
//
//  @override
//  String get info {
//    if (LocaleProvider.rruleL10n != null) {
//      return rrule.toText(l10n: LocaleProvider.rruleL10n);
//    }
//    return '';
//  }
//
//  RecurrenceRule get rruleBasedOnCalendar {
//    final RecurrenceRule rrule = this.rrule;
//    if (calendar != null && rrule.frequency == Frequency.weekly) {
//      var weeks = calendar.nonHolidayWeeks;
//
//      // Get the correct sequence of weeks for this event.
//      //
//      // For example, if the first academic calendar week is 40 and the event
//      // starts on week 41 and repeats every two weeks - get every odd-index
//      // week in the non holiday weeks.
//      // This is necessary because if an "even" week is followed by a one-week
//      // holiday, the week that comes after the holiday should be considered
//      // an "odd" week, even though its number in the calendar would have the
//      // same parity as the week before the holiday.
//      if (rrule.interval != 1) {
//        // Check whether the first calendar week is odd
//        final bool startOdd = weeks.first % 2 == 1;
//        weeks = weeks
//            .whereIndex((index) =>
//                (startOdd ? index : index + 1) % rrule.interval !=
//                weeks.lookup(WeekYearRules.iso
//                        .getWeekOfWeekYear(start.calendarDate)) %
//                    rrule.interval)
//            .toSet();
//      }
//      return rrule.copyWith(
//          frequency: Frequency.yearly,
//          interval: 1,
//          byWeekDays: rrule.byWeekDays.isNotEmpty
//              ? rrule.byWeekDays
//              : {ByWeekDayEntry(start.dayOfWeek)},
//          byWeeks: weeks);
//    }
//    return rrule;
//  }
//
//  @override
//  Iterable<UniEventInstance> generateInstances(
//      {DateInterval intersectingInterval}) sync* {
//    final RecurrenceRule rrule = rruleBasedOnCalendar;
//
//    // Calculate recurrences
//    int i = 0;
//    for (final start in rrule.getInstances(start: start)) {
//      final LocalDateTime end = start.add(duration);
//      if (intersectingInterval != null) {
//        if (end.calendarDate < intersectingInterval.start) continue;
//        if (start.calendarDate > intersectingInterval.end) break;
//      }
//
//      bool skip = false;
//      for (final holiday in calendar?.holidays ?? []) {
//        final holidayInterval =
//            DateInterval(holiday.startDate, holiday.endDate);
//        if (holidayInterval.contains(start.calendarDate)) {
//          // Skip holidays
//          skip = true;
//        }
//      }
//
//      if (!skip) {
//        yield UniEventInstance(
//          id: '$id-$i',
//          title: name,
//          mainEvent: this,
//          color: color,
//          start: start,
//          end: end,
//          location: location,
//        );
//      }
//
//      i++;
//    }
//  }
//}
