import 'package:acs_upb_mobile/pages/classes/model/class.dart';
import 'package:acs_upb_mobile/pages/timetable/model/academic_calendar.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:rrule/rrule.dart';
import 'package:time_machine/time_machine.dart';

class RecurringUniEvent extends UniEvent {
  const RecurringUniEvent({
    @required this.rrule,
    @required LocalDateTime start,
    @required Period duration,
    @required String id,
    List<String> relevance,
    String degree,
    String name,
    String location,
    Color color,
    UniEventType type,
    ClassHeader classHeader,
    AcademicCalendar calendar,
    String addedBy,
    Map<String, dynamic> modifiedInstances,
  })  : assert(rrule != null),
        super(
            name: name,
            location: location,
            start: start,
            duration: duration,
            degree: degree,
            relevance: relevance,
            id: id,
            color: color,
            type: type,
            classHeader: classHeader,
            calendar: calendar,
            addedBy: addedBy,
            modifiedInstances: modifiedInstances);

  final RecurrenceRule rrule;

  @override
  Iterable<UniEventInstance> generateInstances(
      {DateInterval intersectingInterval}) sync* {
    RecurrenceRule rrule = this.rrule;
    if (calendar != null && rrule.frequency == Frequency.weekly) {
      var weeks = calendar.nonHolidayWeeks;

      // Get the correct sequence of weeks for this event.
      //
      // For example, if the first academic calendar week is 40 and the event
      // starts on week 41 and repeats every two weeks - get every odd-index
      // week in the non holiday weeks.
      // This is necessary because if an "even" week is followed by a one-week
      // holiday, the week that comes after the holiday should be considered
      // an "odd" week, even though its number in the calendar would have the
      // same parity as the week before the holiday.
      if (rrule.interval != 1) {
        // Check whether the first calendar week is odd
        final bool startOdd = weeks.first % 2 == 1;
        weeks = weeks
            .whereIndex((index) =>
                (startOdd ? index : index + 1) % rrule.interval !=
                weeks.lookup(WeekYearRules.iso
                        .getWeekOfWeekYear(start.calendarDate)) %
                    rrule.interval)
            .toSet();
      }
      rrule = rrule.copyWith(
          frequency: Frequency.daily,
          interval: 1,
          byWeekDays: rrule.byWeekDays.isNotEmpty
              ? rrule.byWeekDays
              : {ByWeekDayEntry(start.dayOfWeek)},
          byWeeks: weeks);
    }

    // Calculate recurrences
    int i = 0;
    for (final start in rrule.getInstances(start: start)) {
      final LocalDateTime end = start.add(duration);
      if (intersectingInterval != null) {
        if (end.calendarDate < intersectingInterval.start) continue;
        if (start.calendarDate > intersectingInterval.end) break;
      }

      bool skip = false;
      for (final holiday in calendar?.holidays ?? []) {
        final holidayInterval =
            DateInterval(holiday.startDate, holiday.endDate);
        if (holidayInterval.contains(start.calendarDate)) {
          // Skip holidays
          skip = true;
        }
      }

      bool active = true;
      if (modifiedInstances != null) {
        if (modifiedInstances.containsKey('$i')) {
          active = modifiedInstances['$i']['active'];
        }
      }
      if (!skip) {
        yield UniEventInstance(
          id: '$id-$i',
          title: name,
          mainEvent: this,
          color: active == true ? color : Colors.black45,
          start: start,
          end: end,
          location: location,
          active: active,
        );
      }

      i++;
    }
  }
}
