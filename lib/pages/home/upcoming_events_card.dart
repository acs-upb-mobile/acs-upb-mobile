//import 'package:acs_upb_mobile/generated/l10n.dart';
//import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
//import 'package:acs_upb_mobile/pages/timetable/service/uni_event_provider.dart';
//import 'package:acs_upb_mobile/pages/timetable/view/events/event_view.dart';
//import 'package:acs_upb_mobile/widgets/info_card.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//
//class UpcomingEventsCard extends StatelessWidget {
//  const UpcomingEventsCard({Key key, this.onShowMore}) : super(key: key);
//  final void Function() onShowMore;
//
//  @override
//  Widget build(BuildContext context) {
//    final UniEventProvider eventProvider =
//        Provider.of<UniEventProvider>(context);
//
//    return InfoCard<Iterable<UniEventInstance>>(
//      title: S.current.sectionEventsComingUp,
//      onShowMore: onShowMore,
//      future: eventProvider.getUpcomingEvents(DateTime),
//      builder: (events) => Column(
//        children: events
//            .map(
//              (event) => ListTile(
//                key: ValueKey(event.id),
//                contentPadding: EdgeInsets.zero,
//                leading: Padding(
//                  padding: const EdgeInsets.all(10),
//                  child: Container(
//                    width: 20,
//                    height: 20,
//                    decoration: BoxDecoration(
//                      borderRadius: const BorderRadius.all(Radius.circular(4)),
//                      color: event.mainEvent.color,
//                    ),
//                  ),
//                ),
//                trailing: event.start.isBefore(DateTime.now())
//                    ? Chip(label: Text(S.current.labelNow))
//                    : null,
//                title: Text(
//                  '${'${event.mainEvent.classHeader.acronym} - '}${event.mainEvent.type.toLocalizedString()}',
//                ),
//                subtitle: Text(event.relativeDateString),
//                onTap: () =>
//                    Navigator.of(context).push(MaterialPageRoute<EventView>(
//                  builder: (_) => EventView(eventInstance: event),
//                )),
//              ),
//            )
//            .toList(),
//      ),
//    );
//  }
//}
