import 'dart:io';

import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/navigation/routes.dart';
import 'package:acs_upb_mobile/pages/settings/service/request_provider.dart';
import 'package:acs_upb_mobile/pages/timetable/service/uni_event_provider.dart';
import 'package:acs_upb_mobile/resources/locale_provider.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/icon_text.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings';

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Whether the user verified their email; this can be true, false or null if
  // the async check hasn't completed yet.
  bool isVerified;

  // String describing the level of editing permissions that the user has.
  String userPermissionString = '';

  @override
  void initState() {
    super.initState();
    Provider.of<AuthProvider>(context, listen: false)
        .isVerified
        .then((value) => setState(() => isVerified = value));
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context);
    if (userPermissionString.isEmpty) {
      userPermissionString = S.current.infoLoading;
      checkUserPermissionsString()
          .then((value) => setState(() => userPermissionString = value));
    }

    return AppScaffold(
      title: Text(S.current.navigationSettings),
      body: PrefPage(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      height: MediaQuery.of(context).size.height / 3,
                      child: Image.asset(
                          'assets/illustrations/undraw_settings.png')),
                ),
                const SizedBox(height: 10),
                categoryTitle(S.current.settingsTitlePersonalization),
                // TODO(IoanaAlexandru): Make this an option out of 3 (light, dark, auto)
                PrefSwitch(
                  title: Text(S.current.settingsItemDarkMode),
                  pref: 'dark_mode',
                  onChange: (selected) {
                    if (selected) {
                      EasyDynamicTheme.of(context).changeTheme(dark: true);
                    } else {
                      EasyDynamicTheme.of(context).changeTheme(dark: false);
                    }
                  },
                ),
                categoryTitle(S.current.settingsTitleLocalization),
                PrefDialogButton(
                  title: Text(S.current.settingsItemLanguage),
                  subtitle: Text(
                      languagePrefString(context, prefService.get('language'))),
                  dialog: PrefDialog(
                    children: [
                      languageRadioPreference(context, 'ro'),
                      languageRadioPreference(context, 'en'),
                      languageRadioPreference(context, 'auto'),
                    ],
                    onlySaveOnSubmit: false,
                  ),
                ),
                categoryTitle(S.current.settingsTitleDataControl),
                ListTile(
                  key: const ValueKey('ask_permissions'),
                  onTap: () {
                    if (authProvider.isAnonymous) {
                      AppToast.show(S.current.messageNotLoggedIn);
                    } else if (isVerified != true) {
                      AppToast.show(
                          S.current.messageEmailNotVerifiedToPerformAction);
                    } else {
                      Navigator.of(context)
                          .pushNamed(Routes.requestPermissions);
                    }
                  },
                  title: Text(S.current.settingsItemEditingPermissions),
                  subtitle: Text(userPermissionString),
                ),
                ListTile(
                  onTap: () => Utils.launchURL(Utils.privacyPolicyURL),
                  title: Text(S.current.labelPrivacyPolicy),
                  subtitle: Text(
                    S.current.infoReadThePolicy(Utils.packageInfo.appName),
                  ),
                ),
                Visibility(
                  visible: Platform.isAndroid || Platform.isIOS,
                  child: categoryTitle(S.current.settingsTitleTimetable),
                ),
                Visibility(
                  visible: Platform.isAndroid || Platform.isIOS,
                  child: ListTile(
                    key: const ValueKey('google_calendar'),
                    onTap: () async {
                      if (authProvider.isAnonymous) {
                        AppToast.show(S.current.messageNotLoggedIn);
                      } else {
                        final eventProvider = Provider.of<UniEventProvider>(
                            context,
                            listen: false);
//                        await eventProvider.exportToGoogleCalendar();
                      }
                    },
                    title: Text(S.current.settingsExportToGoogleCalendar),
                    subtitle: Text(S.current.infoExportToGoogleCalendar),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: IconText(
                        icon: FeatherIcons.github,
                        text: S
                            .of(context)
                            .infoAppIsOpenSource(Utils.packageInfo.appName),
                        actionText: S.current.actionContribute,
                        actionArrow: true,
                        align: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .apply(color: Theme.of(context).hintColor),
                        onTap: () => Utils.launchURL(Utils.repoURL),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        '${S.current.labelVersion} ${Utils.packageInfo.version}+${(int.parse(Utils.packageInfo.buildNumber) % 10000).toString()}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .apply(color: Theme.of(context).hintColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget categoryTitle(String title) => Padding(
        padding: const EdgeInsets.only(left: 10, top: 10),
        child: Text(
          title,
          style: Theme.of(context)
              .accentTextTheme
              .subtitle2
              .apply(fontWeightDelta: 2),
        ),
      );

  PrefRadio<String> languageRadioPreference(
      BuildContext context, String preference) {
    return PrefRadio(
      title: Text(languagePrefString(context, preference)),
      value: preference,
      pref: 'language',
      onSelect: () {
        // Reload settings page
        setState(() {
          S.load(LocaleProvider.localeFromString(preference));
          Navigator.of(context).pop();
        });
      },
    );
  }

  String languagePrefString(BuildContext context, String preference) {
    switch (preference) {
      case 'en':
        return S.current.settingsItemLanguageEnglish;
      case 'ro':
        return S.current.settingsItemLanguageRomanian;
      case 'auto':
        return S.current.settingsItemLanguageAuto;
      default:
        stderr.writeln('Invalid preference string: $preference');
        return S.current.settingsItemLanguageAuto;
    }
  }

  Future<String> checkUserPermissionsString() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final requestProvider =
        Provider.of<RequestProvider>(context, listen: false);

    if (authProvider.isAuthenticated && !authProvider.isAnonymous) {
      final user = await authProvider.currentUser;
      if (user.canEditPublicInfo) {
        return S.current.settingsPermissionsEdit;
      } else if (user.canAddPublicInfo) {
        return S.current.settingsPermissionsAdd;
      } else if (await requestProvider.userAlreadyRequested(user.uid)) {
        return S.current.settingsPermissionsRequestSent;
      }
    }
    return S.current.settingsPermissionsNone;
  }
}
