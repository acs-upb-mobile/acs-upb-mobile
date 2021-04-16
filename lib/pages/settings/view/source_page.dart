import 'dart:ui';

import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SourcePage extends StatefulWidget {
  @override
  _SourcePageState createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  bool wantsOfficialInfo;
  bool wantsOrganizationInfo;
  bool wantsStudentsInfo;
  AuthProvider authProvider;

  @override
  void initState() {
    super.initState();

    authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUserFromCache;
    wantsOrganizationInfo = user.canReadOrganizationInfo ?? false;
    wantsStudentsInfo = user.canReadStudentInfo ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      actions: [
        AppScaffoldAction(
            text: S.of(context).buttonSave,
            onPressed: () async {
              final List<String> sources = ['official'];
              if (wantsOrganizationInfo) sources.add('organizations');
              if (wantsStudentsInfo) sources.add('students');
              await authProvider.setSourcePreferences(sources);
              Navigator.of(context).pop();
            })
      ],
      title: Text(
        S.of(context).sectionInformationSources,
        style: const TextStyle(fontSize: 19.5),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text('${S.of(context).messageSelectSource}*'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              S.of(context).hintSelectSources,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            value: true,
            onChanged: null,
            title: Text(S.of(context).sourceOfficial),
            subtitle: Text(S.of(context).sourceOfficialWebPages),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: wantsOrganizationInfo,
            onChanged: (value) {
              setState(() {
                wantsOrganizationInfo = value;
              });
            },
            title: Text('${S.of(context).sourceOrganization}*'),
            subtitle: Text(S.of(context).sourceStudentOrganizations),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: wantsStudentsInfo,
            onChanged: (value) {
              setState(() {
                wantsStudentsInfo = value;
              });
            },
            title: Text('${S.of(context).sourceStudentRepresentative}*'),
            subtitle: Text(S.of(context).sourceStudentExamples),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '* ${S.of(context).infoAdditionInformationSources}',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
                height: MediaQuery.of(context).size.height / 3,
                child: Image.asset(
                    'assets/illustrations/undraw_selected_options.png')),
          ),
        ],
      ),
    );
  }
}
