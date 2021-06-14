//import 'package:auto_size_text/auto_size_text.dart';
//import 'package:black_hole_flutter/black_hole_flutter.dart';
//import 'package:flutter/material.dart';
//import 'package:time_machine/time_machine.dart';
//import 'package:time_machine/time_machine_text_patterns.dart';
//// ignore: implementation_imports
//import 'package:timetable/src/header/date_indicator.dart';
//// ignore: implementation_imports
//import 'package:timetable/src/theme.dart';
//// ignore: implementation_imports
//import 'package:timetable/src/utils/utils.dart';
//
//// TODO(IoanaAlexandru): This is a temporary fix because the default
//// [DateHeader] from the timetable package has an overflow when the culture
//// is set to Romanian. We copied it here with minor changes and it can be
//// removed once the timetable package has it fixed.
//class DateHeader extends StatelessWidget {
//  const DateHeader(this.date, {Key key}) : super(key: key);
//
//  final LocalDate date;
//
//  @override
//  Widget build(BuildContext context) {
//    return Column(
//      mainAxisSize: MainAxisSize.min,
//      crossAxisAlignment: CrossAxisAlignment.center,
//      children: <Widget>[
//        WeekdayIndicator(date),
//        const SizedBox(height: 4),
//        DateIndicator(date),
//      ],
//    );
//  }
//}
//
//class WeekdayIndicator extends StatelessWidget {
//  const WeekdayIndicator(this.date, {Key key}) : super(key: key);
//
//  final LocalDate date;
//
//  @override
//  Widget build(BuildContext context) {
//    final theme = context.theme;
//    final timetableTheme = context.timetableTheme;
//
//    final states = DateIndicator.statesFor(date);
//    final pattern = timetableTheme?.weekDayIndicatorPattern?.resolve(states) ??
//        LocalDatePattern.createWithCurrentCulture('ddd');
//    final decoration =
//        timetableTheme?.weekDayIndicatorDecoration?.resolve(states) ??
//            const BoxDecoration();
//    final textStyle =
//        timetableTheme?.weekDayIndicatorTextStyle?.resolve(states) ??
//            TextStyle(
//              color: date.isToday
//                  ? timetableTheme?.primaryColor ?? theme.primaryColor
//                  : theme.highEmphasisOnBackground,
//            );
//
//    return DecoratedBox(
//      decoration: decoration,
//      child: Padding(
//        padding: const EdgeInsets.all(4),
//        child: AutoSizeText(
//          pattern.format(date),
//          style: textStyle,
//          maxLines: 1,
//        ),
//      ),
//    );
//  }
//}
