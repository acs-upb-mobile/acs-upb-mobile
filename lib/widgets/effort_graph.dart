import 'dart:math';

import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiver/time.dart';
import 'package:time_machine/time_machine.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';

class EffortGraph extends StatefulWidget {
  const EffortGraph({
    @required this.events,
    this.title,
    this.isExpanded,
  });
  final List<UniEventInstance> events;
  final String title;
  final bool isExpanded;

  @override
  _EffortGraphState createState() => _EffortGraphState();
}

class _EffortGraphState extends State<EffortGraph>
    with SingleTickerProviderStateMixin {
  bool isExpanded;
  AnimationController expandController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded ?? false;
    prepareAnimations();
    _runExpandCheck();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.fastOutSlowIn,
    );
  }

  void _runExpandCheck() {
    if (isExpanded == true) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(EffortGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.events.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              key: ValueKey(widget.title),
              contentPadding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
              onTap: () => {
                setState(() {
                  isExpanded = !isExpanded;
                }),
                _runExpandCheck(),
              },
              trailing: widget.events.isEmpty
                  ? const Icon(Icons.remove_outlined)
                  : isExpanded
                      ? const Icon(Icons.arrow_drop_down_outlined)
                      : const Icon(
                          Icons.arrow_right_outlined,
                        ),
              title: Text(
                widget.title,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          );
        } else if (index == 1) {
          return Visibility(
            visible: isExpanded,
            child: SizeTransition(
              axisAlignment: 1,
              sizeFactor: animation,
              child: AspectRatio(
                aspectRatio: 1.7,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 18, left: 0, top: 24, bottom: 12),
                    child: LineChart(
                      mainData(),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Visibility(
            visible: false,
            child: ListTile(),
          );
        }
      },
    );
  }

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return LocalDateTime.now()
                    .add(Period(months: 2))
                    .subtract(Period(months: 4))
                    .toString('MMM');
              case 4:
                return LocalDateTime.now()
                    .add(Period(months: 2))
                    .subtract(Period(months: 3))
                    .toString('MMM');
              case 8:
                return LocalDateTime.now()
                    .add(Period(months: 2))
                    .subtract(Period(months: 2))
                    .toString('MMM');
              case 12:
                return LocalDateTime.now()
                    .add(Period(months: 2))
                    .subtract(Period(months: 1))
                    .toString('MMM');
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '1';
              case 2:
                return '2';
              case 3:
                return '3';
              case 4:
                return '4';
              case 5:
                return '5';
              case 8:
                return '8';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 13,
      minY: 0,
      maxY: max(maxTasks() + 1, 3),
      lineBarsData: [
        generateGraph(),
      ],
    );
  }

  double dateToNumber(LocalDateTime date) {
    return double.parse(
        ((date.dayOfMonth / daysInMonth(date.year, date.monthOfYear)) * 4 +
                4 * (date.monthOfYear - 3))
            .toStringAsFixed(2));
  }

  double maxTasks() {
    int effort = 0;
    int maxEffort = 0;
    List<double> start = [];
    List<double> end = [];
    int i = 0;
    int j = 0;
    for (final UniEventInstance event in widget.events) {
      start.add(dateToNumber(event.mainEvent.start));
      end.add(dateToNumber(event.end));
    }
    end.sort();
    while (i < widget.events.length || j < widget.events.length) {
      if (i < widget.events.length && start[i] <= end[j]) {
        effort++;
        if (effort > maxEffort) {
          maxEffort = effort;
        }
        i++;
      } else if (i == widget.events.length ||
          (j < widget.events.length && end[j] <= start[i])) {
        effort--;
        j++;
      } else {
        i++;
        j++;
      }
    }
    return maxEffort * 1.0;
  }

  LineChartBarData generateGraph() {
    int effort = 0;
    List<double> start = [];
    List<double> end = [];
    List<FlSpot> points = [FlSpot(0, 0)];
    int i = 0;
    int j = 0;
    for (final UniEventInstance event in widget.events) {
      start.add(dateToNumber(event.mainEvent.start));
      end.add(dateToNumber(event.end));
    }
    end.sort();
    if (widget.events.length > 0) points.add(FlSpot(0, 0));
    while (i < widget.events.length || j < widget.events.length) {
      if (i < widget.events.length && start[i] <= end[j]) {
        effort++;
        points.add(FlSpot(start[i] - 0.05, (effort - 1) * 1.0));
        points.add(FlSpot(start[i], effort * 1.0));
        i++;
      } else if (i == widget.events.length ||
          (j < widget.events.length && end[j] <= start[i])) {
        effort--;
        points.add(FlSpot(end[j] - 0.05, (effort + 1) * 1.0));
        points.add(FlSpot(end[j], effort * 1.0));
        j++;
      } else {
        i++;
        j++;
      }
    }
    points.add(FlSpot(13, 0));

    return LineChartBarData(
      spots: points,
      isCurved: false,
      colors: gradientColors,
      barWidth: 5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: true,
        colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
      ),
    );
  }
}
