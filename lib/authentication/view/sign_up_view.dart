import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/navigation/routes.dart';
import 'package:acs_upb_mobile/pages/filter/view/filter_dropdown.dart';
import 'package:acs_upb_mobile/resources/banner.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/resources/validator.dart';
import 'package:acs_upb_mobile/widgets/button.dart';
import 'package:acs_upb_mobile/widgets/form_card.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

class SignUpView extends StatefulWidget {
  static const String routeName = '/signup';

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  List<FormCardField> formItems;

  bool agreedToPolicy = false;

  final dropdownController = FilterDropdownController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  /// Attempt to guess the user's first and last name from the email, since
  /// university e-mail addresses are standardized.
  ///
  /// Special characters such as ".", "_" are used to separate the names,
  /// numbers are removed and names are capitalized.
  /// *Format example:* firstnameone_firstnametwo.lastname123@stud.acs.pub.ro
  void parseNameFromEmail(TextEditingController email,
      TextEditingController firstName, TextEditingController lastName) {
    final emailWithoutNumbers =
        email.text.replaceAll(RegExp('[^a-zA-Z._]'), '');
    final names = emailWithoutNumbers.split('.');

    if (names.isNotEmpty) {
      if (!names[0].contains('_')) {
        firstName.text = names[0].titleCase;
      } else {
        final firstNames = names[0].split('_');
        firstName.text = firstNames.map((s) => s.titleCase).join(' ');
      }

      if (names.length > 1) {
        lastName.text = names[1].titleCase;
      }
    }
  }

  List<FormCardField> _buildFormItems() {
    // Only build them once to avoid the cursor staying everywhere
    if (formItems != null) {
      return formItems;
    }
    final emailDomain = S.of(context).stringEmailDomain;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return formItems = <FormCardField>[
      FormCardField(
        label: S.of(context).labelEmail,
        hint: S.of(context).hintEmail,
        additionalHint: S.of(context).infoEmail(S.of(context).stringForum),
        controller: emailController,
        suffix: emailDomain,
        autocorrect: false,
        autofillHints: [AutofillHints.newUsername],
        check: (email, {context}) => authProvider.canSignUpWithEmail(
            email: email + emailDomain, context: context),
        onChanged: (_) => parseNameFromEmail(
            emailController, firstNameController, lastNameController),
      ),
      FormCardField(
          label: S.of(context).labelPassword,
          hint: S.of(context).hintPassword,
          additionalHint: S.of(context).infoPassword,
          controller: passwordController,
          obscureText: true,
          autofillHints: [AutofillHints.newPassword],
          check: (password, {context}) async {
            final errorString =
                AppValidator.isStrongPassword(password, context);
            if (context != null && errorString != null) {
              AppToast.show(errorString);
            }
            return errorString == null;
          }),
      FormCardField(
        label: S.of(context).labelConfirmPassword,
        hint: S.of(context).hintPassword,
        obscureText: true,
        check: (password, {context}) async {
          final bool ok = password == passwordController.text;
          if (!ok && context != null) {
            AppToast.show(S.of(context).errorPasswordsDiffer);
          }
          return ok;
        },
      ),
      FormCardField(
          label: S.of(context).labelFirstName,
          hint: S.of(context).hintFirstName,
          controller: firstNameController,
          autofillHints: [AutofillHints.givenName]),
      FormCardField(
          label: S.of(context).labelLastName,
          hint: S.of(context).hintLastName,
          controller: lastNameController,
          autofillHints: [AutofillHints.familyName]),
    ];
  }

  Widget _privacyPolicy() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Checkbox(
            value: agreedToPolicy,
            visualDensity: VisualDensity.compact,
            onChanged: (value) => setState(() => agreedToPolicy = value),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                  style: Theme.of(context).textTheme.subtitle1,
                  children: [
                    TextSpan(text: S.of(context).messageIAgreeToThe),
                    TextSpan(
                        text: S.of(context).labelPrivacyPolicy,
                        style: Theme.of(context)
                            .accentTextTheme
                            .subtitle1
                            .apply(fontWeightDelta: 2),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Utils.launchURL(
                              Utils.privacyPolicyURL,
                              context: context)),
                    const TextSpan(text: '.'),
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  FormCard _buildForm(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return FormCard(
      title: S.of(context).actionSignUp,
      fields: _buildFormItems(),
      trailing: <Widget>[
        FilterDropdown(controller: dropdownController),
        _privacyPolicy()
      ],
      submitOnEnter: false,
      onSubmitted: (fields) async {
        if (!agreedToPolicy) {
          AppToast.show(
              '${S.of(context).warningAgreeTo}${S.of(context).labelPrivacyPolicy}.');
          return;
        }

        fields[S.of(context).labelEmail] += S.of(context).stringEmailDomain;

        if (dropdownController.path != null &&
            dropdownController.path.length > 1) {
          fields['class'] = dropdownController.path;
        }

        final result = await authProvider.signUp(
          info: fields,
          context: context,
        );

        if (result) {
          // Remove all routes below and push home page
          await Navigator.pushNamedAndRemoveUntil(
              context, Routes.home, (route) => false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final signUpForm = _buildForm(context);

    return GestureDetector(
      onTap: () {
        // Remove current focus on tap
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Align(
              alignment: FractionalOffset.topRight,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                    height: MediaQuery.of(context).size.height / 3 - 20,
                    child: Image.asset(
                        'assets/illustrations/undraw_personal_information.png')),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 28, right: 28, bottom: 10),
                child: IntrinsicHeight(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            UniBanner(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(child: signUpForm),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: AppButton(
                              key: const ValueKey('cancel_button'),
                              text: S.of(context).buttonCancel,
                              onTap: () async {
                                return Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: AppButton(
                              key: const ValueKey('sign_up_button'),
                              color: Theme.of(context).accentColor,
                              text: S.of(context).actionSignUp,
                              onTap: () => signUpForm.submit(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
