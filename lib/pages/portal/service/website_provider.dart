import 'dart:async';

import 'package:acs_upb_mobile/authentication/model/user.dart';
import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/filter/model/filter.dart';
import 'package:acs_upb_mobile/pages/portal/model/website.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';
import 'package:provider/provider.dart';

extension UserExtension on User {
  /// Check if there is at least one website that the [User] has permission to edit
  Future<bool> get hasEditableWebsites async {
    // We assume there is at least one public website in the database
    if (canEditPublicInfo) return true;
    return hasPrivateWebsites;
  }

  /// Check if user has at least one private website
  Future<bool> get hasPrivateWebsites async {
    final CollectionReference ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('websites');
    return (await ref.get()).docs.isNotEmpty;
  }
}

extension WebsiteCategoryExtension on WebsiteCategory {
  static WebsiteCategory fromString(String category) {
    switch (category) {
      case 'learning':
        return WebsiteCategory.learning;
      case 'administrative':
        return WebsiteCategory.administrative;
      case 'association':
        return WebsiteCategory.association;
      case 'resource':
        return WebsiteCategory.resource;
      default:
        return WebsiteCategory.other;
    }
  }
}

extension WebsiteExtension on Website {
  // [ownerUid] should be provided if the website is user-private
  static Website fromSnap(DocumentSnapshot snap, {String ownerUid}) {
    final data = snap.data();
    return Website(
      source: data['source'],
      ownerUid: ownerUid ?? data['addedBy'],
      id: snap.id,
      isPrivate: ownerUid != null,
      editedBy: List<String>.from(data['editedBy'] ?? []),
      category: WebsiteCategoryExtension.fromString(data['category']),
      label: data['label'] ?? 'Website',
      link: data['link'] ?? '',
      infoByLocale: data['info'] == null
          ? {}
          : {
              'en': data['info']['en'],
              'ro': data['info']['ro'],
            },
      degree: data['degree'],
      relevance: data['relevance'] == null
          ? null
          : List<String>.from(data['relevance']),
    );
  }

  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};

    if (!isPrivate) {
      if (ownerUid != null) data['addedBy'] = ownerUid;
      data['editedBy'] = editedBy;
      data['relevance'] = relevance;
      if (degree != null) data['degree'] = degree;
    }

    if (label != null) data['label'] = label;
    if (category != null) {
      data['category'] = category.toShortString();
    }
    if (link != null) data['link'] = link;
    if (infoByLocale != null) data['info'] = infoByLocale;
    data['source'] = source;

    return data;
  }
}

class WebsiteProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _errorHandler(dynamic e, BuildContext context) {
    print(e.message);
    if (context != null) {
      if (e.message.contains('PERMISSION_DENIED')) {
        AppToast.show(S.of(context).errorPermissionDenied);
      } else {
        AppToast.show(S.of(context).errorSomethingWentWrong);
      }
    }
  }

  /// Initializes the number of visits of websites with the value stored from Firebase.
  /// If no [uid] is provided, store the data locally instead.
  Future<bool> _initializeNumberOfVisits(
      List<Website> websites, String uid) async {
    if (uid == null) {
      return _initializeNumberOfVisitsLocally(websites);
    }
    try {
      final DocumentReference userDoc = _db.collection('users').doc(uid);
      final userData = (await userDoc.get()).data();

      if (userData != null) {
        final websiteVisits =
            Map<String, dynamic>.from(userData['websiteVisits'] ?? {});
        for (final website in websites) {
          website.numberOfVisits = websiteVisits[website.id] ?? 0;
        }
        return true;
      } else {
        print('User not found.');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Initializes the number of visits of websites with the value stored locally.
  ///
  /// Because [PrefService] doesn't support storing maps, the
  /// data is stored in 2 lists: the list of website IDs (`websiteIds`) and the list
  /// with the number of visits (`websiteVisits`), where `websiteVisits[i]` is the
  /// number of times the user accessed website with ID `websiteIds[i]`.
  Future<bool> _initializeNumberOfVisitsLocally(List<Website> websites) async {
    try {
      final List<String> websiteIds =
          PrefService.sharedPreferences.getStringList('websiteIds') ?? [];
      final List<String> websiteVisits =
          PrefService.sharedPreferences.getStringList('websiteVisits') ?? [];

      final visitsByWebsiteId = Map<String, int>.from(websiteIds.asMap().map(
          (index, key) =>
              MapEntry(key, int.tryParse(websiteVisits[index] ?? 0))));
      for (final Website website in websites) {
        website.numberOfVisits = visitsByWebsiteId[website.id] ?? 0;
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Increments the number of visits of [website], both in-memory and on Firebase.
  /// If no [uid] is provided, update data in the local storage.
  Future<bool> incrementNumberOfVisits(Website website, {String uid}) async {
    try {
      website.numberOfVisits++;
      if (uid == null) {
        return await incrementNumberOfVisitsLocally(website);
      }

      final DocumentReference userDoc = _db.collection('users').doc(uid);
      final userData = (await userDoc.get()).data();

      if (userData != null) {
        final websiteVisits =
            Map<String, dynamic>.from(userData['websiteVisits'] ?? {});
        websiteVisits[website.id] = website.numberOfVisits++;

        await userDoc.update({'websiteVisits': websiteVisits});
        notifyListeners();
        return true;
      } else {
        print('User not found.');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Increments the number of visits of [website], both in-memory and on the local storage.
  ///
  /// Because [PrefService] doesn't support storing maps, the
  /// data is stored in 2 lists: the list of website IDs (`websiteIds`) and the list
  /// with the number of visits `websiteVisits`, where `websiteVisits[i]` is the
  /// number of times the user accessed website with ID `websiteIds[i]`.
  Future<bool> incrementNumberOfVisitsLocally(Website website) async {
    try {
      website.numberOfVisits++;
      final List<String> websiteIds =
          PrefService.sharedPreferences.getStringList('websiteIds') ?? [];
      final List<String> websiteVisits =
          PrefService.sharedPreferences.getStringList('websiteVisits') ?? [];

      if (websiteIds.contains(website.id)) {
        final int index = websiteIds.indexOf(website.id);
        websiteVisits.insert(index, website.numberOfVisits.toString());
      } else {
        websiteIds.add(website.id);
        websiteVisits.add(website.numberOfVisits.toString());
        await PrefService.sharedPreferences
            .setStringList('websiteIds', websiteIds);
      }
      await PrefService.sharedPreferences
          .setStringList('websiteVisits', websiteVisits);
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<Website>> fetchWebsites(Filter filter,
      {bool userOnly = false,
      String uid,
      BuildContext context,
      List<String> sources}) async {
    try {
      final websites = <Website>[];

      if (!userOnly) {
        List<DocumentSnapshot> documents = [];

        if (filter == null) {
          final QuerySnapshot qSnapshot = sources != null
              ? await _db
                  .collection('websites')
                  .where('source', whereIn: sources)
                  .get()
              : await _db.collection('websites').get();
          documents.addAll(qSnapshot.docs);
        } else {
          // Documents without a 'relevance' field are relevant for everyone
          final query = sources != null
              ? _db
                  .collection('websites')
                  .where('source', whereIn: sources)
                  .where('relevance', isNull: true)
              : _db.collection('websites').where('relevance', isNull: true);
          final QuerySnapshot qSnapshot = await query.get();
          documents.addAll(qSnapshot.docs);

          for (final string in filter.relevantNodes) {
            // selected nodes
            final query = sources != null
                ? _db
                    .collection('websites')
                    .where('degree', isEqualTo: filter.baseNode)
                    .where('source', whereIn: sources)
                    .where('relevance', arrayContains: string)
                : _db
                    .collection('websites')
                    .where('degree', isEqualTo: filter.baseNode)
                    .where('relevance', arrayContains: string);
            final QuerySnapshot qSnapshot = await query.get();
            documents.addAll(qSnapshot.docs);
          }
        }

        // Remove duplicates
        // (a document may result out of more than one query)
        final seenDocumentIds = <String>{};

        documents =
            documents.where((doc) => seenDocumentIds.add(doc.id)).toList();

        websites.addAll(documents.map(WebsiteExtension.fromSnap));
      }

      // Get user-added websites
      if (uid != null) {
        final DocumentReference ref =
            FirebaseFirestore.instance.collection('users').doc(uid);

        final QuerySnapshot qSnapshot = sources != null
            ? await ref
                .collection('websites')
                .where('source', whereIn: sources)
                .get()
            : await ref.collection('websites').get();

        websites.addAll(qSnapshot.docs
            .map((doc) => WebsiteExtension.fromSnap(doc, ownerUid: uid)));
      }

      final bool initializeReturnSuccess = await _initializeNumberOfVisits(
          websites,
          Provider.of<AuthProvider>(context, listen: false).isAnonymous
              ? null
              : uid);
      if (!initializeReturnSuccess) {
        AppToast.show(
            S.of(context).warningFavouriteWebsitesInitializationFailed);
      }
      websites.sort((website1, website2) =>
          website2.numberOfVisits.compareTo(website1.numberOfVisits));

      return websites;
    } catch (e) {
      _errorHandler(e, null);
      return null;
    }
  }

  Future<List<Website>> fetchFavouriteWebsites(
      {int limit = 3, String uid, BuildContext context}) async {
    final favouriteWebsites =
        (await fetchWebsites(null, uid: uid, context: context))
            .where((website) => website.numberOfVisits > 0)
            .take(limit)
            .toList();
    if (favouriteWebsites.isEmpty) {
      return null;
    }
    return favouriteWebsites;
  }

  Future<bool> addWebsite(Website website, {BuildContext context}) async {
    assert(website.label != null);

    try {
      DocumentReference ref;
      if (!website.isPrivate) {
        ref = _db.collection('websites').doc(website.id);
      } else {
        ref = _db
            .collection('users')
            .doc(website.ownerUid)
            .collection('websites')
            .doc(website.id);
      }

      if ((await ref.get()).data() != null) {
        // TODO(IoanaAlexandru): Properly check if a website with a similar name/link already exists
        print('A website with id ${website.id} already exists');
        if (context != null) {
          AppToast.show(S.of(context).warningWebsiteNameExists);
        }
        return false;
      }

      final data = website.toData();
      await ref.set(data);

      notifyListeners();
      return true;
    } catch (e) {
      _errorHandler(e, context);
      return false;
    }
  }

  Future<bool> updateWebsite(Website website, {BuildContext context}) async {
    assert(website.label != null);

    try {
      final DocumentReference publicRef =
          _db.collection('websites').doc(website.id);
      final DocumentReference privateRef = _db
          .collection('users')
          .doc(website.ownerUid)
          .collection('websites')
          .doc(website.id);

      DocumentReference previousRef;
      bool wasPrivate;
      if ((await publicRef.get()).data() != null) {
        wasPrivate = false;
        previousRef = publicRef;
      } else if ((await privateRef.get()).data() != null) {
        wasPrivate = true;
        previousRef = privateRef;
      } else {
        print('Website not found.');
        return false;
      }

      if (wasPrivate == website.isPrivate) {
        // No privacy change
        await previousRef.update(website.toData());
      } else {
        // Privacy changed
        await previousRef.delete();
        await (wasPrivate ? publicRef : privateRef).set(website.toData());
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorHandler(e, context);
      return false;
    }
  }

  Future<bool> deleteWebsite(Website website, {BuildContext context}) async {
    try {
      DocumentReference ref;
      if (!website.isPrivate) {
        ref = _db.collection('websites').doc(website.id);
      } else {
        ref = _db
            .collection('users')
            .doc(website.ownerUid)
            .collection('websites')
            .doc(website.id);
      }

      await ref.delete();

      notifyListeners();
      return true;
    } catch (e) {
      _errorHandler(e, context);
      return false;
    }
  }
}
