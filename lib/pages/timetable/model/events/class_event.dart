import 'package:acs_upb_mobile/pages/classes/model/class.dart';
import 'package:acs_upb_mobile/pages/people/model/person.dart';
import 'package:acs_upb_mobile/pages/timetable/model/academic_calendar.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/recurring_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:rrule/rrule.dart';
import 'package:time_machine/time_machine.dart';

class ClassEvent extends RecurringUniEvent {
  const ClassEvent({
    @required this.teacher,
    @required RecurrenceRule rrule,
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
  }) : super(
            rrule: rrule,
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
            addedBy: addedBy);

  final Person teacher;
}
