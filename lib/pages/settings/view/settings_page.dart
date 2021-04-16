import 'dart:io';

import 'package:acs_upb_mobile/authentication/model/user.dart';
import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/navigation/routes.dart';
import 'package:acs_upb_mobile/pages/settings/service/request_provider.dart';
import 'package:acs_upb_mobile/pages/settings/view/source_page.dart';
import 'package:acs_upb_mobile/resources/locale_provider.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/icon_text.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';
import 'package:time_machine/time_machine.dart';

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
      userPermissionString = S.of(context).infoLoading;
      checkUserPermissionsString()
          .then((value) => setState(() => userPermissionString = value));
    }

    return AppScaffold(
      title: Text(S.of(context).navigationSettings),
      body: PreferencePage(
        [
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
                PreferenceTitle(S.of(context).settingsTitlePersonalization),
                SwitchPreference(
                  S.of(context).settingsItemDarkMode,
                  'dark_mode',
                  onEnable: () {
                    DynamicTheme.of(context).setBrightness(Brightness.dark);
                  },
                  onDisable: () {
                    DynamicTheme.of(context).setBrightness(Brightness.light);
                  },
                  defaultVal: MediaQuery.of(context).platformBrightness ==
                      Brightness.dark,
                ),
                PreferenceTitle(S.of(context).settingsTitleLocalization),
                PreferenceDialogLink(
                  S.of(context).settingsItemLanguage,
                  desc: languagePrefString(PrefService.get('language')),
                  dialog: PreferenceDialog(
                    [
                      languageRadioPreference(context, 'ro'),
                      languageRadioPreference(context, 'en'),
                      languageRadioPreference(context, 'auto'),
                    ],
                    onlySaveOnSubmit: false,
                  ),
                ),
                PreferenceTitle(S.of(context).settingsTitleDataControl),
                PreferenceTitle(S.of(context).settingsTitleData),
                ListTile(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<SourcePage>(
                          builder: (context) => SourcePage())),
                  title: Text(S.of(context).sectionInformationSources),
                  subtitle: FutureBuilder<User>(
                      future: authProvider.currentUser,
                      builder: (context, snap) {
                        if (snap.hasData) {
                          final sources = snap.data.sources;
                          return Text(((sources?.isEmpty ?? true) ||
                                  sources.length == 3)
                              ? S.of(context).labelAll
                              : sources
                                  .map(localizedSourceString)
                                  .toList()
                                  .join(', '));
                        } else {
                          return Container();
                        }
                      }),
                ),
                ListTile(
                  key: const ValueKey('ask_permissions'),
                  onTap: () {
                    if (authProvider.isAnonymous) {
                      AppToast.show(S.of(context).messageNotLoggedIn);
                    } else if (isVerified != true) {
                      AppToast.show(
                          S.of(context).messageEmailNotVerifiedToPerformAction);
                    } else {
                      Navigator.of(context)
                          .pushNamed(Routes.requestPermissions);
                    }
                  },
                  title: Text(S.of(context).settingsItemEditingPermissions),
                  subtitle: Text(userPermissionString),
                ),
                ListTile(
                  onTap: () =>
                      Utils.launchURL(Utils.privacyPolicyURL, context: context),
                  title: Text(S.of(context).labelPrivacyPolicy),
                  subtitle: Text(
                    S.of(context).infoReadThePolicy(Utils.packageInfo.appName),
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
                        actionText: S.of(context).actionContribute,
                        actionArrow: true,
                        align: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .apply(color: Theme.of(context).hintColor),
                        onTap: () =>
                            Utils.launchURL(Utils.repoURL, context: context),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        '${S.of(context).labelVersion} ${Utils.packageInfo.version}+${(int.parse(Utils.packageInfo.buildNumber) % 10000).toString()}',
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

  RadioPreference<String> languageRadioPreference(
      BuildContext context, String preference) {
    return RadioPreference(
      languagePrefString(preference),
      preference,
      'language',
      onSelect: () {
        // Reload settings page
        setState(() {
          Culture.current = LocaleProvider.cultures[preference];
          S.load(LocaleProvider.localeFromString(preference));
          Navigator.of(context).pop();

          // Hack to notify all widgets that something changed, since the
          // localizations delegate doesn't do that. Pretend to change the theme
          // so that listeners have to reload.
          DynamicTheme.of(context)
              .setBrightness(DynamicTheme.of(context).brightness);
        });
      },
    );
  }

  String languagePrefString(String preference) {
    switch (preference) {
      case 'en':
        return S.of(context).settingsItemLanguageEnglish;
      case 'ro':
        return S.of(context).settingsItemLanguageRomanian;
      case 'auto':
        return S.of(context).settingsItemLanguageAuto;
      default:
        stderr.writeln('Invalid preference string: $preference');
        return S.of(context).settingsItemLanguageAuto;
    }
  }

  String localizedSourceString(String source) {
    switch (source) {
      case 'official':
        return S.of(context).sourceOfficial;
      case 'organizations':
        return S.of(context).sourceOrganization;
      case 'students':
        return S.of(context).sourceStudentRepresentative;
      default:
        return source;
    }
  }

  Future<String> checkUserPermissionsString() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final requestProvider =
        Provider.of<RequestProvider>(context, listen: false);

    if (authProvider.isAuthenticated && !authProvider.isAnonymous) {
      final user = await authProvider.currentUser;
      if (user.canEditPublicInfo) {
        return S.of(context).settingsPermissionsEdit;
      } else if (user.canAddPublicInfo) {
        return S.of(context).settingsPermissionsAdd;
      } else if (await requestProvider.userAlreadyRequested(user.uid)) {
        return S.of(context).settingsPermissionsRequestSent;
      }
    }
    return S.of(context).settingsPermissionsNone;
  }
}
