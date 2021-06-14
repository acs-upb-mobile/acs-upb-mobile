import 'package:acs_upb_mobile/pages/timetable/service/uni_event_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassEventsCard extends StatefulWidget {
  const ClassEventsCard(this.currentClassId, {Key key}) : super(key: key);
  final String currentClassId;

  @override
  _ClassEventsCardState createState() => _ClassEventsCardState();
}

class _ClassEventsCardState extends State<ClassEventsCard> {
  @override
  Widget build(BuildContext context) {
    final UniEventProvider eventProvider =
        Provider.of<UniEventProvider>(context);

    return Container();
//    return InfoCard<Iterable<UniEvent>>(
//      title: S.of(context).sectionEvents,
//      padding: EdgeInsets.zero,
//      future: eventProvider.getAllEventsOfClass(widget.currentClassId),
//      builder: (events) => Column(
//        children: events
//            .map(
//              (event) => EventListTile(
//                uniEvent: event,
//              ),
//            )
//            .toList(),
//      ),
//    );
  }
}
