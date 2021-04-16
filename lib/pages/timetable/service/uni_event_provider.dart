import 'dart:async';

import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/classes/model/class.dart';
import 'package:acs_upb_mobile/pages/people/model/person.dart';
import 'package:acs_upb_mobile/pages/classes/service/class_provider.dart';
import 'package:acs_upb_mobile/pages/filter/model/filter.dart';
import 'package:acs_upb_mobile/pages/filter/service/filter_provider.dart';
import 'package:acs_upb_mobile/pages/people/service/person_provider.dart';
import 'package:acs_upb_mobile/pages/timetable/model/academic_calendar.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/all_day_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/class_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/recurring_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rrule/rrule.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

extension PeriodExtension on Period {
  static Period fromJSON(Map<String, dynamic> json) {
    return Period(
      years: json['years'] ?? 0,
      months: json['months'] ?? 0,
      weeks: json['weeks'] ?? 0,
      days: json['days'] ?? 0,
      hours: json['hours'] ?? 0,
      minutes: json['minutes'] ?? 0,
      seconds: json['seconds'] ?? 0,
      milliseconds: json['milliseconds'] ?? 0,
      microseconds: json['microseconds'] ?? 0,
      nanoseconds: json['nanoseconds'] ?? 0,
    );
  }

  Map<String, dynamic> toJSON() {
    final json = {
      'years': years,
      'months': months,
      'weeks': weeks,
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'milliseconds': milliseconds,
      'microseconds': microseconds,
      'nanoseconds': nanoseconds
    };

    return json..removeWhere((key, value) => value == 0);
  }
}

extension LocalDateTimeExtension on LocalDateTime {
  Timestamp toTimestamp() => Timestamp.fromDate(toDateTimeLocal());
}

extension UniEventExtension on UniEvent {
  static UniEvent fromJSON(String id, Map<String, dynamic> json,
      {ClassHeader classHeader,
      Person teacher,
      Map<String, AcademicCalendar> calendars = const {}}) {
    if (json['start'] == null ||
        (json['duration'] == null && json['end'] == null)) return null;

    final type = UniEventTypeExtension.fromString(json['type']);

    if (json['end'] != null) {
      return AllDayUniEvent(
        id: id,
        type: type,
        name: json['name'],
        // Convert time to UTC and then to local time
        start: (json['start'] as Timestamp).toLocalDateTime().calendarDate,
        end: (json['end'] as Timestamp).toLocalDateTime().calendarDate,
        location: json['location'],
        // TODO(IoanaAlexandru): Allow users to set event colours in settings
        color: type.color,
        classHeader: classHeader,
        calendar: calendars[json['calendar']],
        degree: json['degree'],
        relevance: json['relevance'] == null
            ? null
            : List<String>.from(json['relevance']),
        addedBy: json['addedBy'],
      );
    } else if (json['rrule'] != null && json['teacher'] == null) {
      return RecurringUniEvent(
        rrule: RecurrenceRule.fromString(json['rrule']),
        id: id,
        type: type,
        name: json['name'],
        // Convert time to UTC and then to local time
        start: (json['start'] as Timestamp).toLocalDateTime(),
        duration: PeriodExtension.fromJSON(json['duration']),
        location: json['location'],
        // TODO(IoanaAlexandru): Allow users to set event colours in settings
        color: type.color,
        classHeader: classHeader,
        calendar: calendars[json['calendar']],
        degree: json['degree'],
        relevance: json['relevance'] == null
            ? null
            : List<String>.from(json['relevance']),
        addedBy: json['addedBy'],
        modifiedInstances: json['modifiedInstances'] == null
            ? null
            : Map<String, dynamic>.from(json['modifiedInstances']),
      );
    } else if (json['rrule'] != null && json['teacher'] != null) {
      return ClassEvent(
        teacher: teacher,
        rrule: RecurrenceRule.fromString(json['rrule']),
        id: id,
        type: type,
        name: json['name'],
        start: (json['start'] as Timestamp).toLocalDateTime(),
        duration: PeriodExtension.fromJSON(json['duration']),
        location: json['location'],
        color: type.color,
        classHeader: classHeader,
        calendar: calendars[json['calendar']],
        degree: json['degree'],
        relevance: json['relevance'] == null
            ? null
            : List<String>.from(json['relevance']),
        addedBy: json['addedBy'],
      );
    } else {
      return UniEvent(
        id: id,
        type: type,
        name: json['name'],
        // Convert time to UTC and then to local time
        start: (json['start'] as Timestamp).toLocalDateTime(),
        duration: PeriodExtension.fromJSON(json['duration']),
        location: json['location'],
        // TODO(IoanaAlexandru): Allow users to set event colours in settings
        color: type.color,
        classHeader: classHeader,
        calendar: calendars[json['calendar']],
        degree: json['degree'],
        relevance: json['relevance'] == null
            ? null
            : List<String>.from(json['relevance']),
        addedBy: json['addedBy'],
      );
    }
  }

  Map<String, dynamic> toData() {
    final type = this.type.toShortString();

    final json = {
      'type': type,
      'name': name,
      'start': start.toTimestamp(),
      'duration': duration.toJSON(),
      'location': location,
      'class': classHeader.id,
      'degree': degree,
      'relevance': relevance,
      'calendar': calendar.id,
      'addedBy': addedBy,
    };

    if (this is RecurringUniEvent) {
      json['rrule'] = (this as RecurringUniEvent).rrule.toString();
      json['modifiedInstances'] =
          (this as RecurringUniEvent).modifiedInstances.toString();
    }

    if (this is AllDayUniEvent) {
      json['end'] = (this as AllDayUniEvent).endDate.atMidnight().toTimestamp();
    }

    if (this is ClassEvent) {
      json['teacher'] = (this as ClassEvent).teacher?.name;
    }

    return json;
  }
}

extension AcademicCalendarExtension on AcademicCalendar {
  static List<AllDayUniEvent> _eventsFromMapList(
          List<dynamic> list, String type) =>
      List<AllDayUniEvent>.from((list ?? []).asMap().map((index, e) {
        e['type'] = type;
        return MapEntry(
            index, UniEventExtension.fromJSON(type + index.toString(), e));
      }).values);

  static AcademicCalendar fromSnap(DocumentSnapshot snap) {
    final data = snap.data();
    return AcademicCalendar(
      id: snap.id,
      semesters: _eventsFromMapList(data['semesters'], 'semester'),
      holidays: _eventsFromMapList(data['holidays'], 'holiday'),
      exams: _eventsFromMapList(data['exams'], 'examSession'),
    );
  }
}

class UniEventProvider extends EventProvider<UniEventInstance>
    with ChangeNotifier {
  UniEventProvider({AuthProvider authProvider, PersonProvider personProvider})
      : _authProvider = authProvider ?? AuthProvider(),
        _personProvider = personProvider ?? PersonProvider() {
    fetchCalendars();
  }

  final Map<String, AcademicCalendar> _calendars = {};
  ClassProvider _classProvider;
  FilterProvider _filterProvider;
  final AuthProvider _authProvider;
  final PersonProvider _personProvider;
  List<String> _classIds = [];
  Filter _filter;
  bool empty;

  Future<Map<String, AcademicCalendar>> fetchCalendars() async {
    final QuerySnapshot query =
        await FirebaseFirestore.instance.collection('calendars').get();
    for (final doc in query.docs) {
      _calendars[doc.id] = AcademicCalendarExtension.fromSnap(doc);
    }

    notifyListeners();
    return _calendars;
  }

  Future<void> checkIfEmpty(List<Stream<List<UniEvent>>> streams) async {
    for (final stream in streams) {
      if ((await stream.first)?.isNotEmpty ?? false) {
        empty = false;
        return;
      }
    }
    empty = true;
  }

  Stream<List<UniEvent>> get _events {
    if (!_authProvider.isAuthenticated ||
        _filter == null ||
        _calendars == null) {
      return Stream.value([]);
    }

    final streams = <Stream<List<UniEvent>>>[];

    if (_filter.relevantNodes.length > 1) {
      for (final classId in _classIds ?? []) {
        final Stream<List<UniEvent>> stream = FirebaseFirestore.instance
            .collection('events')
            .where('class', isEqualTo: classId)
            .where('degree', isEqualTo: _filter.baseNode)
            .where('relevance',
                arrayContainsAny: _filter.relevantNodes..remove('All'))
            .snapshots()
            .asyncMap((snapshot) async {
          final events = <UniEvent>[];

          try {
            for (final doc in snapshot.docs) {
              ClassHeader classHeader;
              Person teacher;
              final data = doc.data();
              if (data['class'] != null) {
                classHeader =
                    await _classProvider.fetchClassHeader(data['class']);
              }
              if (data['teacher'] != null) {
                teacher = await _personProvider.fetchPerson(data['teacher']);
              }

              events.add(UniEventExtension.fromJSON(doc.id, data,
                  classHeader: classHeader,
                  teacher: teacher,
                  calendars: _calendars));
            }
            return events.where((element) => element != null).toList();
          } catch (e) {
            print(e);
            return events;
          }
        });
        streams.add(stream);
      }
    }

    checkIfEmpty(streams);

    final stream = StreamZip(streams);

    // Flatten zipped streams
    return stream.map((events) => events.expand((i) => i).toList());
  }

  @override
  Stream<Iterable<UniEventInstance>> getAllDayEventsIntersecting(
      DateInterval interval) {
    return _events.map((events) => events
        .map((event) => event.generateInstances(intersectingInterval: interval))
        .expand((i) => i)
        .allDayEvents
        .followedBy(_calendars.values.map((cal) {
          final List<AllDayUniEvent> events = cal.holidays + cal.exams;
          return events
              .where((event) =>
                  event.relevance == null ||
                  (_filter != null &&
                      event.degree == _filter.baseNode &&
                      event.relevance.any(_filter.relevantNodes.contains)))
              .map((e) => e.generateInstances(intersectingInterval: interval))
              .expand((e) => e);
        }).expand((e) => e)));
  }

  @override
  Stream<Iterable<UniEventInstance>> getPartDayEventsIntersecting(
      LocalDate date) {
    return _events.map((events) => events
        .map((event) => event.generateInstances(
            intersectingInterval: DateInterval(date, date)))
        .expand((i) => i)
        .partDayEvents);
  }

  void updateClasses(ClassProvider classProvider) {
    _classProvider = classProvider;
    _classProvider.fetchUserClassIds(uid: _authProvider.uid).then((classIds) {
      _classIds = classIds;
      notifyListeners();
    });
  }

  void updateFilter(FilterProvider filterProvider) {
    _filterProvider = filterProvider;
    _filterProvider.fetchFilter().then((filter) {
      _filter = filter;
      notifyListeners();
    });
  }

  Future<bool> addEvent(UniEvent event, {BuildContext context}) async {
    try {
      await FirebaseFirestore.instance.collection('events').add(event.toData());
      notifyListeners();
      return true;
    } catch (e) {
      _errorHandler(e, context);
      return false;
    }
  }

  Future<bool> updateEvent(UniEvent event, {BuildContext context}) async {
    try {
      final ref = FirebaseFirestore.instance.collection('events').doc(event.id);

      if ((await ref.get()).data == null) {
        print('Event not found.');
        return false;
      }

      await ref.update(event.toData());
      notifyListeners();
      return true;
    } catch (e) {
      _errorHandler(e, context);
      return false;
    }
  }

  Future<bool> deleteEvent(UniEvent event, {BuildContext context}) async {
    try {
      DocumentReference ref;
      ref = FirebaseFirestore.instance.collection('events').doc(event.id);
      await ref.delete();
      notifyListeners();
      return true;
    } catch (e) {
      _errorHandler(e, context);
      return false;
    }
  }

  Future<bool> disableInstance(UniEventInstance event,
      {BuildContext context}) async {
    return true;
  }

  @override
  // ignore: must_call_super
  void dispose() {
    // TODO(IoanaAlexandru): Find a better way to prevent Timetable from calling dispose on this provider
  }

  void _errorHandler(dynamic e, BuildContext context) {
    print(e.message);
    if (context != null) {
      if (e.message.contains('PERMISSION_DENIED')) {
        AppToast.show(S.of(context).errorPermissionDenied);
      } else {
        AppToast.show(S.of(context).errorSomethingWentWrong);
      }
    }
  }
}
