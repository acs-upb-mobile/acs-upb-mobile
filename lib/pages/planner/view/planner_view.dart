import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/pages/planner/service/planner_provider.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:acs_upb_mobile/pages/timetable/service/uni_event_provider.dart';
import 'package:acs_upb_mobile/widgets/effort_graph.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/tasks_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';

class PlannerView extends StatefulWidget {
  const PlannerView({Key key}) : super(key: key);

  @override
  _PlannerViewState createState() => _PlannerViewState();
}

class _PlannerViewState extends State<PlannerView> {
  List<String> hiddenEvents;
  bool updating;
  Iterable<UniEventInstance> assignments;

  Future<void> updateHiddenEvents() async {
    // If updating is null, hiddenEvents haven't been initialized yet so they're not
    // technically "updating"
    if (updating != null) {
      updating = true;
    }

    final PlannerProvider plannerProvider =
        Provider.of<PlannerProvider>(context, listen: false);
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    hiddenEvents =
        await plannerProvider.fetchUserHiddenEvents(authProvider.uid);

    updating = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    updateHiddenEvents();
  }

  @override
  Widget build(BuildContext context) {
    final UniEventProvider eventProvider =
        Provider.of<UniEventProvider>(context);

    Iterable<UniEventInstance> _currentEvents() => assignments.where((event) =>
        event.hidden == false &&
        event.end.toDateTimeLocal().isAfter(DateTime.now()));

    Iterable<UniEventInstance> _hiddenEvents() =>
        assignments.where((event) => event.hidden == true);

    Iterable<UniEventInstance> _pastEvents() => assignments.where((event) =>
        event.hidden == false &&
        event.end.toDateTimeLocal().isBefore(DateTime.now()));

    Iterable<UniEventInstance> _visibleEvents() =>
        assignments.where((event) => event.hidden == false);

    return AppScaffold(
      title: Text(S.current.sectionPlanner),
      body: FutureBuilder(
          future: eventProvider.getAssignments(limit: 100, retrievePast: true),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              assignments = snapshot.data;
              return SingleChildScrollView(
                physics: const ScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    EffortGraph(
                      events: _visibleEvents().toList(),
                      title: S.current.sectionEffortGraph,
                      isExpanded: true,
                    ),
                    const SizedBox(width: 16),
                    TasksList(
                      events: _currentEvents().toList(),
                      title: S.current.labelComingUp,
                      isExpanded: true,
                    ),
                    const SizedBox(width: 16),
                    TasksList(
                      events: _hiddenEvents().toList(),
                      title: S.current.labelHidden,
                    ),
                    const SizedBox(width: 16),
                    TasksList(
                      events: _pastEvents().toList(),
                      title: S.current.labelPast,
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
