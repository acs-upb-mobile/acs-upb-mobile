import 'dart:async';
import 'dart:typed_data';

import 'package:acs_upb_mobile/authentication/model/user.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/resources/storage/storage_provider.dart';
import 'package:acs_upb_mobile/resources/validator.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth show User;
import 'package:flutter/material.dart';

extension DatabaseUser on User {
  static User fromSnap(DocumentSnapshot snap) {
    final data = snap.data();
    return User(
        uid: snap.id,
        firstName: data['name']['first'],
        lastName: data['name']['last'],
        classes: List.from(data['class'] ?? []),
        hiddenEvents: List.from(data['hiddenEvents'] ?? []),
        permissionLevel: data['permissionLevel']);
  }

  Map<String, dynamic> toData() {
    return {
      'name': {'first': firstName, 'last': lastName},
      'class': classes,
      'permissionLevel': permissionLevel
    };
  }
}

class AuthProvider with ChangeNotifier {
  AuthProvider() {
    _userAuthSub = FirebaseAuth.instance.authStateChanges().listen((newUser) {
      print('AuthProvider - FirebaseAuth - authStateChanges - $newUser');
      _currentUser = null;
      _fetchUser();
      notifyListeners();
    }, onError: (dynamic e) {
      print('AuthProvider - FirebaseAuth - authStateChanges - $e');
    });
  }

  firebase_auth.User get _firebaseUser => FirebaseAuth.instance.currentUser;
  StreamSubscription<firebase_auth.User> _userAuthSub;
  User _currentUser;

  @override
  void dispose() {
    if (_userAuthSub != null) {
      _userAuthSub.cancel();
      _userAuthSub = null;
    }
    super.dispose();
  }

  void _errorHandler(dynamic e, {bool showToast = true}) {
    try {
      print(e.message);
      if (showToast) {
        switch (e.code) {
          case 'ERROR_INVALID_EMAIL':
          case 'ERROR_INVALID_CREDENTIAL':
            AppToast.show(S.current.errorInvalidEmail);
            break;
          case 'ERROR_WRONG_PASSWORD':
            AppToast.show(S.current.errorIncorrectPassword);
            break;
          case 'ERROR_USER_NOT_FOUND':
            AppToast.show(S.current.errorEmailNotFound);
            break;
          case 'ERROR_USER_DISABLED':
            AppToast.show(S.current.errorAccountDisabled);
            break;
          case 'ERROR_TOO_MANY_REQUESTS':
            AppToast.show(
                '${S.current.errorTooManyRequests} ${S.current.warningTryAgainLater}');
            break;
          case 'ERROR_EMAIL_ALREADY_IN_USE':
            AppToast.show(S.current.errorEmailInUse);
            break;
          default:
            AppToast.show(e.message);
        }
      }
    } catch (_) {
      // Unknown exception
      print(e);
      AppToast.show(S.current.errorSomethingWentWrong);
    }
  }

  bool get isAnonymous {
    if (_firebaseUser == null) {
      return true;
    }

    var isAnonymousUser = true;
    for (final info in _firebaseUser.providerData) {
      if (info.providerId == 'password') {
        isAnonymousUser = false;
        break;
      }
    }
    return isAnonymousUser;
  }

  /// Check if the user verified their e-mail
  Future<bool> get isVerified async {
    assert(_firebaseUser != null);
    await _firebaseUser.reload();
    return !isAnonymous && _firebaseUser.emailVerified;
  }

  /// Check if there is a user authenticated
  bool get isAuthenticated {
    return _firebaseUser != null;
  }

  String get uid {
    return _firebaseUser?.uid;
  }

  String get email => _firebaseUser.email;

  bool _isOldFormat(Map<String, dynamic> userData) =>
      userData['class'] != null && userData['class'] is Map;

  /// Change the `class` of the user data in Firebase to the new format.
  ///
  /// The old format of class in the database is a `Map<String, String>`,
  /// where the key is the name of the level in the filter tree.
  /// In the new format, the class is simply a `List<String>` that contains the
  /// name of the nodes.
  Future<void> _migrateToNewClassFormat(Map<String, dynamic> userData) async {
    final classes = ['degree', 'domain', 'year', 'series', 'group', 'subgroup']
        .map((key) => userData['class'][key].toString())
        .where((s) => s != 'null')
        .toList();

    userData['class'] = classes;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebaseUser.uid)
        .update(userData);
  }

  Future<User> _fetchUser() async {
    if (isAnonymous) {
      return null;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebaseUser.uid)
        .get();
    final data = snapshot.data();
    if (data == null) return null;

    if (_isOldFormat(data)) {
      await _migrateToNewClassFormat(data);
    }

    _currentUser = DatabaseUser.fromSnap(snapshot);
    notifyListeners();
    return _currentUser;
  }

  Future<User> get currentUser => _fetchUser();

  User get currentUserFromCache => _currentUser;

  Future<bool> signInAnonymously() async {
    return FirebaseAuth.instance.signInAnonymously().catchError((dynamic e) {
      _errorHandler(e);
      return false;
    }).then((_) => true);
  }

  Future<bool> changePassword(String password) async {
    bool result = false;
    await _firebaseUser.updatePassword(password).then((_) {
      result = true;
    }).catchError((dynamic e) {
      _errorHandler(e);
      result = false;
    });
    return result;
  }

  Future<bool> changeEmail(String email) async {
    bool result = false;
    await _firebaseUser.updateEmail(email).then((_) {
      result = true;
    }).catchError((dynamic e) {
      _errorHandler(e);
      result = false;
    });
    return result;
  }

  Future<bool> verifyPassword(String password) async {
    return signIn(_firebaseUser.email, password);
  }

  Future<bool> signIn(String email, String password) async {
    if (email == null || email == '') {
      AppToast.show(S.current.errorInvalidEmail);
      return false;
    } else if (password == null || password == '') {
      AppToast.show(S.current.errorNoPassword);
      return false;
    }

    final List<String> providers = await FirebaseAuth.instance
        .fetchSignInMethodsForEmail(email)
        .catchError((dynamic e) {
      _errorHandler(e);
      return null;
    });

    // An error occurred (and was already handled)
    if (providers == null) {
      return false;
    }

    // User has an account with a different provider
    if (providers.isNotEmpty && !providers.contains('password')) {
      AppToast.show(S.current.warningUseProvider(providers[0]));
      return false;
    }

    final result = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .catchError((dynamic e) {
      _errorHandler(e);
      return null;
    });
    await _fetchUser();
    return result != null;
  }

  Future<void> signOut() async {
    if (isAuthenticated && isAnonymous) {
      await delete(showToast: false);
    }
    await FirebaseAuth.instance.signOut();
  }

  Future<bool> delete({bool showToast = true}) async {
    assert(_firebaseUser != null);

    try {
      final DocumentReference ref =
          FirebaseFirestore.instance.collection('users').doc(_firebaseUser.uid);
      await ref.delete();

      await _firebaseUser.delete();
    } catch (e) {
      _errorHandler(e, showToast: showToast);
      return false;
    }

    if (showToast) {
      AppToast.show(S.current.messageAccountDeleted);
    }
    return true;
  }

  Future<bool> canSignInWithPassword(String email,
      {bool showToast = true}) async {
    List<String> providers = [];
    try {
      providers = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    } catch (e) {
      _errorHandler(e, showToast: showToast);
      return false;
    }
    final bool accountExists = providers.contains('password');
    if (!accountExists && showToast) {
      AppToast.show(S.current.errorEmailNotFound);
    }
    return accountExists;
  }

  Future<bool> canSignUpWithEmail(String email, {bool showToast = true}) async {
    List<String> providers = [];
    try {
      providers = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    } catch (e) {
      _errorHandler(e, showToast: showToast);
      return false;
    }
    final bool accountExists = providers.isNotEmpty;
    if (accountExists && showToast) {
      AppToast.show(S.current.warningEmailInUse(email));
    }
    return !accountExists;
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      AppToast.show(S.current.infoPasswordResetEmailSent);
      return true;
    } catch (e) {
      _errorHandler(e);
      return false;
    }
  }

  /// Create a new user with the data in [info].
  Future<bool> signUp(Map<String, dynamic> info) async {
    try {
      final email = info[S.current.labelEmail];
      final password = info[S.current.labelPassword];
      final confirmPassword = info[S.current.labelConfirmPassword];
      final firstName = info[S.current.labelFirstName];
      final lastName = info[S.current.labelLastName];

      final classes = info['class'];

      if (email == null || email == '') {
        AppToast.show(S.current.errorInvalidEmail);
        return false;
      } else if (password == null || password == '') {
        AppToast.show(S.current.errorNoPassword);
        return false;
      }
      if (confirmPassword == null || confirmPassword != password) {
        AppToast.show(S.current.errorPasswordsDiffer);
        return false;
      }
      if (firstName == null || firstName == '') {
        AppToast.show(S.current.errorMissingFirstName);
        return false;
      }
      if (lastName == null || lastName == '') {
        AppToast.show(S.current.errorMissingLastName);
        return false;
      }

      final errorString = AppValidator.isStrongPassword(password);
      if (errorString != null) {
        AppToast.show(errorString);
        return false;
      }

      // Create user
      final UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create document in 'users'
      _currentUser = User(
        uid: credential.user.uid,
        firstName: firstName,
        lastName: lastName,
        classes: classes,
      );

      final DocumentReference ref =
          FirebaseFirestore.instance.collection('users').doc(_currentUser.uid);
      await ref.set(_currentUser.toData());

      // Try to set the default from the user data
      if (_currentUser.classes != null) {
        await ref.update({'filter_nodes': _currentUser.classes});
      }
      // Send verification e-mail
      await _firebaseUser.sendEmailVerification();

      AppToast.show(
          '${S.current.messageAccountCreated} ${S.current.messageCheckEmailVerification}');

      notifyListeners();
      return true;
    } catch (e) {
      // Remove user if it was created
      await _firebaseUser?.delete();

      _errorHandler(e);
      return false;
    }
  }

  Future<bool> sendEmailVerification() async {
    try {
      await _firebaseUser.sendEmailVerification();
    } catch (e) {
      _errorHandler(e);
      return false;
    }

    AppToast.show(S.current.messageCheckEmailVerification);
    return true;
  }

  /// Update the user information with the data in [info].
  Future<bool> updateProfile(Map<String, dynamic> info) async {
    try {
      final firstName = info[S.current.labelFirstName];
      final lastName = info[S.current.labelLastName];

      final classes = info['class'];

      _currentUser
        ..firstName = firstName
        ..lastName = lastName
        ..classes = classes;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .update(_currentUser.toData());

      notifyListeners();
      return true;
    } catch (e) {
      _errorHandler(e);
      return false;
    }
  }

  Future<bool> uploadProfilePicture(Uint8List file) async {
    final result = await StorageProvider.uploadImage(
        file, 'users/${_firebaseUser.uid}/picture.png');
    if (!result) {
      if (file.length > 5 * 1024 * 1024) {
        AppToast.show(S.current.errorPictureSizeToBig);
      } else {
        AppToast.show(S.current.errorSomethingWentWrong);
      }
    }
    return result;
  }

  Future<String> getProfilePictureURL() {
    return StorageProvider.findImageUrl(
        'users/${_firebaseUser.uid}/picture.png');
  }
}
