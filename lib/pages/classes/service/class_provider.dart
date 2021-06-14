import 'package:acs_upb_mobile/authentication/model/user.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/classes/model/class.dart';
import 'package:acs_upb_mobile/pages/filter/model/filter.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

extension UserExtension on User {
  bool get canEditClassInfo => permissionLevel >= 3;
}

extension ShortcutTypeExtension on ShortcutType {
  static ShortcutType fromString(String string) {
    switch (string) {
      case 'main':
        return ShortcutType.main;
      case 'classbook':
        return ShortcutType.classbook;
      case 'resource':
        return ShortcutType.resource;
      default:
        return ShortcutType.other;
    }
  }
}

extension ShortcutExtension on Shortcut {
  Map<String, dynamic> toData() {
    return {
      'type': type.toShortString(),
      'name': name,
      'link': link,
      'addedBy': ownerUid
    };
  }
}

extension ClassHeaderExtension on ClassHeader {
  static ClassHeader fromSnap(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap?.data();
    if (data == null) return null;
    final splitAcronym = data['shortname'].split('-');
    if (splitAcronym.length < 4) {
      return null;
    }
    return ClassHeader(
      id: data['shortname'],
      name: data['fullname'],
      acronym: data['shortname'].split('-')[3],
      category: data['category_path'],
    );
  }
}

extension ClassExtension on Class {
  static Class fromSnap(
      {ClassHeader header, DocumentSnapshot<Map<String, dynamic>> snap}) {
    final data = snap.data();

    if (data == null) {
      return Class(header: header);
    }

    final shortcuts = <Shortcut>[];
    for (final s in List<Map<String, dynamic>>.from(data['shortcuts'] ?? [])) {
      shortcuts.add(Shortcut(
        type: ShortcutTypeExtension.fromString(s['type']),
        name: s['name'],
        link: s['link'],
        ownerUid: s['addedBy'],
      ));
    }

    Map<String, double> grading;
    if (data['grading'] != null) {
      grading = Map<String, double>.from(data['grading'].map(
          (String name, dynamic value) => MapEntry(name, value.toDouble())));
    }

    final gradingLastUpdated = data['gradingLastUpdated'] == null
        ? null
        : (data['gradingLastUpdated'] as Timestamp).toDate();

    return Class(
      header: header,
      shortcuts: shortcuts,
      grading: grading,
      gradingLastUpdated: gradingLastUpdated,
    );
  }
}

class ClassProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<ClassHeader> classHeadersCache;
  List<ClassHeader> userClassHeadersCache;

  Future<List<String>> fetchUserClassIds(String uid) async {
    try {
      // TODO(IoanaAlexandru): Get all classes if user is not authenticated
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snap.data() == null) {
        return [];
      }
      return List<String>.from(snap.data()['classes'] ?? []);
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return null;
    }
  }

  Future<bool> setUserClassIds(List<String> classIds, String uid) async {
    try {
      final DocumentReference ref =
          FirebaseFirestore.instance.collection('users').doc(uid);
      await ref.update({'classes': classIds});
      userClassHeadersCache = null;
      notifyListeners();
      return true;
    } catch (e) {
      AppToast.show(S.current.errorSomethingWentWrong);
      return false;
    }
  }

  Future<ClassHeader> fetchClassHeader(String classId) async {
    try {
      // Get class with id [classId]
      final QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore
          .instance
          .collection('import_moodle')
          .where('shortname', isEqualTo: classId)
          .limit(1)
          .get();

      if (query == null || query.docs.isEmpty) {
        return null;
      }

      return ClassHeaderExtension.fromSnap(query.docs.first);
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return null;
    }
  }

  Future<List<ClassHeader>> fetchClassHeaders(
      {String uid, Filter filter}) async {
    try {
      if (uid == null) {
        if (classHeadersCache != null) {
          return classHeadersCache;
        }

        // Get all classes
        final QuerySnapshot<Map<String, dynamic>> qSnapshot =
            await _db.collection('import_moodle').get();
        final List<DocumentSnapshot> docs = qSnapshot.docs;

        return docs
            .map((doc) => ClassHeaderExtension.fromSnap(doc))
            .where((e) => e != null)
            .toList();
      } else {
        if (userClassHeadersCache != null) {
          return userClassHeadersCache;
        }
        final headers = <ClassHeader>[];

        // Get only the user's classes
        final List<String> classIds = await fetchUserClassIds(uid) ?? [];
        final List<String> newClassIds = List<String>.from(classIds);

        for (final classId in classIds) {
          final ClassHeader header = await fetchClassHeader(classId);
          if (header == null) {
            // Class doesn't exist, remove it
            newClassIds.remove(classId);
            continue;
          }
          headers.add(header);
        }

        // Remove non-existent classes from user data
        if (newClassIds.length != classIds.length) {
          await setUserClassIds(newClassIds, uid);
        }

        return userClassHeadersCache = headers;
      }
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return null;
    }
  }

  Future<Class> fetchClassInfo(ClassHeader header) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snap =
          await _db.collection('classes').doc(header.id).get();
      return ClassExtension.fromSnap(header: header, snap: snap);
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return null;
    }
  }

  Future<bool> addShortcut(String classId, Shortcut shortcut) async {
    try {
      final DocumentReference doc = _db.collection('classes').doc(classId);
      final DocumentSnapshot<Map<String, dynamic>> snap = await doc.get();

      if (snap.data() == null) {
        // Document does not exist
        await doc.set({
          'shortcuts': [shortcut.toData()]
        });
      } else {
        // Document exists
        final shortcuts =
            List<Map<String, dynamic>>.from(snap.data()['shortcuts'] ?? [])
              ..add(shortcut.toData());

        await doc.update({'shortcuts': shortcuts});
      }

      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return false;
    }
  }

  Future<bool> deleteShortcut(String classId, int shortcutIndex) async {
    try {
      final DocumentReference<Map<String, dynamic>> doc =
          _db.collection('classes').doc(classId);

      final shortcuts = List<Map<String, dynamic>>.from(
          (await doc.get()).data()['shortcuts'] ?? [])
        ..removeAt(shortcutIndex);

      await doc.update({'shortcuts': shortcuts});

      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return false;
    }
  }

  Future<bool> setGrading(String classId, Map<String, double> grading) async {
    try {
      final DocumentReference doc = _db.collection('classes').doc(classId);
      final DocumentSnapshot<Map<String, dynamic>> snap = await doc.get();
      final Timestamp now = Timestamp.now();

      if (snap.data() == null) {
        // Document does not exist
        await doc.set({'grading': grading, 'gradingLastUpdated': now});
      } else {
        // Document exists
        await doc.update({'grading': grading, 'gradingLastUpdated': now});
      }

      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return false;
    }
  }
}
