import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:acs_upb_mobile/pages/timetable/view/events/event_view.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timetable/timetable.dart';

/// Widget to display all day events in the timetable, based on
/// [BasicEventWidget] from the timetable API.
class UniEventWidget extends StatelessWidget {
  const UniEventWidget(this.event, {Key key})
      : assert(event != null),
        super(key: key);

  final UniEventInstance event;

  @override
  Widget build(BuildContext context) {
    final color = event.color ??
        event?.mainEvent?.color ??
        Theme.of(context).primaryColor;
    final footer = (event.location?.isNotEmpty ?? false)
        ? event.id.toString().substring(20)
        : event.id.toString();

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<EventView>(
        builder: (_) => EventView(eventInstance: event),
      )),
      child: Material(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: 0.75,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        color: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
              child: AutoSizeText(
                event.title ?? event.mainEvent?.classHeader?.acronym ?? '',
                maxLines: 2,
                minFontSize: 4,
                maxFontSize: 12,
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color.highEmphasisOnColor,
                    ),
              ),
            ),
            if (event.mainEvent.type != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                  child: AutoSizeText(
                    event.mainEvent.type.toLocalizedString(context),
                    wrapWords: false,
                    minFontSize: 8,
                    maxFontSize: 10,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontSize: 10,
                          color: color.highEmphasisOnColor,
                        ),
                  ),
                ),
              ),
            Expanded(
              child: footer?.isNotEmpty ?? false
                  ? Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                        child: AutoSizeText(
                          footer,
                          maxLines: 1,
                          minFontSize: 10,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                fontSize: 12,
                                color: color.mediumEmphasisOnColor,
                              ),
                        ),
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
