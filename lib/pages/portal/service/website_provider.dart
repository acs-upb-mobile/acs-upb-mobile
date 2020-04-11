import 'dart:async';

import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/filter/model/filter.dart';
import 'package:acs_upb_mobile/pages/portal/model/website.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

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
  static Website fromSnap(DocumentSnapshot snap) {
    return Website(
      category: WebsiteCategoryExtension.fromString(snap.data['category']),
      iconPath: snap.data['icon'] ?? 'icons/websites/globe.png',
      label: snap.data['label'] ?? 'Website',
      link: snap.data['link'] ?? '',
      infoByLocale: snap.data['info'] == null
          ? {}
          : {
              'en': snap.data['info']['en'],
              'ro': snap.data['info']['ro'],
            },
    );
  }

  Map<String, dynamic> toData() {
    Map<String, dynamic> data = {
      'relevance': null // TODO: Make relevance customizable
    };

    if (label != null) data['label'] = label;
    if (category != null)
      data['category'] = category.toString().split('.').last;
    if (iconPath != null) data['icon'] = iconPath;
    if (link != null) data['link'] = link;
    if (infoByLocale != null) data['info'] = infoByLocale;

    return data;
  }
}

class WebsiteProvider with ChangeNotifier {
  final Firestore _db = Firestore.instance;

  Future<List<Website>> fetchWebsites(Filter filter,
      {bool userOnly = false, String uid}) async {
    try {
      List<DocumentSnapshot> documents = [];

      if (!userOnly) {
        if (filter == null) {
          QuerySnapshot qSnapshot =
              await _db.collection('websites').getDocuments();
          documents.addAll(qSnapshot.documents);
        } else {
          // Documents without a 'relevance' field are relevant for everyone
          Query query =
              _db.collection('websites').where('relevance', isNull: true);
          QuerySnapshot qSnapshot = await query.getDocuments();
          documents.addAll(qSnapshot.documents);

          for (String string in filter.relevantNodes) {
            // selected nodes
            Query query = _db
                .collection('websites')
                .where('degree', isEqualTo: filter.baseNode)
                .where('relevance', arrayContains: string);
            QuerySnapshot qSnapshot = await query.getDocuments();
            documents.addAll(qSnapshot.documents);
          }
        }

      // Remove duplicates
      // (a document may result out of more than one query)
      final seenDocumentIds = Set<String>();

        documents = documents
            .where((doc) => seenDocumentIds.add(doc.documentID))
            .toList();
      }

      // Get user-added websites
      if (uid != null) {
        DocumentReference ref =
            Firestore.instance.collection('users').document(uid);
        QuerySnapshot qSnapshot =
            await ref.collection('websites').getDocuments();
        documents.addAll(qSnapshot.documents);
      }

      return documents.map((doc) => WebsiteExtension.fromSnap(doc)).toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> addWebsite(Website website,
      {bool userOnly = true, @required BuildContext context}) async {
    assert(website.label != null);
    assert(context != null);

    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    String uid = (await authProvider.currentUser)?.uid;
    assert(uid != null);

    // Sanitize label to obtain document ID
    String id =
        ReCase(website.label.replaceAll(RegExp('[^A-ZĂÂȘȚa-zăâșț0-9 ]'), ''))
            .snakeCase;
    DocumentReference ref;
    if (!userOnly) {
      ref = _db.collection('websites').document(id);
    } else {
      ref = _db
          .collection('users')
          .document(uid)
          .collection('websites')
          .document(id);
    }

    if ((await ref.get()).data != null) {
      print('A website with id $id already exists');
      AppToast.show(S.of(context).warningWebsiteNameExists);
      return false;
    }

    try {
      var data = website.toData();
      data['addedBy'] = uid;
      await ref.setData(data);

      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      AppToast.show(e.message); // TODO: Localize message
      return false;
    }
  }
}
