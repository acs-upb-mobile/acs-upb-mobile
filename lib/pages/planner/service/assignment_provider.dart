import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/people/service/person_provider.dart';
import 'package:acs_upb_mobile/pages/planner/model/assignment.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:acs_upb_mobile/pages/classes/service/class_provider.dart';

extension AssignmentExtension on Assignment {
  static List<Assignment> _assignmentsFromMapList(
          List<dynamic> list, String type) =>
      List<Assignment>.from((list ?? []).asMap().map((index, e) {
        return MapEntry(
            index, AssignmentExtension.fromSnap(type + index.toString(), e));
      }).values);

  static Assignment fromSnap(String index, Map<String, dynamic> json) {
    return Assignment(
        id: index,
        type: UniEventTypeExtension.fromString(json['type']),
        name: json['name'],
        // Convert time to UTC and then to local time
        start: (json['start'] as Timestamp).toLocalDateTime().calendarDate,
        end: (json['end'] as Timestamp).toLocalDateTime().calendarDate,
        addedBy: json['addedBy']);
  }
}

class AssignmentProvider with ChangeNotifier {
  AssignmentProvider({AuthProvider authProvider, PersonProvider personProvider})
      : _authProvider = authProvider ?? AuthProvider(),
        _personProvider = personProvider ?? PersonProvider();

  final AuthProvider _authProvider;
  final PersonProvider _personProvider;
  Future<List<Assignment>> fetchAssignments({BuildContext context}) async {
    try {
      final QuerySnapshot qSnapshot = await FirebaseFirestore.instance
          .collection('calendars')
          //.collection('events')
          //.where('type', isEqualTo: 'assignment')
          //.collection('assignments')
          .get();
      final data = qSnapshot.docs[0].data();
      final list = data['assignments'];
      return AssignmentExtension._assignmentsFromMapList(
          data['assignments'], 'assignment');
    } catch (e) {
      print(e);
      if (context != null) {
        AppToast.show(S.of(context).errorSomethingWentWrong);
      }
      return null;
    }
  }

  // Future<bool> updateAssignment(Assignment event,
  //     {BuildContext context}) async {
  //   try {
  //     final ref =
  //         FirebaseFirestore.instance.collection('calendars').doc(event.id);
  //
  //     if ((await ref.get()).data == null) {
  //       print('Assignment not found.');
  //       return false;
  //     }
  //
  //     await ref.update(event.toData());
  //     notifyListeners();
  //     return true;
  //   } catch (e) {
  //     _errorHandler(e, context);
  //     return false;
  //   }
  // }
}
