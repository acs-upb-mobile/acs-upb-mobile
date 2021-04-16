import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/classes/model/class.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';

class ShortcutView extends StatefulWidget {
  const ShortcutView({Key key, this.onSave}) : super(key: key);

  final void Function(Shortcut) onSave;

  @override
  _ShortcutViewState createState() => _ShortcutViewState();
}

class _ShortcutViewState extends State<ShortcutView> {
  final formKey = GlobalKey<FormState>();
  ShortcutType selectedType = ShortcutType.resource;
  TextEditingController labelController = TextEditingController();
  TextEditingController linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: Text(S.of(context).actionAddShortcut),
      actions: [
        AppScaffoldAction(
            text: S.of(context).buttonSave,
            onPressed: () {
              if (formKey.currentState.validate()) {
                widget.onSave(Shortcut(
                  name: labelController.text,
                  link: linkController.text,
                  type: selectedType,
                  ownerUid:
                      Provider.of<AuthProvider>(context, listen: false).uid,
                ));
                Navigator.of(context).pop();
              }
            })
      ],
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Form(
          key: formKey,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                    height: MediaQuery.of(context).size.height / 3,
                    child: Image.asset(
                        'assets/illustrations/undraw_share_link.png')),
              ),
              TextFormField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: S.of(context).labelName,
                  hintText: S.of(context).hintWebsiteLabel,
                  prefixIcon: const Icon(Icons.label_outlined),
                ),
                onChanged: (_) => setState(() {}),
              ),
              DropdownButtonFormField<ShortcutType>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: S.of(context).labelType,
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                value: selectedType,
                items: ShortcutType.values
                    .map(
                      (type) => DropdownMenuItem<ShortcutType>(
                        value: type,
                        child: Text(type.toLocalizedString(context)),
                      ),
                    )
                    .toList(),
                onChanged: (selection) =>
                    setState(() => selectedType = selection),
              ),
              TextFormField(
                controller: linkController,
                decoration: InputDecoration(
                  labelText: '${S.of(context).labelLink} *',
                  hintText: S.of(context).hintWebsiteLink,
                  prefixIcon: const Icon(FeatherIcons.globe),
                ),
                validator: (value) {
                  if (!isURL(value, requireProtocol: true)) {
                    return S.of(context).warningInvalidURL;
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
