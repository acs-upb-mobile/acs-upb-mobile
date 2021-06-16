import 'dart:core';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/people/model/person.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension PersonExtension on Person {
  static Person fromSnap(DocumentSnapshot snap) {
    final data = snap.data();
    return Person(
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      office: data['office'],
      position: data['position'],
      photo: data['photo'],
    );
  }
}

class PersonProvider with ChangeNotifier {
  Future<List<Person>> fetchPeople() async {
    try {
      final QuerySnapshot qSnapshot =
          await FirebaseFirestore.instance.collection('people').get();
      return qSnapshot.docs.map(PersonExtension.fromSnap).toList();
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return null;
    }
  }

  Future<Person> fetchPerson(String personName) async {
    try {
      // Get person with name [personName]
      final QuerySnapshot query = await FirebaseFirestore.instance
          .collection('people')
          .where('name', isEqualTo: personName)
          .limit(1)
          .get();

      if (query == null || query.docs.isEmpty) {
        return Person(name: personName);
      }

      return PersonExtension.fromSnap(query.docs.first);
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return null;
    }
  }

  Future<String> mostRecentLecturer(String classId) async {
    try {
      final QuerySnapshot query = await FirebaseFirestore.instance
          .collection('events')
          .where('class', isEqualTo: classId)
          .where('type', isEqualTo: 'lecture')
          .orderBy('start', descending: true)
          .limit(1)
          .get();

      if (query == null || query.docs.isEmpty) {
        return null;
      }
      return query.docs.first.get('teacher');
    } catch (e) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return null;
    }
  }

  Future<List<Person>> search(String query) async {
    if (query.isEmpty) {
      return <Person>[];
    }
    final List<Person> people = await fetchPeople();
    final List<String> searchedWords = query
        .toLowerCase()
        .split(' ')
        .where((element) => element != '')
        .toList();
    return people
            .where((person) => searchedWords.fold(
                true,
                (previousValue, filter) =>
                    previousValue &&
                    person.name.toLowerCase().contains(filter.toLowerCase())))
            .toList() ??
        <Person>[];
  }
}