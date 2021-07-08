import 'package:acs_upb_mobile/pages/planner/model/goal.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';

extension GoalExtension on Goal {
  static List<Goal> fromSnap(DocumentSnapshot snap) {
    final data = snap?.data();
    if (data == null) return null;
    final List<Goal> goalList = [];

    for (final goalData in data['taskGoals']) {
      goalList.add(Goal(
          taskId: goalData['taskId'],
          targetGrade: double.parse(goalData['targetGrade'].toString()),
          strategy: goalData['strategy']));
    }
    return goalList;
  }

  static Goal goalFromSnap(DocumentSnapshot snap, String taskId) {
    final data = GoalExtension.fromSnap(snap);
    if (data == null) return null;
    return data.firstWhere((goal) => goal.taskId == taskId, orElse: () => null);
  }

  Map<String, dynamic> toData() {
    final json = {
      'targetGrade': targetGrade,
      'taskId': taskId,
      'strategy': strategy
    };
    return json;
  }
}

class PlannerProvider with ChangeNotifier {
  Future<List<String>> fetchUserHiddenEvents(String uid) async {
    try {
      final DocumentSnapshot snap =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snap.data() == null) {
        return [];
      }
      return List<String>.from(snap.data()['hiddenEvents'] ?? []);
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return null;
    }
  }

  Future<bool> setUserHiddenEvents(
      List<String> hiddenEvents, String uid) async {
    try {
      final DocumentReference ref =
          FirebaseFirestore.instance.collection('users').doc(uid);
      await ref.update({'hiddenEvents': hiddenEvents});
      notifyListeners();
      return true;
    } catch (e) {
      AppToast.show(S.current.errorSomethingWentWrong);
      return false;
    }
  }

  Future<Goal> fetchGoal(String uid, String taskId) async {
    try {
      // Get class with id [classId]
      final QuerySnapshot query = await FirebaseFirestore.instance
          .collection('goals')
          .where('addedBy', isEqualTo: uid)
          .limit(1)
          .get();

      if (query == null || query.docs.isEmpty) {
        return null;
      }

      return GoalExtension.goalFromSnap(query.docs.first, taskId);
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return null;
    }
  }

  Future<bool> setUserGoal(String uid, Goal goal) async {
    try {
      // Get class with id [classId]
      final QuerySnapshot query = await FirebaseFirestore.instance
          .collection('goals')
          .where('addedBy', isEqualTo: uid)
          .limit(1)
          .get();

      if (query == null || query.docs.isEmpty) {
        return addFirstUserGoal(uid, goal);
      }

      return updateUserGoals(uid, query.docs.first, goal);
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return null;
    }
  }

  Future<bool> addFirstUserGoal(String uid, Goal goal) async {
    try {
      await FirebaseFirestore.instance.collection('goals').add({
        'addedBy': uid,
        'taskGoals': [goal.toData()]
      });
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return false;
    }
  }

  Future<bool> updateUserGoals(
      String uid, DocumentSnapshot snap, Goal goal) async {
    try {
      final data = GoalExtension.fromSnap(snap);
      final ref = FirebaseFirestore.instance.collection('goals').doc(snap.id);
      final int index =
          data.indexWhere((element) => element.taskId == goal.taskId);
      if (index != -1) {
        data[index] = goal;
      } else {
        data.add(goal);
      }
      await ref.update({'taskGoals': data.map((e) => e.toData()).toList()});
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return false;
    }
  }
}
