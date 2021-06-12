import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';

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
}
