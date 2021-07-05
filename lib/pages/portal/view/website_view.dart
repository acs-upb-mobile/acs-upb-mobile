import 'package:acs_upb_mobile/authentication/model/user.dart';
import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/filter/view/relevance_picker.dart';
import 'package:acs_upb_mobile/pages/portal/model/website.dart';
import 'package:acs_upb_mobile/pages/portal/service/website_provider.dart';
import 'package:acs_upb_mobile/resources/locale_provider.dart';
import 'package:acs_upb_mobile/resources/storage/storage_provider.dart';
import 'package:acs_upb_mobile/resources/theme.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/button.dart';
import 'package:acs_upb_mobile/widgets/circle_image.dart';
import 'package:acs_upb_mobile/widgets/dialog.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:validators/validators.dart';

class WebsiteView extends StatefulWidget {
  // If [updateExisting] is true, this acts like an "Edit website" page starting
  // from the info in [website]. Otherwise, it acts like an "Add website" page.
  WebsiteView({Key key, this.website, this.updateExisting = false})
      : super(key: key) {
    if (updateExisting == true && website == null) {
      throw ArgumentError(
          'WebsiteView: website cannot be null if updateExisting is true');
    }
  }

  final Website website;
  final bool updateExisting;

  @override
  _WebsiteViewState createState() => _WebsiteViewState();
}

class _WebsiteViewState extends State<WebsiteView> {
  final _formKey = GlobalKey<FormState>();

  WebsiteCategory _selectedCategory;
  TextEditingController _labelController;
  TextEditingController _linkController;
  TextEditingController _descriptionRoController;
  TextEditingController _descriptionEnController;
  final RelevanceController _relevanceController = RelevanceController();

  User _user;

  Future<void> _fetchUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _user = await authProvider.currentUser;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchUser();

    _selectedCategory = widget.website?.category ?? WebsiteCategory.learning;
    _labelController = TextEditingController(text: widget.website?.label ?? '');
    _linkController = TextEditingController(text: widget.website?.link ?? '');

    final description = <String, String>{'en': '', 'ro': ''};
    if (widget.website != null) {
      description['en'] = widget.website.infoByLocale.containsKey('en')
          ? widget.website.infoByLocale['en']
          : '';
      description['ro'] = widget.website.infoByLocale.containsKey('ro')
          ? widget.website.infoByLocale['ro']
          : '';
    }
    _descriptionRoController = TextEditingController(text: description['ro']);
    _descriptionEnController = TextEditingController(text: description['en']);
  }

  String _buildId() {
    if (widget.updateExisting) return widget.website.id;
    final label = (_labelController.text ?? '') == ''
        ? Website.labelFromLink(_linkController.text)
        : _labelController.text;
    // Sanitize label to obtain document ID
    return ReCase(label.replaceAll(RegExp('[^A-ZĂÂȘȚa-zăâșț0-9 ]'), ''))
        .snakeCase;
  }

  Website _buildWebsite() {
    return Website(
      id: _buildId(),
      ownerUid: widget.updateExisting ? widget.website.ownerUid : _user?.uid,
      isPrivate: _relevanceController.private ?? true,
      editedBy: (widget.website?.editedBy ?? []) + [_user?.uid],
      label: _labelController.text,
      link: _linkController.text,
      category: _selectedCategory,
      infoByLocale: {
        'ro': _descriptionRoController.text,
        'en': _descriptionEnController.text
      },
      relevance: _relevanceController.customRelevance,
      degree: _relevanceController.degree ?? widget.website?.degree,
    );
  }

  Widget _preview() {
    final website = _buildWebsite();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Card(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.remove_red_eye_outlined,
                    color: Theme.of(context).formIconColor,
                  ),
                  const SizedBox(width: 12),
                  AutoSizeText(
                    '${S.current.labelPreview}:',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            child: WebsiteIcon(
                          website: website,
                          onTap: () {
                            Utils.launchURL(website.link);
                          },
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: AutoSizeText(
                S.current.messageWebsitePreview,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            )
          ],
        ),
      ),
    );
  }

  AppDialog _deletionConfirmationDialog(BuildContext context) => AppDialog(
        icon: const Icon(Icons.delete_outlined),
        title: S.current.actionDeleteWebsite,
        message: S.current.messageDeleteWebsite,
        info: widget.website.isPrivate
            ? null
            : S.current.messageThisCouldAffectOtherStudents,
        actions: [
          AppButton(
            text: S.current.actionDeleteWebsite,
            width: 130,
            onTap: () async {
              Navigator.pop(context); // Pop dialog window

              final websiteProvider =
                  Provider.of<WebsiteProvider>(context, listen: false);
              final res = await websiteProvider.deleteWebsite(widget.website);
              if (res) {
                Navigator.pop(context); // Pop editing page
                AppToast.show(S.current.messageWebsiteDeleted);
              }
            },
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: Text(widget.updateExisting
          ? S.current.actionEditWebsite
          : S.current.actionAddWebsite),
      actions: [
            AppScaffoldAction(
              text: S.current.buttonSave,
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  final websiteProvider =
                      Provider.of<WebsiteProvider>(context, listen: false);

                  bool res = false;
                  if (widget.updateExisting) {
                    res = await websiteProvider.updateWebsite(_buildWebsite());
                  } else {
                    res = await websiteProvider.addWebsite(_buildWebsite());
                  }
                  if (res) {
                    AppToast.show(widget.updateExisting
                        ? S.current.messageWebsiteEdited
                        : S.current.messageWebsiteAdded);
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ] +
          (widget.updateExisting
              ? [
                  AppScaffoldAction(
                    icon: Icons.more_vert_outlined,
                    items: {
                      S.current.actionDeleteWebsite: () => showDialog(
                          context: context,
                          builder: _deletionConfirmationDialog)
                    },
                    onPressed: () => showDialog(
                        context: context, builder: _deletionConfirmationDialog),
                  )
                ]
              : <AppScaffoldAction>[]),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            _preview(),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _labelController,
                      decoration: InputDecoration(
                        labelText: S.current.labelName,
                        hintText: S.current.hintWebsiteLabel,
                        prefixIcon: const Icon(Icons.label_outlined),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    DropdownButtonFormField<WebsiteCategory>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: S.current.labelCategory,
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                      value: _selectedCategory,
                      items: WebsiteCategory.values
                          .map(
                            (category) => DropdownMenuItem<WebsiteCategory>(
                              value: category,
                              child: Text(category.toLocalizedString()),
                            ),
                          )
                          .toList(),
                      onChanged: (selection) =>
                          setState(() => _selectedCategory = selection),
                    ),
                    TextFormField(
                      controller: _linkController,
                      decoration: InputDecoration(
                        labelText: '${S.current.labelLink} *',
                        hintText: S.current.hintWebsiteLink,
                        prefixIcon: const Icon(FeatherIcons.globe),
                      ),
                      validator: (value) {
                        if (!isURL(value, requireProtocol: true)) {
                          return S.current.warningInvalidURL;
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    RelevanceFormField(
                      canBePrivate: true,
                      canBeForEveryone: true,
                      defaultPrivate: widget.website?.isPrivate ?? true,
                      controller: _relevanceController,
                    ),
                    TextFormField(
                      controller: _descriptionRoController,
                      decoration: InputDecoration(
                          labelText:
                              '${S.current.labelDescription} (${S.current.settingsItemLanguageRomanian.toLowerCase()})',
                          hintText: 'Cel mai popular motor de căutare.',
                          prefixIcon: const Icon(Icons.info_outlined)),
                      onChanged: (_) => setState(() {}),
                      minLines: 1,
                      maxLines: 5,
                    ),
                    TextFormField(
                      controller: _descriptionEnController,
                      decoration: InputDecoration(
                          labelText:
                              '${S.current.labelDescription} (${S.current.settingsItemLanguageEnglish.toLowerCase()})',
                          hintText: 'The most popular search engine.',
                          prefixIcon: const Icon(Icons.info_outlined)),
                      onChanged: (_) => setState(() {}),
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebsiteIcon extends StatelessWidget {
  const WebsiteIcon({this.website, this.canEdit, this.size, this.onTap});

  final Website website;
  final bool canEdit;
  final double size;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: StorageProvider.findImageUrl('websites/${website.id}/icon.png'),
      //Firebase Storage path
      builder: (context, snapshot) {
        ImageProvider image;
        image = const AssetImage('assets/icons/globe.png');
        if (snapshot.hasData) {
          image = NetworkImage(snapshot.data);
        }

        return CircleImage(
            label: website.label,
            tooltip: website.infoByLocale[LocaleProvider.localeString],
            image: image,
            enableOverlay: canEdit,
            circleSize: size,
            onTap: onTap);
      },
    );
  }
}
