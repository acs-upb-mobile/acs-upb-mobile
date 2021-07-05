import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/filter/model/filter.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:preferences/preference_service.dart';

extension FilterNodeExtension on FilterNode {
  static FilterNode fromMap(Map<String, dynamic> map, String parentName) {
    final children = <FilterNode>[];

    final sortedKeys = map.keys.toList()..sort();
    for (final key in sortedKeys) {
      children.add(FilterNodeExtension.fromMap(map[key], key));
    }

    return FilterNode(name: parentName, children: children);
  }
}

class FilterProvider with ChangeNotifier {
  FilterProvider(
      {this.global = false,
      bool filterEnabled,
      this.defaultDegree,
      this.defaultRelevance})
      : _enabled = filterEnabled ?? PrefService.get('relevance_filter') ?? true,
        _relevantNodes = defaultRelevance {
    if (defaultRelevance != null && !defaultRelevance.contains('All')) {
      if (defaultDegree == null) {
        throw ArgumentError(
            'If the relevance is not null, the degree cannot be null.');
      }
    }
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Filter _relevanceFilter; // filter cache

  /// Whether this is the global filter instance and should update shared preferences.
  /// If false, this is probably a local filter setting (e.g. for an event or website)
  /// and should be the user's class by default.
  final bool global;

  final String defaultDegree;

  bool _enabled;
  List<String> _relevantNodes;
  final List<String> defaultRelevance;

  AuthProvider _authProvider;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    clearCache();
  }

  void clearCache() {
    _relevanceFilter = null;
    _relevantNodes = null;

    if (global) {
      // TODO(IoanaAlexandru): Remove this property
      PrefService.setBool('relevance_filter', true);
    }

    notifyListeners();
  }

  Future<void> _setFilterNodes(List<String> nodes) async {
    try {
      final DocumentReference doc =
          _db.collection('users').doc(_authProvider.uid);
      await doc.update({'filter_nodes': nodes});
    } catch (e) {
      print(e);
    }
  }

  void enableFilter() {
    _enabled = true;
    if (global) {
      PrefService.setBool('relevance_filter', true);
    }

    notifyListeners();
  }

  void disableFilter() {
    _relevanceFilter = null;

    _enabled = false;
    if (global) {
      PrefService.setBool('relevance_filter', false);
    }

    notifyListeners();
  }

  void updateFilter(Filter filter) {
    _relevanceFilter = filter;
    if (global) {
      _setFilterNodes(_relevanceFilter.relevantNodes);
    }
    notifyListeners();
  }

  bool get filterEnabled => _enabled;

  Filter get cachedFilter => _relevanceFilter?.clone();

  Future<Filter> fetchFilter() async {
    if (_relevanceFilter != null) {
      return cachedFilter;
    }

    try {
      final col = _db.collection('filters');
      final ref = col.doc('relevance');
      final doc = await ref.get();
      final data = doc.data();

      final levelNames = <Map<String, String>>[];
      // Cast from List<dynamic> to List<Map<String, String>>
      final names = data['levelNames'];
      for (final name in names) {
        levelNames.add(Map<String, String>.from(name));
      }

      final root = data['root'];
      _relevanceFilter = Filter(
        localizedLevelNames: levelNames,
        root: FilterNodeExtension.fromMap(root, 'All'),
      );

      // Set the default relevance, if provided
      if (defaultRelevance != null) {
        for (final node in defaultRelevance) {
          _relevanceFilter.setRelevantUpToRoot(node, defaultDegree);
        }
        _relevantNodes = _relevanceFilter.relevantNodes;
      } else if (!global) {
        if (_authProvider != null &&
            _authProvider.isAuthenticated &&
            !_authProvider.isAnonymous) {
          final userSnap =
              await _db.collection('users').doc(_authProvider.uid).get();

          // Load class information from Firestore
          _relevantNodes = List<String>.from(userSnap['class']);
          _relevanceFilter?.setRelevantNodes(_relevantNodes);
        }
      } else {
        // Check if there is an existing setting already
        if (_authProvider != null &&
            _authProvider.isAuthenticated &&
            !_authProvider.isAnonymous) {
          final userSnap =
              await _db.collection('users').doc(_authProvider.uid).get();

          // Load filter_nodes from Firestore
          _relevantNodes = List<String>.from(userSnap['filter_nodes']);
          _relevanceFilter?.setRelevantNodes(_relevantNodes);
        }
      }

      notifyListeners();
      return cachedFilter;
    } catch (e, _) {
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
      return null;
    }
  }
}
