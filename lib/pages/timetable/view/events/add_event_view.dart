import 'package:acs_upb_mobile/authentication/model/user.dart';
import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/navigation/routes.dart';
import 'package:acs_upb_mobile/pages/classes/model/class.dart';
import 'package:acs_upb_mobile/pages/classes/service/class_provider.dart';
import 'package:acs_upb_mobile/pages/filter/service/filter_provider.dart';
import 'package:acs_upb_mobile/pages/filter/view/relevance_picker.dart';
import 'package:acs_upb_mobile/pages/people/model/person.dart';
import 'package:acs_upb_mobile/pages/people/service/person_provider.dart';
import 'package:acs_upb_mobile/pages/timetable/model/academic_calendar.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/all_day_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/class_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/recurring_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/task_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:acs_upb_mobile/pages/timetable/service/uni_event_provider.dart';
import 'package:acs_upb_mobile/resources/custom_icons.dart';
import 'package:acs_upb_mobile/resources/locale_provider.dart';
import 'package:acs_upb_mobile/widgets/autocomplete.dart';
import 'package:acs_upb_mobile/widgets/button.dart';
import 'package:acs_upb_mobile/widgets/dialog.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/selectable.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
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
  TextEditingController nameController;
  TextEditingController gradeController;
  TextEditingController startDateController;
  TextEditingController hardDeadlineDateController;
  TextEditingController softDeadlineDateController;
  TextEditingController linkController;
  TextEditingController penaltiesController;
  RelevanceController relevanceController = RelevanceController();

  UniEventType selectedEventType;
  ClassHeader selectedClass;
  Person selectedTeacher;
  String selectedCalendar;
  LocalTime startTime;
  LocalDate startDate;
  LocalDate hardDeadlineDate;
  LocalDate softDeadlineDate;
  Period duration;
  bool hasSoftDeadline = false;
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
    nameController =
        TextEditingController(text: widget.initialEvent?.name ?? '');
    gradeController = TextEditingController(
        text: (widget.initialEvent is TaskEvent)
            ? (widget.initialEvent as TaskEvent)?.grade?.toString()
            : '0');
    penaltiesController = TextEditingController(
        text: (widget.initialEvent is TaskEvent)
            ? (widget.initialEvent as TaskEvent)?.penalties?.toString()
            : '0');
    linkController = TextEditingController(
        text: (widget.initialEvent is TaskEvent)
            ? (widget.initialEvent as TaskEvent)?.location
            : '');

    startDate = widget.initialEvent?.start?.calendarDate ?? LocalDate.today();
    startDateController =
        TextEditingController(text: startDate.toString('MMM d yyyy'));
    hardDeadlineDate = (widget.initialEvent is TaskEvent)
        ? (widget.initialEvent as TaskEvent).hardDeadline
        : LocalDate.today().addDays(14);
    hardDeadlineDateController =
        TextEditingController(text: hardDeadlineDate.toString('MMM d yyyy'));
    softDeadlineDate = (widget.initialEvent is TaskEvent)
        ? (widget.initialEvent as TaskEvent).softDeadline
        : LocalDate.today().addDays(7);
    softDeadlineDateController =
        TextEditingController(text: softDeadlineDate.toString('MMM d yyyy'));

    if ((widget.initialEvent is TaskEvent) &&
        (widget.initialEvent as TaskEvent).softDeadline != null &&
        (widget.initialEvent as TaskEvent).softDeadline !=
            (widget.initialEvent as TaskEvent).hardDeadline) {
      setState(() {
        hasSoftDeadline = true;
      });
    }
    final startHour = widget.initialEvent?.start?.hourOfDay ?? 8;
    duration = widget.initialEvent?.duration?.hours == 0
        ? const Period(hours: 2)
        : widget.initialEvent?.duration;
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

  Widget autocompleteLecturer(BuildContext context) {
    return Autocomplete<Person>(
      key: const Key('Autocomplete'),
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        textEditingController.text = selectedTeacher?.name;
        return TextFormField(
          controller: textEditingController,
          decoration: InputDecoration(
            labelText: S.current.labelLecturer,
            prefixIcon: const Icon(FeatherIcons.user),
          ),
          focusNode: focusNode,
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
        );
      },
      displayStringForOption: (Person person) => person.name,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '' || textEditingValue.text.isEmpty) {
          return const Iterable<Person>.empty();
        }
        if (classTeachers.where((Person person) {
          return person.name
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        }).isEmpty) {
          final List<Person> inputTeachers = [];
          final Person inputTeacher =
              Person(name: textEditingValue.text.titleCase);
          inputTeachers.add(inputTeacher);
          return inputTeachers;
        }

        return classTeachers.where((Person person) {
          return person.name
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (Person selection) {
        formKey.currentState.validate();
        setState(() {
          selectedTeacher = selection;
        });
      },
    );
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
                    controller: relevanceController,
                    validator: (_) {
                      if (relevanceController.customRelevance?.isEmpty ??
                          true) {
                        return S.current.warningYouNeedToSelectAtLeastOne;
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<UniEventType>(
                    decoration: InputDecoration(
                      labelText: S.current.labelType,
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    value: selectedEventType,
                    items: (UniEventTypeExtension.classTypes +
                            UniEventTypeExtension.assignmentsTypes)
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
                  if (UniEventTypeExtension.classTypes
                      .contains(selectedEventType))
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
                          autocompleteLecturer(context),
                        TextFormField(
                          controller: locationController,
                          decoration: InputDecoration(
                            labelText: S.current.labelLocation,
                            prefixIcon: const Icon(FeatherIcons.mapPin),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        timeIntervalPicker(),
                        if (weekSelected[WeekType.odd] != null &&
                            weekSelected[WeekType.even] != null)
                          SelectableFormField(
                            key: const ValueKey('week_picker'),
                            icon: FeatherIcons.calendar,
                            label: S.current.labelWeek,
                            initialValues: weekSelected,
                            validator: (selection) {
                              if (selection.values
                                  .where((e) => e != false)
                                  .isEmpty) {
                                return S
                                    .of(context)
                                    .warningYouNeedToSelectAtLeastOne;
                              }
                              return null;
                            },
                          ),
                        SelectableFormField(
                          key: const ValueKey('day_picker'),
                          icon: Icons.today_outlined,
                          label: S.current.labelDay,
                          initialValues: weekDaySelected,
                          validator: (selection) {
                            if (selection.values
                                .where((e) => e != false)
                                .isEmpty) {
                              return S
                                  .of(context)
                                  .warningYouNeedToSelectAtLeastOne;
                            }
                            return null;
                          },
                        ),
                      ],
                    )
                  else if (UniEventTypeExtension.assignmentsTypes
                      .contains(selectedEventType))
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
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: S.current.labelName,
                            hintText: S.current.hintAssignmentName,
                            prefixIcon: const Icon(Icons.title_outlined),
                          ),
                          validator: (value) {
                            return (value == '')
                                ? S.current.errorMissingTaskName
                                : null;
                          },
                          onChanged: (_) => setState(() {
                            formKey.currentState.validate();
                          }),
                        ),
                        TextFormField(
                          controller: linkController,
                          decoration: InputDecoration(
                            labelText: S.current.labelLink,
                            hintText: S.current.hintWebsiteLink,
                            prefixIcon: const Icon(Icons.link_outlined),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        TextFormField(
                          controller: gradeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'(^\d*\.?\d*)$')),
                          ],
                          decoration: InputDecoration(
                            labelText: S.current.sectionGrading,
                            hintText: '1.5',
                            prefixIcon: const Icon(FeatherIcons.pieChart),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        TextFormField(
                          controller: startDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: S.current.actionChooseStartDate,
                            prefixIcon: const Icon(Icons.today_outlined),
                          ),
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            // Show Date Picker Here
                            final DateTime startDay = await showDatePicker(
                              context: context,
                              firstDate:
                                  semester.startDate.toDateTimeUnspecified(),
                              initialDate: startDate.toDateTimeUnspecified(),
                              lastDate:
                                  semester.endDate.toDateTimeUnspecified(),
                            );

                            setState(() => {
                                  startDate =
                                      LocalDate.dateTime(startDay) ?? startDate,
                                  startDateController.text =
                                      startDate.toString('MMM d yyyy')
                                });
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        TextFormField(
                          controller: hardDeadlineDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: S.current.actionChooseHardDeadlineDate,
                            prefixIcon:
                                const Icon(Icons.insert_invitation_outlined),
                          ),
                          onTap: () async {
                            final DateTime endDay = await showDatePicker(
                              context: context,
                              firstDate: startDate.toDateTimeUnspecified(),
                              initialDate: hardDeadlineDate
                                          .toDateTimeUnspecified()
                                          .isAfter(startDate
                                              .toDateTimeUnspecified()) &&
                                      hardDeadlineDate
                                          .toDateTimeUnspecified()
                                          .isBefore(semester.endDate
                                              .toDateTimeUnspecified())
                                  ? hardDeadlineDate.toDateTimeUnspecified()
                                  : startDate.toDateTimeUnspecified(),
                              lastDate:
                                  semester.endDate.toDateTimeUnspecified(),
                            );
                            setState(() => {
                                  hardDeadlineDate =
                                      LocalDate.dateTime(endDay) ??
                                          hardDeadlineDate,
                                  hardDeadlineDateController.text =
                                      hardDeadlineDate.toString('MMM d yyyy')
                                });
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        CheckboxListTile(
                          contentPadding:
                              const EdgeInsets.only(top: 4, left: 4),
                          title: Text(
                            S.current.actionChooseHasSoftDeadline,
                            //style: Theme.of(context).textTheme.bodyText1.fontSize(14),
                          ),
                          selected: hasSoftDeadline,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: hasSoftDeadline,
                          onChanged: (bool hasSoftDeadlineValue) {
                            setState(() {
                              hasSoftDeadline = hasSoftDeadlineValue;
                            });
                          },
                        ),
                        Visibility(
                          visible: hasSoftDeadline,
                          child: TextFormField(
                            controller: softDeadlineDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: S.current.actionChooseSoftDeadlineDate,
                              hintText: S.current.actionChooseDates,
                              prefixIcon:
                                  const Icon(Icons.insert_invitation_outlined),
                            ),
                            onTap: () async {
                              final DateTime endDay = await showDatePicker(
                                context: context,
                                firstDate: startDate.toDateTimeUnspecified(),
                                initialDate: softDeadlineDate
                                            .toDateTimeUnspecified()
                                            .isAfter(startDate
                                                .toDateTimeUnspecified()) &&
                                        softDeadlineDate
                                            .toDateTimeUnspecified()
                                            .isBefore(hardDeadlineDate
                                                .toDateTimeUnspecified())
                                    ? softDeadlineDate.toDateTimeUnspecified()
                                    : startDate.toDateTimeUnspecified(),
                                lastDate:
                                    hardDeadlineDate.toDateTimeUnspecified(),
                              );
                              setState(() => {
                                    softDeadlineDate =
                                        LocalDate.dateTime(endDay) ??
                                            softDeadlineDate,
                                    softDeadlineDateController.text =
                                        softDeadlineDate.toString('MMM d yyyy')
                                  });
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        Visibility(
                            visible: hasSoftDeadline,
                            child: TextFormField(
                              controller: penaltiesController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'(^\d*\.?\d*)$')),
                              ],
                              decoration: InputDecoration(
                                labelText: S.current.messagePenalties,
                                hintText: '0.1',
                                prefixIcon:
                                    const Icon(Icons.assignment_late_outlined),
                              ),
                              onChanged: (_) => setState(() {}),
                            )),
                        //dayIntervalPicker(),
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

          UniEvent event;
          if (UniEventTypeExtension.classTypes.contains(selectedEventType)) {
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
                until:
                    semester.endDate.add(const Period(days: 1)).atMidnight());

            event = ClassEvent(
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
          } else if (UniEventTypeExtension.assignmentsTypes
              .contains(selectedEventType)) {
            event = TaskEvent(
                start: startDate,
                hardDeadline: hardDeadlineDate,
                softDeadline: hasSoftDeadline == true
                    ? softDeadlineDate
                    : hardDeadlineDate,
                id: widget.initialEvent?.id,
                relevance: relevanceController.customRelevance,
                degree: relevanceController.degree,
                name: nameController.text,
                type: selectedEventType,
                classHeader: selectedClass,
                grade: double.parse(gradeController.text),
                location: linkController.text,
                penalties: hasSoftDeadline == true
                    ? double.parse(penaltiesController.text)
                    : 0,
                calendar: calendars[selectedCalendar],
                addedBy: Provider.of<AuthProvider>(context, listen: false)
                    .currentUserFromCache
                    .uid);
          }
          if (event == null) return;

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
              color: CustomIcons.formIconColor(Theme.of(context)),
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

class RelevanceFormField extends FormField<List<String>> {
  RelevanceFormField({
    @required this.controller,
    String Function(List<String>) validator,
    Key key,
  }) : super(
          key: key,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          builder: (FormFieldState<List<String>> state) {
            controller.onChanged = () {
              state.didChange(controller.customRelevance);
            };
            final context = state.context;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RelevancePicker(
                  canBePrivate: false,
                  canBeForEveryone: false,
                  filterProvider: Provider.of<FilterProvider>(context),
                  controller: controller,
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      state.errorText,
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: Theme.of(context).errorColor),
                    ),
                  ),
              ],
            );
          },
        );

  final RelevanceController controller;
}

class SelectableFormField extends FormField<Map<Localizable, bool>> {
  SelectableFormField({
    @required Map<Localizable, bool> initialValues,
    @required IconData icon,
    @required String label,
    String Function(Map<Localizable, bool>) validator,
    Key key,
  }) : super(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          initialValue: initialValues,
          key: key,
          validator: validator,
          builder: (state) {
            final context = state.context;
            final labels = state.value.keys.toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, left: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(icon,
                            color:
                                CustomIcons.formIconColor(Theme.of(context))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .apply(
                                          color: Theme.of(context).hintColor),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      child: ListView.builder(
                                        itemCount: labels.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return Row(
                                            children: [
                                              Selectable(
                                                label: labels[index]
                                                    .toLocalizedString(),
                                                initiallySelected:
                                                    state.value[labels[index]],
                                                onSelected: (selected) {
                                                  state.value[labels[index]] =
                                                      selected;
                                                  state.didChange(state.value);
                                                },
                                              ),
                                              const SizedBox(width: 10),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      state.errorText,
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: Theme.of(context).errorColor),
                    ),
                  ),
              ],
            );
          },
        );
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
