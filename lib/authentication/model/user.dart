import 'package:meta/meta.dart';

class User {
  User(
      {@required this.uid,
      @required this.firstName,
      @required this.lastName,
      this.classes,
      this.sources,
      int permissionLevel})
      : permissionLevel = permissionLevel ?? 0;

  final String uid;

  String firstName;
  String lastName;
  List<String> sources;

  /// Info about the user's assigned group (including degree, year of study, series etc)
  List<String> classes;

  int permissionLevel;

  bool get canReadFacultyInfo => sources?.contains('official');

  bool get canReadOrganizationInfo => sources?.contains('organizations');

  bool get canReadStudentInfo => sources?.contains('students');

  bool get canAddPublicInfo => permissionLevel >= 3;

  bool get canEditPublicInfo => permissionLevel >= 3;
}
