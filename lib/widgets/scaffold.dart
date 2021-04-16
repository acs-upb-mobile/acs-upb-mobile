import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/error_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppScaffoldAction {
  AppScaffoldAction(
      {this.icon,
      this.route,
      this.onPressed,
      this.tooltip,
      this.text,
      this.items});

  // Icon for the action button
  final IconData icon;

  // Route to push when the action button is pressed
  final String route;

  // Action that happens when the button is pressed. This overrides [route].
  final void Function() onPressed;

  // Action button tooltip text
  final String tooltip;

  // Action text. This overrides [icon].
  final String text;

  // Option-action map that should be specified if a popup menu is needed. It
  // overrides [route].
  final Map<String, void Function()> items;
}

class AppScaffold extends StatelessWidget {
  AppScaffold({
    this.body,
    this.title,
    List<AppScaffoldAction> actions,
    this.floatingActionButton,
    this.leading,
    this.needsToBeAuthenticated = false,
  }) : actions = actions ?? [];

  final Widget body;
  final Widget title;
  final Widget floatingActionButton;
  final List<AppScaffoldAction> actions;
  final AppScaffoldAction leading;
  final bool needsToBeAuthenticated;

  Widget _widgetFromAction(AppScaffoldAction action,
      {@required bool enableContent, @required BuildContext context}) {
    if (action == null) {
      return null;
    }

    final void Function() onPressed =
        !enableContent || (action?.onPressed == null && action?.route == null)
            ? null
            : action?.onPressed ??
                () => Navigator.pushNamed(context, action?.route);

    return action?.items != null
        ? PopupMenuButton<String>(
            icon: Icon(action.icon),
            tooltip: action.tooltip ?? action.text,
            onSelected: (selected) => action.items[selected](),
            itemBuilder: (BuildContext context) {
              return action.items.keys
                  .map((option) => PopupMenuItem(
                        value: option,
                        child: Text(option),
                      ))
                  .toList();
            },
          )
        : Tooltip(
            message: action?.tooltip ?? action?.text ?? '',
            child: action?.text != null
                ? ButtonTheme(
                    minWidth: 10,
                    child: TextButton(
                      child: Text(
                        action.text,
                        style: const TextStyle().apply(
                            color: Theme.of(context).primaryIconTheme.color),
                      ),
                      onPressed: onPressed,
                    ),
                  )
                : IconButton(
                    icon: Icon(action?.icon),
                    onPressed: onPressed,
                  ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isAuthenticated =
        authProvider.isAuthenticated && !authProvider.isAnonymous;
    final bool enableContent = !needsToBeAuthenticated || isAuthenticated;

    return GestureDetector(
      onTap: () {
        // Remove current focus on tap
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: enableContent
            ? body ??
                ErrorPage(
                  imgPath: 'assets/illustrations/undraw_under_construction.png',
                  errorMessage: S.of(context).messageUnderConstruction,
                )
            : ErrorPage(
                imgPath: 'assets/illustrations/undraw_sign_in.png',
                info: [
                  TextSpan(text: S.of(context).warningAuthenticationNeeded)
                ],
                actionText: S.of(context).actionLogIn,
                actionOnTap: () => Utils.signOut(context),
              ),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: AppBar(
            title: title,
            centerTitle: true,
            toolbarOpacity: 0.8,
            leading: _widgetFromAction(leading,
                enableContent: enableContent, context: context),
            actions: actions
                .map((action) => _widgetFromAction(action,
                    enableContent: enableContent, context: context))
                .toList(),
          ),
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
