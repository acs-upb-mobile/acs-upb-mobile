import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/classes/service/class_provider.dart';
import 'package:acs_upb_mobile/pages/classes/view/class_view.dart';
import 'package:acs_upb_mobile/pages/classes/view/classes_page.dart';
import 'package:acs_upb_mobile/pages/filter/model/filter.dart';
import 'package:acs_upb_mobile/pages/filter/service/filter_provider.dart';
import 'package:acs_upb_mobile/pages/people/view/person_view.dart';
import 'package:acs_upb_mobile/pages/planner/service/planner_provider.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/class_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/task_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:acs_upb_mobile/pages/timetable/view/events/add_event_view.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';

class EventView extends StatefulWidget {
  const EventView({Key key, this.eventInstance, this.uniEvent})
      : assert(
            (eventInstance != null && uniEvent == null) ||
                (eventInstance == null && uniEvent != null),
            'Only one of the parameters must be provided'),
        super(key: key);
  final UniEventInstance eventInstance;
  final UniEvent uniEvent;

  @override
  _EventViewState createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  List<String> hiddenEvents;
  bool updating;

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

  Padding _colorIcon() => Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              color: widget.uniEvent?.color ?? widget.eventInstance.color),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUserFromCache;
    final UniEvent mainEvent =
        widget.eventInstance?.mainEvent ?? widget.uniEvent;
    return AppScaffold(
      title: Text(S.current.navigationEventDetails),
      actions: [
        if (mainEvent is TaskEvent)
          AppScaffoldAction(
            icon: !(hiddenEvents != null && hiddenEvents.contains(mainEvent.id))
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onPressed: () async {
              bool res;
              if (hiddenEvents != null && hiddenEvents.contains(mainEvent.id)) {
                hiddenEvents.remove(mainEvent.id);
                res = await Provider.of<PlannerProvider>(context, listen: false)
                    .setUserHiddenEvents(hiddenEvents, user.uid);
                if (res != null) {
                  await updateHiddenEvents();
                  AppToast.show(S.current.messageEventShowSuccessfully);
                }
              } else {
                hiddenEvents ??= <String>[];
                hiddenEvents.add(mainEvent.id);
                res = await Provider.of<PlannerProvider>(context, listen: false)
                    .setUserHiddenEvents(hiddenEvents, user.uid);
                if (res != null) {
                  await updateHiddenEvents();
                  AppToast.show(S.current.messageEventHiddenSuccessfully);
                }
              }
            },
          ),
        AppScaffoldAction(
          icon: Icons.edit_outlined,
          disabled: !mainEvent.editable || !user.canAddPublicInfo,
          onPressed: () {
            if (!mainEvent.editable) {
              AppToast.show(S.current.warningEventNotEditable);
            } else if (!user.canAddPublicInfo) {
              AppToast.show(S.current.errorPermissionDenied);
            } else {
              Navigator.of(context).push(MaterialPageRoute<AddEventView>(
                builder: (_) => ChangeNotifierProvider<FilterProvider>(
                  create: (_) => FilterProvider(
                    defaultDegree: mainEvent.degree,
                    defaultRelevance: mainEvent.relevance,
                  ),
                  child: AddEventView(
                    initialEvent: mainEvent,
                  ),
                ),
              ));
            }
          },
        )
      ],
      body: SafeArea(
        child: ListView(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                _colorIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          widget.eventInstance?.title ??
                              mainEvent.name ??
                              mainEvent.type.toLocalizedString(),
                          style: Theme.of(context).textTheme.headline6),
                      const SizedBox(height: 4),
                      if (widget.eventInstance != null)
                        Text(widget.eventInstance.dateString),
                      if (mainEvent.info != widget.eventInstance?.dateString)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            mainEvent.info,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(color: Theme.of(context).hintColor),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (mainEvent?.classHeader != null)
            ClassListItem(
              classHeader: mainEvent.classHeader,
              hint: S.current.messageTapForMoreInfo,
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute<ChangeNotifierProvider>(
                builder: (context) => ChangeNotifierProvider.value(
                  value: Provider.of<ClassProvider>(context),
                  child: ClassView(classHeader: mainEvent.classHeader),
                ),
              )),
            ),
          if (widget.eventInstance?.location?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(FeatherIcons.mapPin),
                  ),
                  const SizedBox(width: 16),
                  Text(widget.eventInstance?.location,
                      style: Theme.of(context).textTheme.subtitle1),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(FeatherIcons.users),
                ),
                const SizedBox(width: 16),
                Text(
                    mainEvent.relevance == null
                        ? S.current.relevanceAnyone
                        : '${FilterNode.localizeName(mainEvent.degree, context)}: ${mainEvent.relevance.join(', ')}',
                    style: Theme.of(context).textTheme.subtitle1),
              ],
            ),
          ),
          if (mainEvent is ClassEvent)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: GestureDetector(
                onTap: () {
                  if (mainEvent.teacher != null) {
                    showModalBottomSheet<dynamic>(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext buildContext) =>
                            PersonView(person: mainEvent.teacher));
                  }
                },
                child: Row(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(FeatherIcons.user),
                    ),
                    const SizedBox(width: 16),
                    Text(mainEvent.teacher.name ?? S.current.labelUnknown,
                        style: Theme.of(context).textTheme.subtitle1),
                  ],
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
