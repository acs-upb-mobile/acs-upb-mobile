import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/planner/model/assignment.dart';
import 'package:acs_upb_mobile/pages/planner/service/assignment_provider.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/search_bar.dart';
import 'package:dynamic_text_highlighting/dynamic_text_highlighting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({Key key}) : super(key: key);

  @override
  _PlannerPageState createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  String filter = '';
  bool searchClosed = true;
  Future<List<Assignment>> assignemnts;
  List<Assignment> assignemntsData;

  @override
  void initState() {
    super.initState();
    final assignmentProvider =
        Provider.of<AssignmentProvider>(context, listen: false);
    assignemnts = assignmentProvider.fetchAssignments(context: context);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AppScaffold(
      actions: [
        AppScaffoldAction(
          icon: Icons.search,
          onPressed: () {
            setState(() => searchClosed = !searchClosed);
          },
        )
      ],
      title: Text(S.of(context).navigationPlanner),
      body: Container(
        child: FutureBuilder(
            future: assignemnts,
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                assignemntsData = snapshot.data;
                return Column(
                  children: [
                    SearchWidget(
                      onSearch: (searchText) {
                        setState(() => filter = searchText);
                      },
                      cancelCallback: () {
                        setState(() {
                          searchClosed = true;
                          filter = '';
                        });
                      },
                      searchClosed: searchClosed,
                    ),
                    Expanded(
                        child: AssignmentsList(
                            assignments: filteredAssignments, filter: filter))
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }

  List<Assignment> get filteredAssignments => assignemntsData
      .where((assignment) => filter.split(' ').fold(
          true,
          (previousValue, filter) =>
              assignment.name != null &&
              previousValue &&
              assignment.name.toLowerCase().contains(filter.toLowerCase())))
      .toList();
}

class AssignmentsList extends StatefulWidget {
  const AssignmentsList({this.assignments, this.filter});
  final List<Assignment> assignments;
  final String filter;

  @override
  _AssignmentsListState createState() => _AssignmentsListState();
}

class _AssignmentsListState extends State<AssignmentsList> {
  @override
  Widget build(BuildContext context) {
    final List<String> filteredWords = widget.filter
        .toLowerCase()
        .split(' ')
        .where((element) => element != '')
        .toList();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.assignments.length,
        itemBuilder: (context, index) {
          return ListTile(
            key: ValueKey(widget.assignments[index].name),
            title: filteredWords.isNotEmpty
                ? DynamicTextHighlighting(
                    text: widget.assignments[index].name,
                    style: Theme.of(context).textTheme.subtitle1,
                    highlights: filteredWords,
                    color: Theme.of(context).accentColor,
                    caseSensitive: false,
                  )
                : Text(
                    widget.assignments[index].name,
                  ),
            subtitle: Text('Deadline ${widget.assignments[index]?.endDate}'),
          );
        },
      ),
    );
  }
}
