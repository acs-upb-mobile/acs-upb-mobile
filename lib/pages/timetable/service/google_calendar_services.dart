//import 'package:acs_upb_mobile/pages/classes/model/class.dart';
//import 'package:acs_upb_mobile/pages/timetable/model/events/recurring_event.dart';
//import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
//import 'package:acs_upb_mobile/pages/timetable/service/uni_event_provider.dart';
//import 'package:acs_upb_mobile/resources/utils.dart';
//import 'package:acs_upb_mobile/widgets/toast.dart';
//import 'package:googleapis/calendar/v3.dart' as g_cal;
//import 'package:googleapis/calendar/v3.dart';
//import 'package:googleapis_auth/auth_io.dart';
//import 'package:acs_upb_mobile/generated/l10n.dart';
//
//class GoogleCalendarServices {
//  GoogleCalendarServices();
//
//  // allows us to see, edit, share, and permanently delete all the calendars you can access using GCal
//  static const List<String> _scopes = [CalendarApi.calendarScope];
//
//  static List<String> get scopes => _scopes;
//
//  // Our project IDs, used to identify an app to Google's OAuth servers.
//  static ClientId get credentials {
//    String _clientIdString;
//    if (Platform.isAndroid) {
//      _clientIdString =
//          '611150208061-4ftun8ln4v9hm1mocqs1vqcftaanj8sj.apps.googleusercontent.com';
//    } else if (Platform.isIOS) {
//      _clientIdString =
//          '611150208061-4ftun8ln4v9hm1mocqs1vqcftaanj8sj.apps.googleusercontent.com';
//    } else {
//      _clientIdString =
//          '611150208061-ljqdu5mfmjisdi1h3ics3l2sirvtpljk.apps.googleusercontent.com';
//    }
//    return ClientId(_clientIdString, '');
//  }
//}
//
//extension UniEventProviderGoogleCalendar on UniEventProvider {
//  g_cal.Event convertEvent(UniEvent uniEvent) {
//    final g_cal.Event googleCalendarEvent = g_cal.Event();
//
//    final g_cal.EventDateTime start = g_cal.EventDateTime();
//    final DateTime startDateTime = uniEvent.start.toDateTimeLocal();
//
//    start
//      ..timeZone = 'Europe/Bucharest'
//      // Google Calendar uses the IANA timezone format, but the native Dart `DateTime` uses an abbreviation provided by the operating system.
//      ..dateTime = startDateTime;
//
//    final Duration duration = uniEvent.duration.toDuration();
//
//    final g_cal.EventDateTime end = g_cal.EventDateTime();
//    final DateTime endDateTime = startDateTime.add(duration);
//    end
//      ..timeZone = 'Europe/Bucharest'
//      ..dateTime = endDateTime;
//
//    final ClassHeader classHeader = uniEvent.classHeader;
//
//    googleCalendarEvent
//      ..start = start
//      ..end = end
//      ..summary = classHeader.acronym
//      ..colorId = (uniEvent.type.googleCalendarColor.index).toString()
//      ..location = uniEvent.location;
//
//    if (uniEvent is RecurringUniEvent) {
//      final String rruleBasedOnCalendarString = uniEvent.rruleBasedOnCalendar
//          .toString()
//          .replaceAll(RegExp(r'T000000'), 'T000000Z');
//      googleCalendarEvent.recurrence = [rruleBasedOnCalendarString];
//    }
//
//    return googleCalendarEvent;
//  }
//
//  // This opens a browser window asking the user to authenticate and allow access to edit their calendar
//  Future<void> insertGoogleEvents(
//      List<g_cal.Event> googleCalendarEvents) async {
//    AutoRefreshingAuthClient client;
//    try {
//      client = await clientViaUserConsent(GoogleCalendarServices.credentials,
//          GoogleCalendarServices.scopes, Utils.launchURL);
//      final g_cal.CalendarApi calendarApi = g_cal.CalendarApi(client);
//      final g_cal.Calendar calendar = g_cal.Calendar()
//        ..timeZone = 'Europe/Bucharest'
//        ..summary = 'ACS UPB Mobile'
//        ..description = 'Timetable imported from ACS UPB Mobile';
//
//      g_cal.CalendarList calendarListNonIterable;
//      calendarListNonIterable = await calendarApi.calendarList.list();
//
//      final List<g_cal.CalendarListEntry> calendarList =
//          calendarListNonIterable.items;
//      for (final g_cal.CalendarListEntry calendar in calendarList) {
//        if (calendar.summary == 'ACS UPB Mobile') {
//          await calendarApi.calendars.delete(calendar.id);
//          break;
//        }
//      }
//
//      final g_cal.Calendar returnedCalendar =
//          await calendarApi.calendars.insert(calendar);
//
//      if (returnedCalendar is g_cal.Calendar) {
//        final String calendarId = returnedCalendar.id;
//        for (final g_cal.Event event in googleCalendarEvents) {
//          await calendarApi.events.insert(event, calendarId).then(
//            (value) {
//              print('Added event status: ${value.status}');
//              if (value.status == 'confirmed') {
//                print('Event named ${event.summary} added in Google Calendar');
//              } else {
//                print(
//                    'Unable to add event named ${event.summary} in Google Calendar');
//              }
//            },
//          );
//        }
//      }
//    } catch (e) {
//      AppToast.show(S.current.errorInsertGoogleEvents);
//      print('Error $e when inserting GCal events.');
//      return;
//    }
//  }
//}
//
//enum GoogleCalendarColorNames {
//  undefined,
//  lavender,
//  sage,
//  grape,
//  flamingo,
//  banana,
//  tangerine,
//  peacock,
//  graphite,
//  blueberry,
//  basil,
//  tomato
//}
//
//extension UniEventTypeGCalColor on UniEventType {
//  GoogleCalendarColorNames get googleCalendarColor {
//    switch (this) {
//      case UniEventType.lecture:
//        return GoogleCalendarColorNames.flamingo;
//      case UniEventType.lab:
//        return GoogleCalendarColorNames.peacock;
//      case UniEventType.seminar:
//        return GoogleCalendarColorNames.banana;
//      case UniEventType.sports:
//        return GoogleCalendarColorNames.basil;
//      case UniEventType.semester:
//        return GoogleCalendarColorNames.undefined;
//      case UniEventType.holiday:
//        return GoogleCalendarColorNames.grape;
//      case UniEventType.examSession:
//        return GoogleCalendarColorNames.tomato;
//      default:
//        return GoogleCalendarColorNames.undefined;
//    }
//  }
//}
