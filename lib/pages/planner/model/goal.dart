import 'package:flutter/cupertino.dart';

class Goal {
  Goal({
    @required this.taskId,
    this.targetGrade,
    this.strategy,
  });
  final String taskId;
  final double targetGrade;
  final String strategy;
}
