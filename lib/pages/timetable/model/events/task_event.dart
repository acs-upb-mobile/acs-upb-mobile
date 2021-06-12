import 'package:acs_upb_mobile/pages/classes/model/class.dart';
import 'package:acs_upb_mobile/pages/timetable/model/academic_calendar.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/all_day_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:time_machine/time_machine.dart';

class TaskEvent extends AllDayUniEvent {
  TaskEvent({
    @required LocalDate start,
    @required LocalDate hardDeadline,
    @required String id,
    LocalDate softDeadline,
    String name,
    String location,
    Color color,
    UniEventType type,
    ClassHeader classHeader,
    AcademicCalendar calendar,
    List<String> relevance,
    String degree,
    String addedBy,
    double grade,
    double penalties,
  })  : hardDeadline = hardDeadline ?? hardDeadline,
        softDeadline = softDeadline ?? softDeadline,
        grade = grade ?? 0,
        penalties = penalties ?? 0,
        super(
            start: start,
            end: hardDeadline,
            name: name,
            location: location,
            id: id,
            color: color,
            type: type,
            classHeader: classHeader,
            calendar: calendar,
            relevance: relevance,
            degree: degree,
            addedBy: addedBy,
            editable: true);

  LocalDate softDeadline;
  LocalDate hardDeadline;
  double grade;
  double penalties;

  @override
  Iterable<UniEventInstance> generateInstances(
      {DateInterval intersectingInterval, bool hidden = false}) sync* {
    yield UniEventInstance(
      id: id,
      title: name + (classHeader != null ? ' ${classHeader.acronym}' : ''),
      mainEvent: this,
      start: startDate.atMidnight(),
      end: endDate.addDays(1).atMidnight(),
      color: color,
      grade: grade,
      penalties: penalties,
      hidden: hidden,
    );
  }
}
