import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/pages/filter/service/filter_provider.dart';
import 'package:acs_upb_mobile/pages/planner/model/assignment.dart';
import 'package:acs_upb_mobile/pages/timetable/view/events/add_event_view.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AssignmentView extends StatefulWidget {
  const AssignmentView({Key key, this.assignmentInstance}) : super(key: key);
  final Assignment assignmentInstance;
  @override
  _AssignmentViewState createState() => _AssignmentViewState();
}

class _AssignmentViewState extends State<AssignmentView> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        title: Text(S.of(context).navigationAssignmentDetails),
        actions: [
          AppScaffoldAction(
              icon: Icons.edit,
              onPressed: () {
                final user = Provider.of<AuthProvider>(context, listen: false)
                    .currentUserFromCache;
                if (user.canAddPublicInfo) {
                  Navigator.of(context).push(MaterialPageRoute<AddEventView>(
                    builder: (_) => ChangeNotifierProvider<FilterProvider>(
                      create: (_) => FilterProvider(),
                      child: AddEventView(
                        initialEvent: widget.assignmentInstance,
                      ),
                    ),
                  ));
                } else {
                  AppToast.show(S.of(context).errorPermissionDenied);
                }
              })
        ],
        body: SafeArea(child: Text(widget.assignmentInstance.id)));
  }
}
