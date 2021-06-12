import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:acs_upb_mobile/pages/timetable/view/events/event_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';

class EventInstanceListTile extends StatelessWidget {
  const EventInstanceListTile({
    this.eventInstance,
  });

  final UniEventInstance eventInstance;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(eventInstance.id),
      contentPadding: EdgeInsets.zero,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              color: eventInstance.hidden == false
                  ? eventInstance.end.toDateTimeLocal().isAfter(DateTime.now())
                      ? eventInstance.mainEvent.color
                      : Colors.grey.shade600
                  : eventInstance.mainEvent.color.withAlpha(20)),
        ),
      ),
      trailing:
          eventInstance.start.toDateTimeLocal().isBefore(DateTime.now()) &&
                  eventInstance.end.toDateTimeLocal().isAfter(DateTime.now())
              ? Chip(label: Text(S.current.labelOngoing))
              : null,
      title: Text(
        '${'${eventInstance.title} - '}${eventInstance.mainEvent.type.toLocalizedString()}',
      ),
      subtitle: Text(eventInstance.relativeDateString),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<EventView>(
          builder: (_) => EventView(eventInstance: eventInstance),
        ),
      ),
    );
  }
}
