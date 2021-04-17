import 'package:acs_upb_mobile/pages/planner/model/assignment.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dynamic_text_highlighting/dynamic_text_highlighting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'assignment_view.dart';

class AssignmentWidget extends StatelessWidget {
  const AssignmentWidget(this.event, this.filteredWords, {Key key})
      : assert(event != null),
        super(key: key);
  final Assignment event;
  final List<String> filteredWords;

  @override
  Widget build(BuildContext context) {
    final color = event.color ?? Theme.of(context).primaryColor;

    return GestureDetector(
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute<AssignmentView>(
              builder: (_) => AssignmentView(assignmentInstance: event),
            )),
        child: ListTile(
          key: ValueKey(event.name),
          title: filteredWords.isNotEmpty
              ? DynamicTextHighlighting(
                  text: event.name,
                  style: Theme.of(context).textTheme.subtitle1,
                  highlights: filteredWords,
                  color: Theme.of(context).accentColor,
                  caseSensitive: false,
                )
              : Text(
                  event.name,
                ),
          subtitle: Text('Deadline ${event?.endDate}'),
        ));
  }
}
