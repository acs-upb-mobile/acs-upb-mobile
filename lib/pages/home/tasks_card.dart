import 'package:acs_upb_mobile/pages/planner/view/planner_view.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:acs_upb_mobile/pages/timetable/service/uni_event_provider.dart';
import 'package:acs_upb_mobile/widgets/event_instance_list_tile.dart';
import 'package:acs_upb_mobile/widgets/info_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';

class TasksCard extends StatelessWidget {
  const TasksCard({Key key, this.onShowMore}) : super(key: key);
  final void Function() onShowMore;

  @override
  Widget build(BuildContext context) {
    final UniEventProvider eventProvider =
        Provider.of<UniEventProvider>(context);
    return InfoCard<Iterable<UniEventInstance>>(
      title: S.current.sectionPlanner,
      onShowMore: () =>
          Navigator.of(context).push(MaterialPageRoute<PlannerView>(
        builder: (_) => const PlannerView(),
      )),
      future: eventProvider.getAssignments(),
      builder: (events) => Column(
        children: events
            .map(
              (event) => EventInstanceListTile(eventInstance: event),
            )
            .toList(),
      ),
    );
  }
}
