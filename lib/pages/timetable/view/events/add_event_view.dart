import 'package:acs_upb_mobile/authentication/model/user.dart';
import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/navigation/routes.dart';
import 'package:acs_upb_mobile/pages/classes/model/class.dart';
import 'package:acs_upb_mobile/pages/classes/service/class_provider.dart';
import 'package:acs_upb_mobile/pages/filter/view/relevance_picker.dart';
import 'package:acs_upb_mobile/pages/people/model/person.dart';
import 'package:acs_upb_mobile/pages/people/service/person_provider.dart';
import 'package:acs_upb_mobile/pages/people/view/people_page.dart';
import 'package:acs_upb_mobile/pages/timetable/model/academic_calendar.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/all_day_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/class_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/recurring_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:acs_upb_mobile/pages/timetable/service/uni_event_provider.dart';
import 'package:acs_upb_mobile/resources/locale_provider.dart';
import 'package:acs_upb_mobile/resources/theme.dart';
import 'package:acs_upb_mobile/widgets/button.dart';
import 'package:acs_upb_mobile/widgets/chip_form_field.dart';
import 'package:acs_upb_mobile/widgets/dialog.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:rrule/rrule.dart';
import 'package:time_machine/time_machine.dart' as time_machine show DayOfWeek;
import 'package:time_machine/time_machine.dart' hide DayOfWeek;
import 'package:time_machine/time_machine_text_patterns.dart';

class AddEventView extends StatefulWidget {
  /// If the `id` of [initialEvent] is not null, this acts like an "Edit event"
  /// page starting from the info in [initialEvent]. Otherwise, it acts like an
  /// "Add event" page with optional default values based on [initialEvent].
  const AddEventView({Key key, this.initialEvent}) : super(key: key);

  final UniEvent initialEvent;

  @override
  _AddEventViewState createState() => _AddEventViewState();
}

class _AddEventViewState extends State<AddEventView> {
  final formKey = GlobalKey<FormState>();

  TextEditingController locationController;
  RelevanceController relevanceController = RelevanceController();

  UniEventType selectedEventType;
  ClassHeader selectedClass;
  Person selectedTeacher;
  String selectedCalendar;
  LocalTime startTime;
  Period duration;
  Map<WeekType, bool> weekSelected = {
    WeekType.odd: null,
    WeekType.even: null,
  };
  Map<_DayOfWeek, bool> weekDaySelected = {
    _DayOfWeek.monday: false,
    _DayOfWeek.tuesday: false,
    _DayOfWeek.wednesday: false,
    _DayOfWeek.thursday: false,
    _DayOfWeek.friday: false,
    _DayOfWeek.saturday: false,
    _DayOfWeek.sunday: false,
  };

  int selectedSemester = 1;

  AllDayUniEvent get semester =>
      calendars[selectedCalendar]?.semesters?.elementAt(selectedSemester - 1);

  List<ClassHeader> classHeaders = [];
  List<Person> classTeachers = [];
  User user;
  Map<String, AcademicCalendar> calendars = {};

  @override
  void initState() {
    super.initState();

    user =
        Provider.of<AuthProvider>(context, listen: false).currentUserFromCache;
    Provider.of<ClassProvider>(context, listen: false)
        .fetchClassHeaders(uid: user.uid)
        .then((headers) => setState(() => classHeaders = headers));
    Provider.of<PersonProvider>(context, listen: false)
        .fetchPeople()
        .then((teachers) => setState(() => classTeachers = teachers));
    Provider.of<UniEventProvider>(context, listen: false)
        .fetchCalendars()
        .then((calendars) {
      setState(() {
        this.calendars = calendars;
        selectedCalendar = calendars.keys.first;
      });

      if (widget.initialEvent?.id != null) {
        selectedCalendar = widget.initialEvent.calendar.id;
        final AllDayUniEvent secondSemester =
            widget.initialEvent.calendar.semesters.last;
        selectedSemester =
            DateInterval(secondSemester.startDate, secondSemester.endDate)
                    .contains(widget.initialEvent.start.calendarDate)
                ? 2
                : 1;
      } else {
        bool foundSemester = false;
        for (final calendar in calendars.entries) {
          for (final semester in calendar.value.semesters) {
            final LocalDate date =
                widget.initialEvent.start.calendarDate ?? LocalDate.today();
            if (date.isBeforeOrDuring(semester)) {
              // semester.id is represented as "semesterN", where "semester0" is the first semester
              selectedSemester =
                  1 + int.tryParse(semester.id[semester.id.length - 1]);
              selectedCalendar = calendar.key;
              foundSemester = true;
              break;
            }
          }
          if (foundSemester) break;
        }
        if (!foundSemester) {
          selectedCalendar = calendars.entries.last.value.id;
          selectedSemester = 2;
        }
      }

      if (widget.initialEvent != null &&
          widget.initialEvent is RecurringUniEvent) {
        final RecurringUniEvent event = widget.initialEvent;
        if (event.rrule.interval != 1) {
          final rule = WeekYearRules.iso;
          if (rule.getWeekOfWeekYear(semester.start.calendarDate) ==
              rule.getWeekOfWeekYear(event.start.calendarDate)) {
            // Week is odd
            weekSelected[WeekType.even] = false;
            weekSelected[WeekType.odd] = true;
          } else {
            // Week is even
            weekSelected[WeekType.even] = true;
            weekSelected[WeekType.odd] = false;
          }
        }
      }

      setState(() {
        weekSelected[WeekType.even] ??= true;
        weekSelected[WeekType.odd] ??= true;
      });
    });

    selectedEventType = widget.initialEvent?.type;
    selectedClass = widget.initialEvent?.classHeader;
    selectedTeacher = widget.initialEvent is ClassEvent
        ? (widget.initialEvent as ClassEvent).teacher
        : null;
    locationController =
        TextEditingController(text: widget.initialEvent?.location ?? '');

    final startHour = widget.initialEvent?.start?.hourOfDay ?? 8;
    duration = widget.initialEvent?.duration ?? const Period(hours: 2);
    startTime = LocalTime(startHour, 0, 0);

    var initialWeekDays = [
      _DayOfWeek.from(widget.initialEvent?.start?.dayOfWeek) ??
          _DayOfWeek.monday
    ];
    if (widget.initialEvent != null &&
        widget.initialEvent is RecurringUniEvent &&
        (widget.initialEvent as RecurringUniEvent)
            .rrule
            .byWeekDays
            .isNotEmpty) {
      initialWeekDays = (widget.initialEvent as RecurringUniEvent)
          .rrule
          .byWeekDays
          .map((entry) => _DayOfWeek.from(entry.day))
          .toList();
    }
    for (final initialWeekDay in initialWeekDays) {
      weekDaySelected[initialWeekDay] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: Text(widget.initialEvent?.id == null
          ? S.current.actionAddEvent
          : S.current.actionEditEvent),
      actions: widget.initialEvent?.id == null
          ? [_saveButton()]
          : [
              _saveButton(),
              _deleteButton(),
            ],
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: S.current.labelUniversityYear,
                            prefixIcon:
                                const Icon(Icons.calendar_today_outlined),
                          ),
                          value: selectedCalendar,
                          items: calendars.keys.map((key) {
                            final year = int.tryParse(key);
                            return DropdownMenuItem<String>(
                              value: key,
                              child: Text(
                                  year != null ? '$year-${year + 1}' : key),
                            );
                          }).toList(),
                          onChanged: (selection) =>
                              selectedCalendar = selection,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: S.current.labelSemester,
                            prefixIcon: const Icon(FeatherIcons.columns),
                          ),
                          value: selectedSemester,
                          items: [1, 2]
                              .map((semester) => DropdownMenuItem<int>(
                                    value: semester,
                                    child: Text(semester.toString()),
                                  ))
                              .toList(),
                          onChanged: (selection) =>
                              selectedSemester = selection,
                        ),
                      ),
                    ],
                  ),
                  RelevanceFormField(
                    canBePrivate: false,
                    canBeForEveryone: false,
                    controller: relevanceController,
                  ),
                  DropdownButtonFormField<UniEventType>(
                    decoration: InputDecoration(
                      labelText: S.current.labelType,
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    value: selectedEventType,
                    items: UniEventTypeExtension.classTypes
                        .map(
                          (type) => DropdownMenuItem<UniEventType>(
                            value: type,
                            child: Text(type.toLocalizedString()),
                          ),
                        )
                        .toList(),
                    onChanged: (selection) {
                      formKey.currentState.validate();
                      setState(() => selectedEventType = selection);
                    },
                    validator: (selection) {
                      if (selection == null) {
                        return S.current.errorEventTypeCannotBeEmpty;
                      }
                      return null;
                    },
                  ),
                  if (selectedEventType != null)
                    Column(
                      children: [
                        if (classHeaders.isNotEmpty)
                          DropdownButtonFormField<ClassHeader>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: S.current.labelClass,
                              prefixIcon: const Icon(FeatherIcons.bookOpen),
                            ),
                            value: selectedClass,
                            items: classHeaders
                                .map(
                                  (header) => DropdownMenuItem(
                                      value: header, child: Text(header.name)),
                                )
                                .toList(),
                            onChanged: (selection) {
                              formKey.currentState.validate();
                              setState(() => selectedClass = selection);
                            },
                            validator: (selection) {
                              if (selection == null) {
                                return S.current.errorClassCannotBeEmpty;
                              }
                              return null;
                            },
                          ),
                        if ([UniEventType.lecture].contains(selectedEventType))
                          AutocompletePerson(
                            key: const Key('AutocompleteLecturer'),
                            labelText: S.current.labelLecturer,
                            formKey: formKey,
                            onSaved: (value) => selectedTeacher = value,
                            classTeachers: classTeachers,
                            personDisplayed: selectedTeacher,
                          ),
                        TextFormField(
                          controller: locationController,
                          decoration: InputDecoration(
                            labelText: S.current.labelLocation,
                            prefixIcon: const Icon(FeatherIcons.mapPin),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        timeIntervalPicker(),
                        Divider(
                          thickness: 0.7,
                          color: Theme.of(context).hintColor,
                        ),
                        if (weekSelected[WeekType.odd] != null &&
                            weekSelected[WeekType.even] != null)
                          FilterChipFormField(
                            key: const ValueKey('week_picker'),
                            icon: FeatherIcons.calendar,
                            label: S.current.labelWeek,
                            initialValues: weekSelected,
                          ),
                        FilterChipFormField(
                          key: const ValueKey('day_picker'),
                          icon: Icons.today_outlined,
                          label: S.current.labelDay,
                          initialValues: weekDaySelected,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppDialog _deletionConfirmationDialog(BuildContext context) => AppDialog(
        icon: const Icon(Icons.delete_outlined),
        title: S.current.actionDeleteEvent,
        info: S.current.messageThisCouldAffectOtherStudents,
        message: S.current.messageDeleteEvent,
        actions: [
          AppButton(
            text: S.current.actionDeleteEvent,
            width: 130,
            onTap: () async {
              final res =
                  await Provider.of<UniEventProvider>(context, listen: false)
                      .deleteEvent(widget.initialEvent);
              if (res) {
                Navigator.of(context)
                    .popUntil(ModalRoute.withName(Routes.home));
                AppToast.show(S.current.messageEventDeleted);
              }
            },
          )
        ],
      );

  AppScaffoldAction _saveButton() => AppScaffoldAction(
        text: S.current.buttonSave,
        onPressed: () async {
          if (!formKey.currentState.validate()) return;

          LocalDateTime start = semester.startDate.at(startTime);
          if (weekSelected[WeekType.even] && !weekSelected[WeekType.odd]) {
            // Event is every even week, add a week to start date
            start = start.add(const Period(weeks: 1));
          }

          final rrule = RecurrenceRule(
              frequency: Frequency.weekly,
              byWeekDays: (Map<_DayOfWeek, bool>.from(weekDaySelected)
                    ..removeWhere((key, value) => !value))
                  .keys
                  .map((weekDay) => ByWeekDayEntry(weekDay))
                  .toSet(),
              interval:
                  weekSelected[WeekType.odd] != weekSelected[WeekType.even]
                      ? 2
                      : 1,
              until: semester.endDate.add(const Period(days: 1)).atMidnight());

          final event = ClassEvent(
              teacher: selectedTeacher,
              rrule: rrule,
              start: start,
              duration: duration,
              id: widget.initialEvent?.id,
              relevance: relevanceController.customRelevance,
              degree: relevanceController.degree,
              location: locationController.text,
              type: selectedEventType,
              classHeader: selectedClass,
              calendar: calendars[selectedCalendar],
              addedBy: Provider.of<AuthProvider>(context, listen: false)
                  .currentUserFromCache
                  .uid);

          if (widget.initialEvent?.id == null) {
            final res =
                await Provider.of<UniEventProvider>(context, listen: false)
                    .addEvent(event);
            if (res) {
              Navigator.of(context).pop();
              AppToast.show(S.current.messageEventAdded);
            }
          } else {
            final res =
                await Provider.of<UniEventProvider>(context, listen: false)
                    .updateEvent(event);
            if (res) {
              Navigator.of(context).popUntil(ModalRoute.withName(Routes.home));
              AppToast.show(S.current.messageEventEdited);
            }
          }
        },
      );

  AppScaffoldAction _deleteButton() => AppScaffoldAction(
        icon: Icons.more_vert_outlined,
        items: {
          S.current.actionDeleteEvent: () =>
              showDialog(context: context, builder: _deletionConfirmationDialog)
        },
        onPressed: () =>
            showDialog(context: context, builder: _deletionConfirmationDialog),
      );

  Widget timeIntervalPicker() {
    final endTime = startTime.add(duration);
    final textColor = Theme.of(context).textTheme.headline4.color;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              FeatherIcons.clock,
              color: Theme.of(context).formIconColor,
            ),
          ),
          TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
            ),
            onPressed: () async {
              final TimeOfDay start = await showTimePicker(
                context: context,
                initialTime: startTime.toTimeOfDay(),
              );
              setState(() => startTime = start.toLocalTime());
            },
            child: Text(
              startTime.toString('HH:mm'),
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Text(
                    duration.toString().replaceAll(RegExp(r'[PT]'), ''),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: textColor),
                  ),
                  DottedLine(
                    lineThickness: 4,
                    dashRadius: 2,
                    dashColor: textColor,
                  ),
                  // Text-sized box so that the line is centered
                  SizedBox(
                      height: Theme.of(context).textTheme.bodyText1.fontSize),
                ],
              ),
            ),
          ),
          TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
            ),
            onPressed: () async {
              final TimeOfDay end = await showTimePicker(
                context: context,
                initialTime: startTime.add(duration).toTimeOfDay(),
              );
              setState(() => duration =
                  Period.differenceBetweenTimes(startTime, end.toLocalTime()));
            },
            child: Text(
              endTime.toString('HH:mm'),
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _DayOfWeek extends time_machine.DayOfWeek with Localizable {
  const _DayOfWeek(int value) : super(value);

  _DayOfWeek.from(time_machine.DayOfWeek dayOfWeek) : super(dayOfWeek.value);

  @override
  String toLocalizedString() {
    final helperDate = LocalDate.today().next(this);
    return LocalDatePattern.createWithCurrentCulture('ddd')
        .format(helperDate)
        .substring(0, 3);
  }

  static const _DayOfWeek monday = _DayOfWeek(1);
  static const _DayOfWeek tuesday = _DayOfWeek(2);
  static const _DayOfWeek wednesday = _DayOfWeek(3);
  static const _DayOfWeek thursday = _DayOfWeek(4);
  static const _DayOfWeek friday = _DayOfWeek(5);
  static const _DayOfWeek saturday = _DayOfWeek(6);
  static const _DayOfWeek sunday = _DayOfWeek(7);
}

class WeekType with Localizable {
  const WeekType(this._value);

  final int _value;

  int get value => _value;

  static const WeekType odd = WeekType(0);
  static const WeekType even = WeekType(1);

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(dynamic other) =>
      other is WeekType && other._value == _value ||
      other is int && other == _value;

  @override
  String toLocalizedString() {
    switch (_value) {
      case 0:
        return S.current.labelOdd;
      case 1:
        return S.current.labelEven;
      default:
        return '';
    }
  }
}

extension LocalTimeConversion on LocalTime {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hourOfDay, minute: minuteOfHour);
}

extension TimeOfDayConversion on TimeOfDay {
  LocalTime toLocalTime() => LocalTime(hour, minute, 0);
}

extension LocalDateComparisons on LocalDate {
  bool isDuring(AllDayUniEvent semester) {
    return DateInterval(semester.startDate, semester.endDate).contains(this);
  }

  bool isBeforeOrDuring(AllDayUniEvent semester) {
    if (compareTo(semester.startDate) < 0) return true;
    return isDuring(semester);
  }
}
