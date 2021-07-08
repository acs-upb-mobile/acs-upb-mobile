import 'package:acs_upb_mobile/pages/planner/model/goal.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/task_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/src/localdate.dart';
import 'package:time_machine/time_machine.dart';

class GoalView extends StatelessWidget {
  const GoalView({Key key, this.goal, this.event}) : super(key: key);
  final Goal goal;
  final TaskEvent event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: goal == null
          ? const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
              ),
            )
          : Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Target Grade',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(fontSize: 16),
                                      overflow: TextOverflow.fade,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ListTile(
                                key: ValueKey('Target goal'),
                                title: Text(
                                  goal.targetGrade.toString(),
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    //const Spacer(flex: 1),
                    Flexible(
                      flex: 3,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Strategy',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(fontSize: 18),
                                      overflow: TextOverflow.fade,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ListTile(
                                key: const ValueKey('Strategy'),
                                title: Text(
                                  goal.strategy ?? 'No strategy selected yet',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Indications',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(fontSize: 18),
                                      overflow: TextOverflow.fade,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ListTile(
                                key: const ValueKey('Indications'),
                                title: goal.strategy == 'Constant'
                                    ? Text(
                                        '-> ${(goal.targetGrade / 4).toStringAsFixed(1)} points by ${getMiddleBetweenDates(4)} \n'
                                        '-> ${(goal.targetGrade / 2).toStringAsFixed(1)} points by ${getMiddleBetweenDates(2)} \n'
                                        '-> ${(goal.targetGrade * (3 / 4)).toStringAsFixed(1)} points by ${getMiddleBetweenDates(4 / 3)} \n'
                                        '-> ${(goal.targetGrade / 1).toStringAsFixed(1)} points by ${getMiddleBetweenDates(1)} \n',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      )
                                    : goal.strategy == 'Early'
                                        ? Text(
                                            '-> ${(goal.targetGrade / 3).toStringAsFixed(1)} points by ${getMiddleBetweenDates(4)} \n'
                                            '-> ${(goal.targetGrade * (2 / 3)).toStringAsFixed(1)} points by ${getMiddleBetweenDates(2)} \n'
                                            '-> ${(goal.targetGrade * 1).toStringAsFixed(1)} points by ${getMiddleBetweenDates(4 / 3)} \n',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6,
                                          )
                                        : Text(
                                            '-> ${(goal.targetGrade / 3).toStringAsFixed(1)} points by ${getMiddleBetweenDates(2)} \n'
                                            '-> ${(goal.targetGrade * (2 / 3)).toStringAsFixed(1)} points by ${getMiddleBetweenDates(4 / 3)} \n'
                                            '-> ${(goal.targetGrade / 1).toStringAsFixed(1)} points by ${getMiddleBetweenDates(1)} \n',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6,
                                          ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    //const Spacer(flex: 1),
                    // Flexible(
                    //   flex: 6,
                    //   child: Card(
                    //     // height: 200,
                    //
                    //     child: Text(
                    //       goal.taskId,
                    //       textScaleFactor: 2,
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ],
            ),
    );
  }

  String getMiddleBetweenDates(double div) {
    Period diff = LocalDate.difference(event.softDeadline, event.startDate);
    return event.startDate
        .addDays(((diff.days + diff.weeks * 7 + diff.months * 30) / div).ceil())
        .toString('dd MMM');
  }
}
