import 'dart:typed_data';
import 'dart:ui';

import 'package:acs_upb_mobile/authentication/model/user.dart';
import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/filter/view/filter_dropdown.dart';
import 'package:acs_upb_mobile/resources/storage/storage_provider.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/resources/validator.dart';
import 'package:acs_upb_mobile/widgets/button.dart';
import 'package:acs_upb_mobile/widgets/circle_image.dart';
import 'package:acs_upb_mobile/widgets/dialog.dart';
import 'package:acs_upb_mobile/widgets/icon_text.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as im;
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final dropdownController = FilterDropdownController();

  final formKey = GlobalKey<FormState>();

  Uint8List uploadedImage;
  ImageProvider imageWidget;

  // Whether the user verified their email; this can be true, false or null if
  // the async check hasn't completed yet.
  bool isVerified;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.isVerified.then((value) => setState(() => isVerified = value));
    authProvider.getProfilePictureURL().then((value) =>
        setState(() => {if (value != null) imageWidget = NetworkImage(value)}));
  }

  AppDialog _changePasswordDialog(BuildContext context) {
    final newPasswordController = TextEditingController();
    final oldPasswordController = TextEditingController();
    final changePasswordKey = GlobalKey<FormState>();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return AppDialog(
      title: S.current.actionChangePassword,
      content: [
        Form(
          key: changePasswordKey,
          child: Column(
            children: [
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: S.current.labelOldPassword,
                  hintText: S.current.hintPassword,
                  errorMaxLines: 2,
                ),
                controller: oldPasswordController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return S.current.errorNoPassword;
                  }
                  return null;
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: S.current.labelNewPassword,
                  hintText: S.current.hintPassword,
                  errorMaxLines: 2,
                ),
                controller: newPasswordController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return S.current.errorNoPassword;
                  }
                  if (value == oldPasswordController.text) {
                    return S.current.warningSamePassword;
                  }
                  final result = AppValidator.isStrongPassword(value);
                  if (result != null) {
                    return result;
                  }
                  return null;
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: S.current.labelConfirmNewPassword,
                  hintText: S.current.hintPassword,
                  errorMaxLines: 2,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return S.current.errorNoPassword;
                  }
                  if (value == newPasswordController.text) {
                    return S.current.errorPasswordsDiffer;
                  }
                  return null;
                },
              ),
            ],
          ),
        )
      ],
      actions: [
        AppButton(
          key: const ValueKey('change_password_button'),
          text: S.current.actionChangePassword.toUpperCase(),
          color: Theme.of(context).accentColor,
          width: 130,
          onTap: () async {
            if (changePasswordKey.currentState.validate()) {
              if (await authProvider
                  .verifyPassword(oldPasswordController.text)) {
                if (await authProvider
                    .changePassword(newPasswordController.text)) {
                  AppToast.show(S.current.messageChangePasswordSuccess);
                  Navigator.pop(context);
                }
              }
            }
          },
        )
      ],
    );
  }

  AppDialog _deletionConfirmationDialog(BuildContext context) {
    final passwordController = TextEditingController();
    return AppDialog(
      icon: const Icon(Icons.warning_amber_outlined, color: Colors.red),
      title: S.current.actionDeleteAccount,
      message:
          '${S.current.messageDeleteAccount} ${S.current.messageCannotBeUndone}',
      content: [
        TextFormField(
          decoration: InputDecoration(
            labelText: S.current.labelConfirmPassword,
            hintText: S.current.hintPassword,
          ),
          obscureText: true,
          controller: passwordController,
        )
      ],
      actions: [
        AppButton(
          key: const ValueKey('delete_account_button'),
          text: S.current.actionDeleteAccount.toUpperCase(),
          color: Colors.red,
          width: 130,
          onTap: () async {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            if (await authProvider.verifyPassword(passwordController.text)) {
              if (await authProvider.delete()) {
                await Utils.signOut(context);
              }
            }
          },
        )
      ],
    );
  }

  AppDialog _changeEmailConfirmationDialog(BuildContext context) {
    final passwordController = TextEditingController();
    return AppDialog(
      title: S.current.actionChangeEmail,
      message: S.current.messageChangeEmail(
          emailController.text + S.current.stringEmailDomain),
      content: [
        TextFormField(
          decoration: InputDecoration(
            labelText: S.current.labelConfirmPassword,
            hintText: S.current.hintPassword,
          ),
          obscureText: true,
          controller: passwordController,
        ),
      ],
      actions: [
        AppButton(
          key: const ValueKey('change_email_button'),
          text: S.current.actionChangeEmail,
          color: Theme.of(context).accentColor,
          width: 130,
          onTap: () async {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            if (await authProvider.verifyPassword(passwordController.text)) {
              if (await authProvider.changeEmail(
                  emailController.text + S.current.stringEmailDomain)) {
                AppToast.show(S.current.messageChangeEmailSuccess);
                Navigator.pop(context, true);
              } else {
                Navigator.pop(context, false);
              }
            }
          },
        )
      ],
    );
  }

  Widget buildEditableAvatar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        child: CircleImage(
            circleSize: 150,
            image: imageWidget ??
                const AssetImage('assets/illustrations/undraw_profile_pic.png'),
            enableOverlay: true,
            overlayIcon: const Icon(Icons.edit_outlined)),
        onTap: () async {
          final Uint8List uploadedImage =
              await StorageProvider.showImagePicker();
          if (uploadedImage != null) {
            setState(() {
              this.uploadedImage = uploadedImage;
              imageWidget = MemoryImage(uploadedImage);
            });
          }
        },
      ),
    );
  }

  Future<Uint8List> convertToPNG(Uint8List image) async {
    final decodedImage = im.decodeImage(image);
    return im.encodePng(im.copyResize(decodedImage, width: 500, height: 500),
        level: 9);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final emailDomain = S.current.stringEmailDomain;
    final User user = authProvider.currentUserFromCache;

    if (user == null) {
      // TODO(AdrianMargineanu): Show error page if user is not authenticated
      return Container();
    }

    lastNameController.text = user.lastName;
    firstNameController.text = user.firstName;
    Uint8List imageAsPNG;
    if (isVerified == false) {
      emailController.text = authProvider.email.split('@')[0];
    }
    final path = user.classes;

    return AppScaffold(
      title: Text(S.current.actionEditProfile),
      needsToBeAuthenticated: true,
      actions: [
        AppScaffoldAction(
            text: S.current.buttonSave,
            onPressed: () async {
              final Map<String, dynamic> info = {
                S.current.labelFirstName: firstNameController.text,
                S.current.labelLastName: lastNameController.text,
              };
              if (dropdownController.path != null) {
                info['class'] = dropdownController.path;
              }

              if (formKey.currentState.validate()) {
                bool result = true;
                if (isVerified == false &&
                    emailController.text + emailDomain != authProvider.email) {
                  await showDialog(
                          context: context,
                          builder: _changeEmailConfirmationDialog)
                      .then((value) => result = value ?? false);
                }
                if (uploadedImage != null) {
                  imageAsPNG = await convertToPNG(uploadedImage);
                  result = await authProvider.uploadProfilePicture(imageAsPNG);
                  if (result) {
                    AppToast.show(S.current.messagePictureUpdatedSuccess);
                  }
                }
                if (result) {
                  if (await authProvider.updateProfile(info)) {
                    AppToast.show(S.current.messageEditProfileSuccess);
                    Navigator.pop(context);
                  }
                }
              }
            }),
        AppScaffoldAction(
          icon: Icons.more_vert_outlined,
          items: {
            S.current.actionChangePassword: () =>
                showDialog(context: context, builder: _changePasswordDialog),
            S.current.actionDeleteAccount: () => showDialog(
                context: context, builder: _deletionConfirmationDialog)
          },
        )
      ],
      body: Container(
        child: ListView(padding: const EdgeInsets.all(12), children: [
          AccountNotVerifiedWarning(),
          buildEditableAvatar(context),
          PrefTitle(
            title: Text(S.current.labelPersonalInformation),
            padding: const EdgeInsets.only(left: 0, bottom: 0, top: 20),
          ),
          const SizedBox(height: 10),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outlined),
                    labelText: S.current.labelFirstName,
                    hintText: S.current.hintFirstName,
                  ),
                  controller: firstNameController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return S.current.errorMissingFirstName;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outlined),
                    labelText: S.current.labelLastName,
                    hintText: S.current.hintLastName,
                  ),
                  controller: lastNameController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return S.current.errorMissingLastName;
                    }
                    return null;
                  },
                ),
                if (isVerified == false)
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.alternate_email_outlined),
                      labelText: S.current.labelEmail,
                      hintText: S.current.hintEmail,
                      suffix: Text(emailDomain),
                    ),
                    controller: emailController,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return S.current.errorMissingLastName;
                      }
                      return null;
                    },
                  )
              ],
            ),
          ),
          const SizedBox(height: 10),
          PrefTitle(
            title: Text(S.current.labelClass),
            padding: const EdgeInsets.only(left: 0, bottom: 0, top: 20),
          ),
          FilterDropdown(
            initialPath: path,
            controller: dropdownController,
            leftPadding: 10,
            textStyle: Theme.of(context)
                .textTheme
                .caption
                .apply(color: Theme.of(context).hintColor),
          ),
        ]),
      ),
    );
  }
}

class AccountNotVerifiedWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated || authProvider.isAnonymous) {
      return Container();
    }

    return FutureBuilder(
      future: authProvider.isVerified,
      builder: (context, snap) {
        if (!snap.hasData || snap.data) {
          return Container();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconText(
                align: TextAlign.center,
                icon: Icons.error_outlined,
                text: S.current.messageEmailNotVerified,
                actionText: S.current.actionSendVerificationAgain,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: Theme.of(context).hintColor),
                onTap: authProvider.sendEmailVerification,
              ),
            ],
          ),
        );
      },
    );
  }
}
