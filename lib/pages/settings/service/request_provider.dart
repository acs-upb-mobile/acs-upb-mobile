import 'dart:async';

import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/settings/model/request.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

extension RequestExtension on Request {
  Map<String, dynamic> toData() {
    final Map<String, dynamic> data = {};

    if (userId != null) data['addedBy'] = userId;
    if (requestBody != null) data['requestBody'] = requestBody;
    data['done'] = processed;
    data['dateSubmitted'] = Timestamp.now();
    data['type'] = type.toShortString();

    return data;
  }
}

class RequestProvider {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool userAlreadyRequestedCache;

  Future<bool> makeRequest(Request request) async {
    assert(request.requestBody != null);

    try {
      CollectionReference ref;
      ref = _db.collection('forms');

      final data = request.toData();
      await ref.add(data);

      return userAlreadyRequestedCache = true;
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return userAlreadyRequestedCache = false;
    }
  }

  Future<bool> userAlreadyRequested(final String userId) async {
    if (userAlreadyRequestedCache != null) return userAlreadyRequestedCache;

    try {
      final DocumentSnapshot<Map<String, dynamic>> snap =
          await _db.collection('forms').doc(userId).get();
      if (snap.data() != null) {
        return userAlreadyRequestedCache = true;
      }
      return userAlreadyRequestedCache = false;
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return userAlreadyRequestedCache = false;
    }
  }
}
