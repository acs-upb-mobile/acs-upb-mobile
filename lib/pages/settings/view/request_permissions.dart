import 'package:acs_upb_mobile/authentication/model/user.dart';
import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/settings/model/request.dart';
import 'package:acs_upb_mobile/pages/settings/service/request_provider.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/button.dart';
import 'package:acs_upb_mobile/widgets/dialog.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestPermissionsPage extends StatefulWidget {
  static const String routeName = '/requestPermissions';

  @override
  State<StatefulWidget> createState() => _RequestPermissionsPageState();
}

class _RequestPermissionsPageState extends State<RequestPermissionsPage> {
  User user;
  bool agreedToResponsibilities = false;
  TextEditingController requestController = TextEditingController();

  Future<void> _fetchUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    user = await authProvider.currentUser;
    if (mounted) {
      setState(() {});
    }
  }

  AppDialog _requestAlreadyExistsDialog(BuildContext context) {
    return AppDialog(
      title: S.of(context).warningRequestExists,
      content: [
        Text(S.of(context).messageRequestAlreadyExists),
      ],
      actions: [
        AppButton(
            key: const ValueKey('agree_overwrite_request'),
            text: S.of(context).buttonSend,
            color: Theme.of(context).accentColor,
            width: 130,
            onTap: () async {
              Navigator.of(context).pop();
            }),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context);

    return AppScaffold(
        title: Text(S.of(context).navigationAskPermissions),
        actions: [
          AppScaffoldAction(
              text: S.of(context).buttonSave,
              onPressed: () async {
                if (!agreedToResponsibilities) {
                  AppToast.show(
                      '${S.of(context).warningAgreeTo}${S.of(context).labelPermissionsConsent}.');
                  return;
                }

                if (requestController.text == '') {
                  AppToast.show(S.of(context).warningRequestEmpty);
                  return;
                }

                /*
                 * Check if there is already a request registered for the current
                 * user.
                 */
                bool queryResult = await requestProvider
                    .userAlreadyRequested(user.uid, context: context);

                if (queryResult) {
                  await showDialog(
                      context: context, builder: _requestAlreadyExistsDialog);
                }

                queryResult = await requestProvider.makeRequest(
                    Request(
                      userId: user.uid,
                      requestBody: requestController.text,
                    ),
                    context: context);
                if (queryResult) {
                  AppToast.show(S.of(context).messageRequestHasBeenSent);
                  Navigator.of(context).pop();
                }
              })
        ],
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                  height: MediaQuery.of(context).size.height / 4,
                  child: Image.asset('assets/illustrations/undraw_hiring.png')),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                S.of(context)
                    .messageAskPermissionToEdit(Utils.packageInfo.appName),
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(S.of(context).messageAnnouncedOnMail,
                  style: Theme.of(context).textTheme.caption.apply(
                      color: Theme.of(context).textTheme.headline5.color)),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 10,
                controller: requestController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: agreedToResponsibilities,
                    visualDensity: VisualDensity.compact,
                    onChanged: (value) =>
                        setState(() => agreedToResponsibilities = value),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.25),
                      child: Text(
                        S.of(context).messageAgreePermissions,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
