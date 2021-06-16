// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Next`
  String get buttonNext {
    return Intl.message(
      'Next',
      name: 'buttonNext',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get buttonCancel {
    return Intl.message(
      'Cancel',
      name: 'buttonCancel',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get buttonSave {
    return Intl.message(
      'Save',
      name: 'buttonSave',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get buttonSend {
    return Intl.message(
      'Send',
      name: 'buttonSend',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get buttonApply {
    return Intl.message(
      'Apply',
      name: 'buttonApply',
      desc: '',
      args: [],
    );
  }

  /// `Set`
  String get buttonSet {
    return Intl.message(
      'Set',
      name: 'buttonSet',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get labelEmail {
    return Intl.message(
      'Email',
      name: 'labelEmail',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get labelPassword {
    return Intl.message(
      'Password',
      name: 'labelPassword',
      desc: '',
      args: [],
    );
  }

  /// `Old password`
  String get labelOldPassword {
    return Intl.message(
      'Old password',
      name: 'labelOldPassword',
      desc: '',
      args: [],
    );
  }

  /// `New password`
  String get labelNewPassword {
    return Intl.message(
      'New password',
      name: 'labelNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password`
  String get labelConfirmPassword {
    return Intl.message(
      'Confirm password',
      name: 'labelConfirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm new password`
  String get labelConfirmNewPassword {
    return Intl.message(
      'Confirm new password',
      name: 'labelConfirmNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Request editing permissions`
  String get labelAskPermissions {
    return Intl.message(
      'Request editing permissions',
      name: 'labelAskPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get labelVersion {
    return Intl.message(
      'Version',
      name: 'labelVersion',
      desc: '',
      args: [],
    );
  }

  /// `First name`
  String get labelFirstName {
    return Intl.message(
      'First name',
      name: 'labelFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Last name`
  String get labelLastName {
    return Intl.message(
      'Last name',
      name: 'labelLastName',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get labelName {
    return Intl.message(
      'Name',
      name: 'labelName',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get labelCategory {
    return Intl.message(
      'Category',
      name: 'labelCategory',
      desc: '',
      args: [],
    );
  }

  /// `Link`
  String get labelLink {
    return Intl.message(
      'Link',
      name: 'labelLink',
      desc: '',
      args: [],
    );
  }

  /// `Relevance`
  String get labelRelevance {
    return Intl.message(
      'Relevance',
      name: 'labelRelevance',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get labelPreview {
    return Intl.message(
      'Preview',
      name: 'labelPreview',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get labelDescription {
    return Intl.message(
      'Description',
      name: 'labelDescription',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get labelCustom {
    return Intl.message(
      'Custom',
      name: 'labelCustom',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get labelType {
    return Intl.message(
      'Type',
      name: 'labelType',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get labelLocation {
    return Intl.message(
      'Location',
      name: 'labelLocation',
      desc: '',
      args: [],
    );
  }

  /// `Color`
  String get labelColor {
    return Intl.message(
      'Color',
      name: 'labelColor',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get labelStart {
    return Intl.message(
      'Start',
      name: 'labelStart',
      desc: '',
      args: [],
    );
  }

  /// `End`
  String get labelEnd {
    return Intl.message(
      'End',
      name: 'labelEnd',
      desc: '',
      args: [],
    );
  }

  /// `Class`
  String get labelClass {
    return Intl.message(
      'Class',
      name: 'labelClass',
      desc: '',
      args: [],
    );
  }

  /// `Lecturer`
  String get labelLecturer {
    return Intl.message(
      'Lecturer',
      name: 'labelLecturer',
      desc: '',
      args: [],
    );
  }

  /// `Year`
  String get labelYear {
    return Intl.message(
      'Year',
      name: 'labelYear',
      desc: '',
      args: [],
    );
  }

  /// `Semester`
  String get labelSemester {
    return Intl.message(
      'Semester',
      name: 'labelSemester',
      desc: '',
      args: [],
    );
  }

  /// `{name} team`
  String labelTeam(Object name) {
    return Intl.message(
      '$name team',
      name: 'labelTeam',
      desc: '',
      args: [name],
    );
  }

  /// `Unknown`
  String get labelUnknown {
    return Intl.message(
      'Unknown',
      name: 'labelUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Evaluation`
  String get labelEvaluation {
    return Intl.message(
      'Evaluation',
      name: 'labelEvaluation',
      desc: '',
      args: [],
    );
  }

  /// `Points`
  String get labelPoints {
    return Intl.message(
      'Points',
      name: 'labelPoints',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get labelPrivacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'labelPrivacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Personal information`
  String get labelPersonalInformation {
    return Intl.message(
      'Personal information',
      name: 'labelPersonalInformation',
      desc: '',
      args: [],
    );
  }

  /// `consent for editing rights`
  String get labelPermissionsConsent {
    return Intl.message(
      'consent for editing rights',
      name: 'labelPermissionsConsent',
      desc: '',
      args: [],
    );
  }

  /// `Last updated`
  String get labelLastUpdated {
    return Intl.message(
      'Last updated',
      name: 'labelLastUpdated',
      desc: '',
      args: [],
    );
  }

  /// `University year`
  String get labelUniversityYear {
    return Intl.message(
      'University year',
      name: 'labelUniversityYear',
      desc: '',
      args: [],
    );
  }

  /// `Week`
  String get labelWeek {
    return Intl.message(
      'Week',
      name: 'labelWeek',
      desc: '',
      args: [],
    );
  }

  /// `Even`
  String get labelEven {
    return Intl.message(
      'Even',
      name: 'labelEven',
      desc: '',
      args: [],
    );
  }

  /// `Odd`
  String get labelOdd {
    return Intl.message(
      'Odd',
      name: 'labelOdd',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get labelDay {
    return Intl.message(
      'Day',
      name: 'labelDay',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get labelToday {
    return Intl.message(
      'Today',
      name: 'labelToday',
      desc: '',
      args: [],
    );
  }

  /// `Tomorrow`
  String get labelTomorrow {
    return Intl.message(
      'Tomorrow',
      name: 'labelTomorrow',
      desc: '',
      args: [],
    );
  }

  /// `Now`
  String get labelNow {
    return Intl.message(
      'Now',
      name: 'labelNow',
      desc: '',
      args: [],
    );
  }

  /// `People`
  String get labelPeople {
    return Intl.message(
      'People',
      name: 'labelPeople',
      desc: '',
      args: [],
    );
  }

  /// `Classes`
  String get labelClasses {
    return Intl.message(
      'Classes',
      name: 'labelClasses',
      desc: '',
      args: [],
    );
  }

  /// `Shortcuts`
  String get sectionShortcuts {
    return Intl.message(
      'Shortcuts',
      name: 'sectionShortcuts',
      desc: '',
      args: [],
    );
  }

  /// `Events`
  String get sectionEvents {
    return Intl.message(
      'Events',
      name: 'sectionEvents',
      desc: '',
      args: [],
    );
  }

  /// `Favourite websites`
  String get sectionFrequentlyAccessedWebsites {
    return Intl.message(
      'Favourite websites',
      name: 'sectionFrequentlyAccessedWebsites',
      desc: '',
      args: [],
    );
  }

  /// `Events coming up`
  String get sectionEventsComingUp {
    return Intl.message(
      'Events coming up',
      name: 'sectionEventsComingUp',
      desc: '',
      args: [],
    );
  }

  /// `FAQ`
  String get sectionFAQ {
    return Intl.message(
      'FAQ',
      name: 'sectionFAQ',
      desc: '',
      args: [],
    );
  }

  /// `Grading`
  String get sectionGrading {
    return Intl.message(
      'Grading',
      name: 'sectionGrading',
      desc: '',
      args: [],
    );
  }

  /// `Main page`
  String get shortcutTypeMain {
    return Intl.message(
      'Main page',
      name: 'shortcutTypeMain',
      desc: '',
      args: [],
    );
  }

  /// `Classbook`
  String get shortcutTypeClassbook {
    return Intl.message(
      'Classbook',
      name: 'shortcutTypeClassbook',
      desc: '',
      args: [],
    );
  }

  /// `Resource`
  String get shortcutTypeResource {
    return Intl.message(
      'Resource',
      name: 'shortcutTypeResource',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get shortcutTypeOther {
    return Intl.message(
      'Other',
      name: 'shortcutTypeOther',
      desc: '',
      args: [],
    );
  }

  /// `john.doe`
  String get hintEmail {
    return Intl.message(
      'john.doe',
      name: 'hintEmail',
      desc: '',
      args: [],
    );
  }

  /// `····················`
  String get hintPassword {
    return Intl.message(
      '····················',
      name: 'hintPassword',
      desc: '',
      args: [],
    );
  }

  /// `John`
  String get hintFirstName {
    return Intl.message(
      'John',
      name: 'hintFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Doe`
  String get hintLastName {
    return Intl.message(
      'Doe',
      name: 'hintLastName',
      desc: '',
      args: [],
    );
  }

  /// `314CB`
  String get hintGroup {
    return Intl.message(
      '314CB',
      name: 'hintGroup',
      desc: '',
      args: [],
    );
  }

  /// `Google`
  String get hintWebsiteLabel {
    return Intl.message(
      'Google',
      name: 'hintWebsiteLabel',
      desc: '',
      args: [],
    );
  }

  /// `http://google.com`
  String get hintWebsiteLink {
    return Intl.message(
      'http://google.com',
      name: 'hintWebsiteLink',
      desc: '',
      args: [],
    );
  }

  /// `Final exam`
  String get hintEvaluation {
    return Intl.message(
      'Final exam',
      name: 'hintEvaluation',
      desc: '',
      args: [],
    );
  }

  /// `4.0`
  String get hintPoints {
    return Intl.message(
      '4.0',
      name: 'hintPoints',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get actionSignUp {
    return Intl.message(
      'Sign up',
      name: 'actionSignUp',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get actionLogIn {
    return Intl.message(
      'Log in',
      name: 'actionLogIn',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get actionLogOut {
    return Intl.message(
      'Log out',
      name: 'actionLogOut',
      desc: '',
      args: [],
    );
  }

  /// `Log in anonymously`
  String get actionLogInAnonymously {
    return Intl.message(
      'Log in anonymously',
      name: 'actionLogInAnonymously',
      desc: '',
      args: [],
    );
  }

  /// `Edit profile`
  String get actionEditProfile {
    return Intl.message(
      'Edit profile',
      name: 'actionEditProfile',
      desc: '',
      args: [],
    );
  }

  /// `Social login`
  String get actionSocialLogin {
    return Intl.message(
      'Social login',
      name: 'actionSocialLogin',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with {provider}`
  String actionSignInWith(Object provider) {
    return Intl.message(
      'Sign in with $provider',
      name: 'actionSignInWith',
      desc: '',
      args: [provider],
    );
  }

  /// `Reset password`
  String get actionResetPassword {
    return Intl.message(
      'Reset password',
      name: 'actionResetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Send e-mail`
  String get actionSendEmail {
    return Intl.message(
      'Send e-mail',
      name: 'actionSendEmail',
      desc: '',
      args: [],
    );
  }

  /// `Change email`
  String get actionChangeEmail {
    return Intl.message(
      'Change email',
      name: 'actionChangeEmail',
      desc: '',
      args: [],
    );
  }

  /// `Send e-mail again?`
  String get actionSendVerificationAgain {
    return Intl.message(
      'Send e-mail again?',
      name: 'actionSendVerificationAgain',
      desc: '',
      args: [],
    );
  }

  /// `Delete account`
  String get actionDeleteAccount {
    return Intl.message(
      'Delete account',
      name: 'actionDeleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Change password`
  String get actionChangePassword {
    return Intl.message(
      'Change password',
      name: 'actionChangePassword',
      desc: '',
      args: [],
    );
  }

  /// `Add website`
  String get actionAddWebsite {
    return Intl.message(
      'Add website',
      name: 'actionAddWebsite',
      desc: '',
      args: [],
    );
  }

  /// `Edit website`
  String get actionEditWebsite {
    return Intl.message(
      'Edit website',
      name: 'actionEditWebsite',
      desc: '',
      args: [],
    );
  }

  /// `Delete website`
  String get actionDeleteWebsite {
    return Intl.message(
      'Delete website',
      name: 'actionDeleteWebsite',
      desc: '',
      args: [],
    );
  }

  /// `Enable editing`
  String get actionEnableEditing {
    return Intl.message(
      'Enable editing',
      name: 'actionEnableEditing',
      desc: '',
      args: [],
    );
  }

  /// `Disable editing`
  String get actionDisableEditing {
    return Intl.message(
      'Disable editing',
      name: 'actionDisableEditing',
      desc: '',
      args: [],
    );
  }

  /// `Jump to today`
  String get actionJumpToToday {
    return Intl.message(
      'Jump to today',
      name: 'actionJumpToToday',
      desc: '',
      args: [],
    );
  }

  /// `Add event`
  String get actionAddEvent {
    return Intl.message(
      'Add event',
      name: 'actionAddEvent',
      desc: '',
      args: [],
    );
  }

  /// `Edit event`
  String get actionEditEvent {
    return Intl.message(
      'Edit event',
      name: 'actionEditEvent',
      desc: '',
      args: [],
    );
  }

  /// `Delete event`
  String get actionDeleteEvent {
    return Intl.message(
      'Delete event',
      name: 'actionDeleteEvent',
      desc: '',
      args: [],
    );
  }

  /// `Choose classes`
  String get actionChooseClasses {
    return Intl.message(
      'Choose classes',
      name: 'actionChooseClasses',
      desc: '',
      args: [],
    );
  }

  /// `Add shortcut`
  String get actionAddShortcut {
    return Intl.message(
      'Add shortcut',
      name: 'actionAddShortcut',
      desc: '',
      args: [],
    );
  }

  /// `Delete shortcut`
  String get actionDeleteShortcut {
    return Intl.message(
      'Delete shortcut',
      name: 'actionDeleteShortcut',
      desc: '',
      args: [],
    );
  }

  /// `Show more`
  String get actionShowMore {
    return Intl.message(
      'Show more',
      name: 'actionShowMore',
      desc: '',
      args: [],
    );
  }

  /// `Edit grading`
  String get actionEditGrading {
    return Intl.message(
      'Edit grading',
      name: 'actionEditGrading',
      desc: '',
      args: [],
    );
  }

  /// `Contribute`
  String get actionContribute {
    return Intl.message(
      'Contribute',
      name: 'actionContribute',
      desc: '',
      args: [],
    );
  }

  /// `Open filter`
  String get actionOpenFilter {
    return Intl.message(
      'Open filter',
      name: 'actionOpenFilter',
      desc: '',
      args: [],
    );
  }

  /// `Request permissions`
  String get actionRequestPermissions {
    return Intl.message(
      'Request permissions',
      name: 'actionRequestPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get actionRefresh {
    return Intl.message(
      'Refresh',
      name: 'actionRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong.`
  String get errorSomethingWentWrong {
    return Intl.message(
      'Something went wrong.',
      name: 'errorSomethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `The two passwords differ.`
  String get errorPasswordsDiffer {
    return Intl.message(
      'The two passwords differ.',
      name: 'errorPasswordsDiffer',
      desc: '',
      args: [],
    );
  }

  /// `The password you entered is incorrect.`
  String get errorIncorrectPassword {
    return Intl.message(
      'The password you entered is incorrect.',
      name: 'errorIncorrectPassword',
      desc: '',
      args: [],
    );
  }

  /// `You need to provide a password.`
  String get errorNoPassword {
    return Intl.message(
      'You need to provide a password.',
      name: 'errorNoPassword',
      desc: '',
      args: [],
    );
  }

  /// `You need to provide a valid e-mail address.`
  String get errorInvalidEmail {
    return Intl.message(
      'You need to provide a valid e-mail address.',
      name: 'errorInvalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please provide your first name(s).`
  String get errorMissingFirstName {
    return Intl.message(
      'Please provide your first name(s).',
      name: 'errorMissingFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Please provide your last name(s).`
  String get errorMissingLastName {
    return Intl.message(
      'Please provide your last name(s).',
      name: 'errorMissingLastName',
      desc: '',
      args: [],
    );
  }

  /// `There is already an account associated with this e-mail address`
  String get errorEmailInUse {
    return Intl.message(
      'There is already an account associated with this e-mail address',
      name: 'errorEmailInUse',
      desc: '',
      args: [],
    );
  }

  /// `An account associated with that e-mail could not be found. Please sign up instead.`
  String get errorEmailNotFound {
    return Intl.message(
      'An account associated with that e-mail could not be found. Please sign up instead.',
      name: 'errorEmailNotFound',
      desc: '',
      args: [],
    );
  }

  /// `The account has been disabled.`
  String get errorAccountDisabled {
    return Intl.message(
      'The account has been disabled.',
      name: 'errorAccountDisabled',
      desc: '',
      args: [],
    );
  }

  /// `There have been too many requests from this device.`
  String get errorTooManyRequests {
    return Intl.message(
      'There have been too many requests from this device.',
      name: 'errorTooManyRequests',
      desc: '',
      args: [],
    );
  }

  /// `Could not launch '{url}'.`
  String errorCouldNotLaunchURL(Object url) {
    return Intl.message(
      'Could not launch \'$url\'.',
      name: 'errorCouldNotLaunchURL',
      desc: '',
      args: [url],
    );
  }

  /// `You do not have permission to do that.`
  String get errorPermissionDenied {
    return Intl.message(
      'You do not have permission to do that.',
      name: 'errorPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Event type cannot be empty.`
  String get errorEventTypeCannotBeEmpty {
    return Intl.message(
      'Event type cannot be empty.',
      name: 'errorEventTypeCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Class cannot be empty.`
  String get errorClassCannotBeEmpty {
    return Intl.message(
      'Class cannot be empty.',
      name: 'errorClassCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Please select a picture that is less than 5MB.`
  String get errorPictureSizeToBig {
    return Intl.message(
      'Please select a picture that is less than 5MB.',
      name: 'errorPictureSizeToBig',
      desc: '',
      args: [],
    );
  }

  /// `The image could not be loaded.`
  String get errorImage {
    return Intl.message(
      'The image could not be loaded.',
      name: 'errorImage',
      desc: '',
      args: [],
    );
  }

  /// `Unable to insert events in Google Calendar.`
  String get errorInsertGoogleEvents {
    return Intl.message(
      'Unable to insert events in Google Calendar.',
      name: 'errorInsertGoogleEvents',
      desc: '',
      args: [],
    );
  }

  /// `Request already exists`
  String get warningRequestExists {
    return Intl.message(
      'Request already exists',
      name: 'warningRequestExists',
      desc: '',
      args: [],
    );
  }

  /// `Please make sure you have an internet connection.`
  String get warningInternetConnection {
    return Intl.message(
      'Please make sure you have an internet connection.',
      name: 'warningInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `The password must be 8 characters long or more.`
  String get warningPasswordLength {
    return Intl.message(
      'The password must be 8 characters long or more.',
      name: 'warningPasswordLength',
      desc: '',
      args: [],
    );
  }

  /// `The password must be different from the old one.`
  String get warningSamePassword {
    return Intl.message(
      'The password must be different from the old one.',
      name: 'warningSamePassword',
      desc: '',
      args: [],
    );
  }

  /// `The password must include at least one uppercase letter.`
  String get warningPasswordUppercase {
    return Intl.message(
      'The password must include at least one uppercase letter.',
      name: 'warningPasswordUppercase',
      desc: '',
      args: [],
    );
  }

  /// `The password must include at least one lowercase letter.`
  String get warningPasswordLowercase {
    return Intl.message(
      'The password must include at least one lowercase letter.',
      name: 'warningPasswordLowercase',
      desc: '',
      args: [],
    );
  }

  /// `The password must include at least one special character.`
  String get warningPasswordSpecialCharacters {
    return Intl.message(
      'The password must include at least one special character.',
      name: 'warningPasswordSpecialCharacters',
      desc: '',
      args: [],
    );
  }

  /// `The password must include at least one number.`
  String get warningPasswordNumber {
    return Intl.message(
      'The password must include at least one number.',
      name: 'warningPasswordNumber',
      desc: '',
      args: [],
    );
  }

  /// `There is already an account associated with {email}.`
  String warningEmailInUse(Object email) {
    return Intl.message(
      'There is already an account associated with $email.',
      name: 'warningEmailInUse',
      desc: '',
      args: [email],
    );
  }

  /// `Please log in with {provider} to continue.`
  String warningUseProvider(Object provider) {
    return Intl.message(
      'Please log in with $provider to continue.',
      name: 'warningUseProvider',
      desc: '',
      args: [provider],
    );
  }

  /// `Please try again later.`
  String get warningTryAgainLater {
    return Intl.message(
      'Please try again later.',
      name: 'warningTryAgainLater',
      desc: '',
      args: [],
    );
  }

  /// `Already showing all content.`
  String get warningFilterAlreadyDisabled {
    return Intl.message(
      'Already showing all content.',
      name: 'warningFilterAlreadyDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Already showing only custom websites.`
  String get warningFilterAlreadyShowingYours {
    return Intl.message(
      'Already showing only custom websites.',
      name: 'warningFilterAlreadyShowingYours',
      desc: '',
      args: [],
    );
  }

  /// `You need to provide a valid URL.`
  String get warningInvalidURL {
    return Intl.message(
      'You need to provide a valid URL.',
      name: 'warningInvalidURL',
      desc: '',
      args: [],
    );
  }

  /// `A website with the same name already exists.`
  String get warningWebsiteNameExists {
    return Intl.message(
      'A website with the same name already exists.',
      name: 'warningWebsiteNameExists',
      desc: '',
      args: [],
    );
  }

  /// `You have not created any private websites yet.`
  String get warningNoPrivateWebsite {
    return Intl.message(
      'You have not created any private websites yet.',
      name: 'warningNoPrivateWebsite',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to create a public website.`
  String get warningNoPermissionToAddPublicWebsite {
    return Intl.message(
      'You do not have permission to create a public website.',
      name: 'warningNoPermissionToAddPublicWebsite',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to edit class information.`
  String get warningNoPermissionToEditClassInfo {
    return Intl.message(
      'You do not have permission to edit class information.',
      name: 'warningNoPermissionToEditClassInfo',
      desc: '',
      args: [],
    );
  }

  /// `Please authenticate in order to access this feature.`
  String get warningAuthenticationNeeded {
    return Intl.message(
      'Please authenticate in order to access this feature.',
      name: 'warningAuthenticationNeeded',
      desc: '',
      args: [],
    );
  }

  /// `There is nothing you have permission to edit.`
  String get warningNothingToEdit {
    return Intl.message(
      'There is nothing you have permission to edit.',
      name: 'warningNothingToEdit',
      desc: '',
      args: [],
    );
  }

  /// `Field cannot be empty.`
  String get warningFieldCannotBeEmpty {
    return Intl.message(
      'Field cannot be empty.',
      name: 'warningFieldCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Field cannot be zero.`
  String get warningFieldCannotBeZero {
    return Intl.message(
      'Field cannot be zero.',
      name: 'warningFieldCannotBeZero',
      desc: '',
      args: [],
    );
  }

  /// `None yet`
  String get warningNoneYet {
    return Intl.message(
      'None yet',
      name: 'warningNoneYet',
      desc: '',
      args: [],
    );
  }

  /// `You need to agree to the `
  String get warningAgreeTo {
    return Intl.message(
      'You need to agree to the ',
      name: 'warningAgreeTo',
      desc: '',
      args: [],
    );
  }

  /// `The request must not be empty`
  String get warningRequestEmpty {
    return Intl.message(
      'The request must not be empty',
      name: 'warningRequestEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Only {n} options can be selected at a time.`
  String warningOnlyNOptionsAtATime(Object n) {
    return Intl.message(
      'Only $n options can be selected at a time.',
      name: 'warningOnlyNOptionsAtATime',
      desc: '',
      args: [n],
    );
  }

  /// `No events to show`
  String get warningNoEvents {
    return Intl.message(
      'No events to show',
      name: 'warningNoEvents',
      desc: '',
      args: [],
    );
  }

  /// `You need to select at least one option.`
  String get warningYouNeedToSelectAtLeastOne {
    return Intl.message(
      'You need to select at least one option.',
      name: 'warningYouNeedToSelectAtLeastOne',
      desc: '',
      args: [],
    );
  }

  /// `Could not read favourite websites.`
  String get warningFavouriteWebsitesInitializationFailed {
    return Intl.message(
      'Could not read favourite websites.',
      name: 'warningFavouriteWebsitesInitializationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Unable to reach the news feed.`
  String get warningUnableToReachNewsFeed {
    return Intl.message(
      'Unable to reach the news feed.',
      name: 'warningUnableToReachNewsFeed',
      desc: '',
      args: [],
    );
  }

  /// `There are no news yet.`
  String get warningNoNews {
    return Intl.message(
      'There are no news yet.',
      name: 'warningNoNews',
      desc: '',
      args: [],
    );
  }

  /// `This event cannot be edited.`
  String get warningEventNotEditable {
    return Intl.message(
      'This event cannot be edited.',
      name: 'warningEventNotEditable',
      desc: '',
      args: [],
    );
  }

  /// `Ask for permissions`
  String get navigationAskPermissions {
    return Intl.message(
      'Ask for permissions',
      name: 'navigationAskPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get navigationHome {
    return Intl.message(
      'Home',
      name: 'navigationHome',
      desc: '',
      args: [],
    );
  }

  /// `Timetable`
  String get navigationTimetable {
    return Intl.message(
      'Timetable',
      name: 'navigationTimetable',
      desc: '',
      args: [],
    );
  }

  /// `Portal`
  String get navigationPortal {
    return Intl.message(
      'Portal',
      name: 'navigationPortal',
      desc: '',
      args: [],
    );
  }

  /// `Map`
  String get navigationMap {
    return Intl.message(
      'Map',
      name: 'navigationMap',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get navigationProfile {
    return Intl.message(
      'Profile',
      name: 'navigationProfile',
      desc: '',
      args: [],
    );
  }

  /// `People`
  String get navigationPeople {
    return Intl.message(
      'People',
      name: 'navigationPeople',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get navigationSettings {
    return Intl.message(
      'Settings',
      name: 'navigationSettings',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get navigationFilter {
    return Intl.message(
      'Filter',
      name: 'navigationFilter',
      desc: '',
      args: [],
    );
  }

  /// `Classes`
  String get navigationClasses {
    return Intl.message(
      'Classes',
      name: 'navigationClasses',
      desc: '',
      args: [],
    );
  }

  /// `Event details`
  String get navigationEventDetails {
    return Intl.message(
      'Event details',
      name: 'navigationEventDetails',
      desc: '',
      args: [],
    );
  }

  /// `News feed`
  String get navigationNewsFeed {
    return Intl.message(
      'News feed',
      name: 'navigationNewsFeed',
      desc: '',
      args: [],
    );
  }

  /// `Class information`
  String get navigationClassInfo {
    return Intl.message(
      'Class information',
      name: 'navigationClassInfo',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get navigationSearch {
    return Intl.message(
      'Search',
      name: 'navigationSearch',
      desc: '',
      args: [],
    );
  }

  /// `Classes found`
  String get navigationSearchResults {
    return Intl.message(
      'Classes found',
      name: 'navigationSearchResults',
      desc: '',
      args: [],
    );
  }

  /// `Show all`
  String get filterMenuShowAll {
    return Intl.message(
      'Show all',
      name: 'filterMenuShowAll',
      desc: '',
      args: [],
    );
  }

  /// `Show only mine`
  String get filterMenuShowMine {
    return Intl.message(
      'Show only mine',
      name: 'filterMenuShowMine',
      desc: '',
      args: [],
    );
  }

  /// `Filter by relevance`
  String get filterMenuRelevance {
    return Intl.message(
      'Filter by relevance',
      name: 'filterMenuRelevance',
      desc: '',
      args: [],
    );
  }

  /// `Bachelor's`
  String get filterNodeNameBSc {
    return Intl.message(
      'Bachelor\'s',
      name: 'filterNodeNameBSc',
      desc: '',
      args: [],
    );
  }

  /// `Master's`
  String get filterNodeNameMSc {
    return Intl.message(
      'Master\'s',
      name: 'filterNodeNameMSc',
      desc: '',
      args: [],
    );
  }

  /// `Only me`
  String get relevanceOnlyMe {
    return Intl.message(
      'Only me',
      name: 'relevanceOnlyMe',
      desc: '',
      args: [],
    );
  }

  /// `Anyone`
  String get relevanceAnyone {
    return Intl.message(
      'Anyone',
      name: 'relevanceAnyone',
      desc: '',
      args: [],
    );
  }

  /// `Personalization`
  String get settingsTitlePersonalization {
    return Intl.message(
      'Personalization',
      name: 'settingsTitlePersonalization',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get settingsItemDarkMode {
    return Intl.message(
      'Dark Mode',
      name: 'settingsItemDarkMode',
      desc: '',
      args: [],
    );
  }

  /// `Localization`
  String get settingsTitleLocalization {
    return Intl.message(
      'Localization',
      name: 'settingsTitleLocalization',
      desc: '',
      args: [],
    );
  }

  /// `Data control`
  String get settingsTitleDataControl {
    return Intl.message(
      'Data control',
      name: 'settingsTitleDataControl',
      desc: '',
      args: [],
    );
  }

  /// `Your editing permissions`
  String get settingsItemEditingPermissions {
    return Intl.message(
      'Your editing permissions',
      name: 'settingsItemEditingPermissions',
      desc: '',
      args: [],
    );
  }

  /// `No special permissions`
  String get settingsPermissionsNone {
    return Intl.message(
      'No special permissions',
      name: 'settingsPermissionsNone',
      desc: '',
      args: [],
    );
  }

  /// `Permission to add public info`
  String get settingsPermissionsAdd {
    return Intl.message(
      'Permission to add public info',
      name: 'settingsPermissionsAdd',
      desc: '',
      args: [],
    );
  }

  /// `Permission to edit public info`
  String get settingsPermissionsEdit {
    return Intl.message(
      'Permission to edit public info',
      name: 'settingsPermissionsEdit',
      desc: '',
      args: [],
    );
  }

  /// `Permissions request already sent`
  String get settingsPermissionsRequestSent {
    return Intl.message(
      'Permissions request already sent',
      name: 'settingsPermissionsRequestSent',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get settingsItemLanguage {
    return Intl.message(
      'Language',
      name: 'settingsItemLanguage',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get settingsItemLanguageEnglish {
    return Intl.message(
      'English',
      name: 'settingsItemLanguageEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Romanian`
  String get settingsItemLanguageRomanian {
    return Intl.message(
      'Romanian',
      name: 'settingsItemLanguageRomanian',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get settingsItemLanguageAuto {
    return Intl.message(
      'Auto',
      name: 'settingsItemLanguageAuto',
      desc: '',
      args: [],
    );
  }

  /// `Relevance filter`
  String get settingsRelevanceFilter {
    return Intl.message(
      'Relevance filter',
      name: 'settingsRelevanceFilter',
      desc: '',
      args: [],
    );
  }

  /// `Export events to Google Calendar`
  String get settingsExportToGoogleCalendar {
    return Intl.message(
      'Export events to Google Calendar',
      name: 'settingsExportToGoogleCalendar',
      desc: '',
      args: [],
    );
  }

  /// `Timetable`
  String get settingsTitleTimetable {
    return Intl.message(
      'Timetable',
      name: 'settingsTitleTimetable',
      desc: '',
      args: [],
    );
  }

  /// `Learning`
  String get websiteCategoryLearning {
    return Intl.message(
      'Learning',
      name: 'websiteCategoryLearning',
      desc: '',
      args: [],
    );
  }

  /// `Administrative`
  String get websiteCategoryAdministrative {
    return Intl.message(
      'Administrative',
      name: 'websiteCategoryAdministrative',
      desc: '',
      args: [],
    );
  }

  /// `Associations`
  String get websiteCategoryAssociations {
    return Intl.message(
      'Associations',
      name: 'websiteCategoryAssociations',
      desc: '',
      args: [],
    );
  }

  /// `Resources`
  String get websiteCategoryResources {
    return Intl.message(
      'Resources',
      name: 'websiteCategoryResources',
      desc: '',
      args: [],
    );
  }

  /// `Others`
  String get websiteCategoryOthers {
    return Intl.message(
      'Others',
      name: 'websiteCategoryOthers',
      desc: '',
      args: [],
    );
  }

  /// `Lab`
  String get uniEventTypeLab {
    return Intl.message(
      'Lab',
      name: 'uniEventTypeLab',
      desc: '',
      args: [],
    );
  }

  /// `Seminar`
  String get uniEventTypeSeminar {
    return Intl.message(
      'Seminar',
      name: 'uniEventTypeSeminar',
      desc: '',
      args: [],
    );
  }

  /// `Lecture`
  String get uniEventTypeLecture {
    return Intl.message(
      'Lecture',
      name: 'uniEventTypeLecture',
      desc: '',
      args: [],
    );
  }

  /// `Sports`
  String get uniEventTypeSports {
    return Intl.message(
      'Sports',
      name: 'uniEventTypeSports',
      desc: '',
      args: [],
    );
  }

  /// `Exam`
  String get uniEventTypeExam {
    return Intl.message(
      'Exam',
      name: 'uniEventTypeExam',
      desc: '',
      args: [],
    );
  }

  /// `Homework`
  String get uniEventTypeHomework {
    return Intl.message(
      'Homework',
      name: 'uniEventTypeHomework',
      desc: '',
      args: [],
    );
  }

  /// `Project`
  String get uniEventTypeProject {
    return Intl.message(
      'Project',
      name: 'uniEventTypeProject',
      desc: '',
      args: [],
    );
  }

  /// `Test`
  String get uniEventTypeTest {
    return Intl.message(
      'Test',
      name: 'uniEventTypeTest',
      desc: '',
      args: [],
    );
  }

  /// `Practical`
  String get uniEventTypePractical {
    return Intl.message(
      'Practical',
      name: 'uniEventTypePractical',
      desc: '',
      args: [],
    );
  }

  /// `Research`
  String get uniEventTypeResearch {
    return Intl.message(
      'Research',
      name: 'uniEventTypeResearch',
      desc: '',
      args: [],
    );
  }

  /// `Holiday`
  String get uniEventTypeHoliday {
    return Intl.message(
      'Holiday',
      name: 'uniEventTypeHoliday',
      desc: '',
      args: [],
    );
  }

  /// `Exam session`
  String get uniEventTypeExamSession {
    return Intl.message(
      'Exam session',
      name: 'uniEventTypeExamSession',
      desc: '',
      args: [],
    );
  }

  /// `Semester`
  String get uniEventTypeSemester {
    return Intl.message(
      'Semester',
      name: 'uniEventTypeSemester',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get uniEventTypeOther {
    return Intl.message(
      'Other',
      name: 'uniEventTypeOther',
      desc: '',
      args: [],
    );
  }

  /// `Welcome!`
  String get messageWelcomeSimple {
    return Intl.message(
      'Welcome!',
      name: 'messageWelcomeSimple',
      desc: '',
      args: [],
    );
  }

  /// `Welcome, {name}!`
  String messageWelcomeName(Object name) {
    return Intl.message(
      'Welcome, $name!',
      name: 'messageWelcomeName',
      desc: '',
      args: [name],
    );
  }

  /// `New user?`
  String get messageNewUser {
    return Intl.message(
      'New user?',
      name: 'messageNewUser',
      desc: '',
      args: [],
    );
  }

  /// `Account is not verified.`
  String get messageEmailNotVerified {
    return Intl.message(
      'Account is not verified.',
      name: 'messageEmailNotVerified',
      desc: '',
      args: [],
    );
  }

  /// `You need to be logged in to perform this action.`
  String get messageNotLoggedIn {
    return Intl.message(
      'You need to be logged in to perform this action.',
      name: 'messageNotLoggedIn',
      desc: '',
      args: [],
    );
  }

  /// `Your account needs to be verified to perform this action.`
  String get messageEmailNotVerifiedToPerformAction {
    return Intl.message(
      'Your account needs to be verified to perform this action.',
      name: 'messageEmailNotVerifiedToPerformAction',
      desc: '',
      args: [],
    );
  }

  /// `Account created successfully.`
  String get messageAccountCreated {
    return Intl.message(
      'Account created successfully.',
      name: 'messageAccountCreated',
      desc: '',
      args: [],
    );
  }

  /// `Account deleted successfully.`
  String get messageAccountDeleted {
    return Intl.message(
      'Account deleted successfully.',
      name: 'messageAccountDeleted',
      desc: '',
      args: [],
    );
  }

  /// `You will receive a mail confirmation if your request is approved.`
  String get messageAnnouncedOnMail {
    return Intl.message(
      'You will receive a mail confirmation if your request is approved.',
      name: 'messageAnnouncedOnMail',
      desc: '',
      args: [],
    );
  }

  /// `Please check your email for account verification.`
  String get messageCheckEmailVerification {
    return Intl.message(
      'Please check your email for account verification.',
      name: 'messageCheckEmailVerification',
      desc: '',
      args: [],
    );
  }

  /// `Enter your e-mai in order to receive instructions on how to reset your password.`
  String get messageResetPassword {
    return Intl.message(
      'Enter your e-mai in order to receive instructions on how to reset your password.',
      name: 'messageResetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account?`
  String get messageDeleteAccount {
    return Intl.message(
      'Are you sure you want to delete your account?',
      name: 'messageDeleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `This action cannot be undone.`
  String get messageCannotBeUndone {
    return Intl.message(
      'This action cannot be undone.',
      name: 'messageCannotBeUndone',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to change the account email to {email}?`
  String messageChangeEmail(Object email) {
    return Intl.message(
      'Are you sure you want to change the account email to $email?',
      name: 'messageChangeEmail',
      desc: '',
      args: [email],
    );
  }

  /// `Under construction`
  String get messageUnderConstruction {
    return Intl.message(
      'Under construction',
      name: 'messageUnderConstruction',
      desc: '',
      args: [],
    );
  }

  /// `Try tapping/long-pressing/hovering the preview to test the new website.`
  String get messageWebsitePreview {
    return Intl.message(
      'Try tapping/long-pressing/hovering the preview to test the new website.',
      name: 'messageWebsitePreview',
      desc: '',
      args: [],
    );
  }

  /// `Try adding a custom website.`
  String get messageAddCustomWebsite {
    return Intl.message(
      'Try adding a custom website.',
      name: 'messageAddCustomWebsite',
      desc: '',
      args: [],
    );
  }

  /// `Website added successfully.`
  String get messageWebsiteAdded {
    return Intl.message(
      'Website added successfully.',
      name: 'messageWebsiteAdded',
      desc: '',
      args: [],
    );
  }

  /// `Website modified successfully.`
  String get messageWebsiteEdited {
    return Intl.message(
      'Website modified successfully.',
      name: 'messageWebsiteEdited',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this website?`
  String get messageDeleteWebsite {
    return Intl.message(
      'Are you sure you want to delete this website?',
      name: 'messageDeleteWebsite',
      desc: '',
      args: [],
    );
  }

  /// `Website deleted successfully.`
  String get messageWebsiteDeleted {
    return Intl.message(
      'Website deleted successfully.',
      name: 'messageWebsiteDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this event?`
  String get messageDeleteEvent {
    return Intl.message(
      'Are you sure you want to delete this event?',
      name: 'messageDeleteEvent',
      desc: '',
      args: [],
    );
  }

  /// `Event deleted successfully.`
  String get messageEventDeleted {
    return Intl.message(
      'Event deleted successfully.',
      name: 'messageEventDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Event added successfully.`
  String get messageEventAdded {
    return Intl.message(
      'Event added successfully.',
      name: 'messageEventAdded',
      desc: '',
      args: [],
    );
  }

  /// `Event modified successfully.`
  String get messageEventEdited {
    return Intl.message(
      'Event modified successfully.',
      name: 'messageEventEdited',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete "{shortcutName}"?`
  String messageDeleteShortcut(Object shortcutName) {
    return Intl.message(
      'Are you sure you want to delete "$shortcutName"?',
      name: 'messageDeleteShortcut',
      desc: '',
      args: [shortcutName],
    );
  }

  /// `This could affect other students.`
  String get messageThisCouldAffectOtherStudents {
    return Intl.message(
      'This could affect other students.',
      name: 'messageThisCouldAffectOtherStudents',
      desc: '',
      args: [],
    );
  }

  /// `Shortcut deleted successfully.`
  String get messageShortcutDeleted {
    return Intl.message(
      'Shortcut deleted successfully.',
      name: 'messageShortcutDeleted',
      desc: '',
      args: [],
    );
  }

  /// `You have not added any classes yet.`
  String get messageNoClassesYet {
    return Intl.message(
      'You have not added any classes yet.',
      name: 'messageNoClassesYet',
      desc: '',
      args: [],
    );
  }

  /// `Get started by pressing the`
  String get messageGetStartedByPressing {
    return Intl.message(
      'Get started by pressing the',
      name: 'messageGetStartedByPressing',
      desc: '',
      args: [],
    );
  }

  /// `button above`
  String get messageButtonAbove {
    return Intl.message(
      'button above',
      name: 'messageButtonAbove',
      desc: '',
      args: [],
    );
  }

  /// `Why do you want edit permissions for {appName}?`
  String messageAskPermissionToEdit(Object appName) {
    return Intl.message(
      'Why do you want edit permissions for $appName?',
      name: 'messageAskPermissionToEdit',
      desc: '',
      args: [appName],
    );
  }

  /// `The request has been sent succesfully.`
  String get messageRequestHasBeenSent {
    return Intl.message(
      'The request has been sent succesfully.',
      name: 'messageRequestHasBeenSent',
      desc: '',
      args: [],
    );
  }

  /// `You have already submitted a request. If you want to add another one, please press 'Send'.`
  String get messageRequestAlreadyExists {
    return Intl.message(
      'You have already submitted a request. If you want to add another one, please press \'Send\'.',
      name: 'messageRequestAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `I agree to the `
  String get messageIAgreeToThe {
    return Intl.message(
      'I agree to the ',
      name: 'messageIAgreeToThe',
      desc: '',
      args: [],
    );
  }

  /// `Profile updated successfully.`
  String get messageEditProfileSuccess {
    return Intl.message(
      'Profile updated successfully.',
      name: 'messageEditProfileSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Tap for more info`
  String get messageTapForMoreInfo {
    return Intl.message(
      'Tap for more info',
      name: 'messageTapForMoreInfo',
      desc: '',
      args: [],
    );
  }

  /// `Password changed successfully.`
  String get messageChangePasswordSuccess {
    return Intl.message(
      'Password changed successfully.',
      name: 'messageChangePasswordSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Email changed successfully`
  String get messageChangeEmailSuccess {
    return Intl.message(
      'Email changed successfully',
      name: 'messageChangeEmailSuccess',
      desc: '',
      args: [],
    );
  }

  /// `I will only upload information that is correct and accurate, to the best of my knowledge. I understand that submitting erroneous or offensive information on purpose will lead to my editing permissions being permanently revoked.`
  String get messageAgreePermissions {
    return Intl.message(
      'I will only upload information that is correct and accurate, to the best of my knowledge. I understand that submitting erroneous or offensive information on purpose will lead to my editing permissions being permanently revoked.',
      name: 'messageAgreePermissions',
      desc: '',
      args: [],
    );
  }

  /// `You can contribute to the app data, but you first need to request permissions.`
  String get messageYouCanContribute {
    return Intl.message(
      'You can contribute to the app data, but you first need to request permissions.',
      name: 'messageYouCanContribute',
      desc: '',
      args: [],
    );
  }

  /// `There are no events for the selected `
  String get messageThereAreNoEventsForSelected {
    return Intl.message(
      'There are no events for the selected ',
      name: 'messageThereAreNoEventsForSelected',
      desc: '',
      args: [],
    );
  }

  /// `Profile picture updated successfully.`
  String get messagePictureUpdatedSuccess {
    return Intl.message(
      'Profile picture updated successfully.',
      name: 'messagePictureUpdatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Do you have another question?`
  String get messageAnotherQuestion {
    return Intl.message(
      'Do you have another question?',
      name: 'messageAnotherQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Talk to Polly!`
  String get messageTalkToChatbot {
    return Intl.message(
      'Talk to Polly!',
      name: 'messageTalkToChatbot',
      desc: '',
      args: [],
    );
  }

  /// `Please check your inbox for the password reset e-mail.`
  String get infoPasswordResetEmailSent {
    return Intl.message(
      'Please check your inbox for the password reset e-mail.',
      name: 'infoPasswordResetEmailSent',
      desc: '',
      args: [],
    );
  }

  /// `Try to choose the most restrictive category.`
  String get infoRelevance {
    return Intl.message(
      'Try to choose the most restrictive category.',
      name: 'infoRelevance',
      desc: '',
      args: [],
    );
  }

  /// `Select the`
  String get infoSelect {
    return Intl.message(
      'Select the',
      name: 'infoSelect',
      desc: '',
      args: [],
    );
  }

  /// `You first need to select the`
  String get infoYouNeedToSelect {
    return Intl.message(
      'You first need to select the',
      name: 'infoYouNeedToSelect',
      desc: '',
      args: [],
    );
  }

  /// `classes you are interested in`
  String get infoClasses {
    return Intl.message(
      'classes you are interested in',
      name: 'infoClasses',
      desc: '',
      args: [],
    );
  }

  /// `Make sure your group/subgroup is selected in the`
  String get infoMakeSureGroupIsSelected {
    return Intl.message(
      'Make sure your group/subgroup is selected in the',
      name: 'infoMakeSureGroupIsSelected',
      desc: '',
      args: [],
    );
  }

  /// `If this is relevant for everyone, don't select anything .`
  String get infoRelevanceNothingSelected {
    return Intl.message(
      'If this is relevant for everyone, don\'t select anything .',
      name: 'infoRelevanceNothingSelected',
      desc: '',
      args: [],
    );
  }

  /// `For instance, if something is only relevant for "314CB" and "315CB", don't just set "CB".`
  String get infoRelevanceExample {
    return Intl.message(
      'For instance, if something is only relevant for "314CB" and "315CB", don\'t just set "CB".',
      name: 'infoRelevanceExample',
      desc: '',
      args: [],
    );
  }

  /// `It must contain lower and uppercase letters, one number and one special character, and have a minimum length of 8.`
  String get infoPassword {
    return Intl.message(
      'It must contain lower and uppercase letters, one number and one special character, and have a minimum length of 8.',
      name: 'infoPassword',
      desc: '',
      args: [],
    );
  }

  /// `{appName} is open source.`
  String infoAppIsOpenSource(Object appName) {
    return Intl.message(
      '$appName is open source.',
      name: 'infoAppIsOpenSource',
      desc: '',
      args: [appName],
    );
  }

  /// `This is the same username you use to log in to {forum}.`
  String infoEmail(Object forum) {
    return Intl.message(
      'This is the same username you use to log in to $forum.',
      name: 'infoEmail',
      desc: '',
      args: [forum],
    );
  }

  /// `Loading...`
  String get infoLoading {
    return Intl.message(
      'Loading...',
      name: 'infoLoading',
      desc: '',
      args: [],
    );
  }

  /// `Read the {appName} policy`
  String infoReadThePolicy(Object appName) {
    return Intl.message(
      'Read the $appName policy',
      name: 'infoReadThePolicy',
      desc: '',
      args: [appName],
    );
  }

  /// `Export filtered events from Timetable`
  String get infoExportToGoogleCalendar {
    return Intl.message(
      'Export filtered events from Timetable',
      name: 'infoExportToGoogleCalendar',
      desc: '',
      args: [],
    );
  }

  /// `@stud.acs.upb.ro`
  String get stringEmailDomain {
    return Intl.message(
      '@stud.acs.upb.ro',
      name: 'stringEmailDomain',
      desc: '',
      args: [],
    );
  }

  /// `cs.curs.pub.ro`
  String get stringForum {
    return Intl.message(
      'cs.curs.pub.ro',
      name: 'stringForum',
      desc: '',
      args: [],
    );
  }

  /// `Anonymous`
  String get stringAnonymous {
    return Intl.message(
      'Anonymous',
      name: 'stringAnonymous',
      desc: '',
      args: [],
    );
  }

  /// `and`
  String get stringAnd {
    return Intl.message(
      'and',
      name: 'stringAnd',
      desc: '',
      args: [],
    );
  }

  /// `assets/images/acs_banner_en.png`
  String get fileAcsBanner {
    return Intl.message(
      'assets/images/acs_banner_en.png',
      name: 'fileAcsBanner',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ro'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}