import 'dart:core';
import 'dart:math';

import 'package:acs_upb_mobile/authentication/model/user.dart';
import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/filter/model/filter.dart';
import 'package:acs_upb_mobile/pages/filter/service/filter_provider.dart';
import 'package:acs_upb_mobile/pages/filter/view/filter_page.dart';
import 'package:acs_upb_mobile/pages/portal/model/website.dart';
import 'package:acs_upb_mobile/pages/portal/service/website_provider.dart';
import 'package:acs_upb_mobile/pages/portal/view/website_view.dart';
import 'package:acs_upb_mobile/resources/custom_icons.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/circle_image.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/spoiler.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

class PortalPage extends StatefulWidget {
  const PortalPage({Key key}) : super(key: key);

  @override
  _PortalPageState createState() => _PortalPageState();
}

class _PortalPageState extends State<PortalPage> {
  Filter filterCache;
  List<Website> websites = [];
  FilterProvider filterProvider;

  // Only show user-added websites
  bool userOnly = false;

  bool editingEnabled = false;

  User user;

  bool updating;

  Future<void> _fetchUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    user = await authProvider.currentUser;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _updateFilter();
  }

  Future<void> _updateFilter() async {
    // If updating is null, filter hasn't been initialized yet so it's not
    // technically "updating"
    if (updating != null) {
      updating = true;
    }

    final filterProvider = this.filterProvider ??
        Provider.of<FilterProvider>(context, listen: false);
    filterCache = await filterProvider.fetchFilter(context: context);

    updating = false;
    if (mounted) {
      setState(() {});
    }
  }

  Widget websiteCircle(Website website, double size) {
    final bool canEdit = editingEnabled &&
        (website.isPrivate || (user.canEditPublicInfo ?? false));
    return Padding(
        padding: const EdgeInsets.all(10),
        child: WebsiteIcon(
          website: website,
          canEdit: canEdit,
          size: size,
          onTap: () {
            if (canEdit) {
              Navigator.of(context)
                  .push(MaterialPageRoute<ChangeNotifierProvider>(
                builder: (_) => ChangeNotifierProvider<FilterProvider>(
                  create: (_) =>
                      Platform.environment.containsKey('FLUTTER_TEST')
                          ? Provider.of<FilterProvider>(context)
                          : FilterProvider(
                              defaultDegree: website.degree,
                              defaultRelevance: website.relevance,
                            ),
                  child: WebsiteView(
                    website: website,
                    updateExisting: true,
                  ),
                ),
              ));
            } else {
              Provider.of<WebsiteProvider>(context, listen: false)
                  .incrementNumberOfVisits(website, uid: user?.uid);
              Utils.launchURL(website.link);
            }
          },
        ));
  }

  Widget listCategory(WebsiteCategory category, List<Website> websites) {
    final bool hasContent = websites != null && websites.isNotEmpty;

    const double padding = 10;
    // The width available for displaying the circles (screen width minus the
    // left/right padding)
    final double availableWidth =
        MediaQuery.of(context).size.width - 2 * padding;
    // The maximum size of a circle, regardless of screen size
    const double maxCircleSize = 80;
    // The amount of circles that can fit on one row (given the screen size,
    // maximum circle size and the fact that there need to be at least 4 circles
    // on a row), including the padding.
    final int circlesPerRow =
        max(4, (availableWidth / (maxCircleSize + 2 * padding)).floor());
    // The exact size of a circle (without the padding), so that they fit
    // perfectly in a row
    final double circleSize = availableWidth / circlesPerRow - 2 * padding;

    Widget content;
    if (!hasContent) {
      // Display just the plus button (but set the height to mimic the rows with
      // content)
      content = Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: circleSize + 16.0,
          height: circleSize +
              16.0 + // padding
              40.0, // text
          child: _AddWebsiteButton(
              key: ValueKey(
                  'add_website_${ReCase(category.toLocalizedString(context)).snakeCase}'),
              category: category),
        ),
      );
    } else {
      final rows = <Row>[];

      for (var i = 0; i < websites.length;) {
        List<Widget> children = [];
        for (var j = 0; j < circlesPerRow && i < websites.length; j++, i++) {
          children.add(websiteCircle(websites[i], circleSize));
        }

        // Add trailing "plus" button
        if (i == websites.length) {
          if (children.length == circlesPerRow) {
            rows.add(Row(children: children));
            children = [];
          }
          children.add(Container(
            width: circleSize + 16,
            child: _AddWebsiteButton(
              key: ValueKey(
                  'add_website_${ReCase(category.toLocalizedString(context)).snakeCase}'),
              category: category,
              size: circleSize * 0.6,
            ),
          ));
        }

        rows.add(Row(children: children));
      }

      content = Column(children: rows);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: AppSpoiler(
        title: category.toLocalizedString(context),
        initiallyExpanded: hasContent,
        content: content,
      ),
    );
  }

  List<Widget> listWebsitesByCategory(List<Website> websites) {
    assert(websites != null);

    final map = <WebsiteCategory, List<Website>>{};
    for (final website in websites) {
      final category = website.category;
      map.putIfAbsent(category, () => <Website>[]);
      map[category].add(website);
    }

    return [
      WebsiteCategory.learning,
      WebsiteCategory.administrative,
      WebsiteCategory.association,
      WebsiteCategory.resource,
      WebsiteCategory.other
    ].map((category) => listCategory(category, map[category])).toList();
  }

  @override
  Widget build(BuildContext context) {
    final websiteProvider = Provider.of<WebsiteProvider>(context);
    filterProvider = Provider.of<FilterProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    const CircularProgressIndicator progressIndicator =
        CircularProgressIndicator();

    return AppScaffold(
      title: Text(S.of(context).navigationPortal),
      actions: [
        AppScaffoldAction(
          icon: editingEnabled ? CustomIcons.edit_slash : Icons.edit_outlined,
          tooltip: editingEnabled
              ? S.of(context).actionDisableEditing
              : S.of(context).actionEnableEditing,
          onPressed: () {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            if (authProvider.isAuthenticated && !authProvider.isAnonymous) {
              // Show message if there is nothing the user can edit
              if (!editingEnabled) {
                user.hasEditableWebsites.then((canEdit) {
                  if (!canEdit) {
                    AppToast.show(
                        '${S.of(context).warningNothingToEdit} ${S.of(context).messageAddCustomWebsite}');
                  }
                });
              }

              setState(() => editingEnabled = !editingEnabled);
            } else {
              AppToast.show(S.of(context).warningAuthenticationNeeded);
            }
          },
        ),
        AppScaffoldAction(
          icon: FeatherIcons.filter,
          tooltip: S.of(context).navigationFilter,
          items: {
            S.of(context).filterMenuRelevance: () {
              userOnly = false;
              Navigator.push(
                context,
                MaterialPageRoute<FilterPage>(
                  builder: (_) => FilterPage(
                    onSubmit: _updateFilter,
                  ),
                ),
              );
            },
            S.of(context).filterMenuShowMine: () {
              if (authProvider.isAuthenticated && !authProvider.isAnonymous) {
                // Show message if user has no private websites
                if (!userOnly) {
                  user.hasPrivateWebsites.then((hasPrivate) {
                    if (!hasPrivate) {
                      AppToast.show(S.of(context).warningNoPrivateWebsite);
                    }
                  });

                  _updateFilter();
                  setState(() => userOnly = true);
                  filterProvider.enableFilter();
                } else {
                  AppToast.show(S.of(context).warningFilterAlreadyShowingYours);
                }
              } else {
                AppToast.show(S.of(context).warningAuthenticationNeeded);
              }
            },
            S.of(context).filterMenuShowAll: () {
              if (!filterProvider.filterEnabled) {
                AppToast.show(S.of(context).warningFilterAlreadyDisabled);
              } else {
                _updateFilter();
                userOnly = false;
                filterProvider.disableFilter();
              }
            },
          },
        ),
      ],
      body: Stack(
        children: [
          FutureBuilder<List<Website>>(
              future: websiteProvider.fetchWebsites(
                filterProvider.filterEnabled ? filterCache : null,
                userOnly: userOnly,
                uid: authProvider.uid,
                context: context,
                sources: user?.sources ?? []

              ),
              builder: (context, AsyncSnapshot<List<Website>> websiteSnap) {
                if (websiteSnap.hasData) {
                  websites = websiteSnap.data;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: listWebsitesByCategory(websites),
                      ),
                    ),
                  );
                } else if (websiteSnap.hasError) {
                  print(websiteSnap.error);
                  // TODO(IoanaAlexandru): Show error toast
                  return Container();
                } else {
                  return const Center(child: progressIndicator);
                }
              }),
          if (updating == true)
            Container(
                color: Theme.of(context).disabledColor,
                child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}

class _AddWebsiteButton extends StatelessWidget {
  const _AddWebsiteButton(
      {Key key, this.category = WebsiteCategory.learning, this.size = 50})
      : super(key: key);

  final WebsiteCategory category;
  final double size;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: S.of(context).actionAddWebsite,
        child: GestureDetector(
          onTap: () {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            if (authProvider.isAuthenticated && !authProvider.isAnonymous) {
              Navigator.of(context)
                  .push(MaterialPageRoute<ChangeNotifierProvider>(
                builder: (_) =>
                    ChangeNotifierProxyProvider<AuthProvider, FilterProvider>(
                  create: (_) =>
                      Platform.environment.containsKey('FLUTTER_TEST')
                          ? Provider.of<FilterProvider>(context)
                          : FilterProvider(),
                  update: (context, authProvider, filterProvider) {
                    return filterProvider..updateAuth(authProvider);
                  },
                  child: WebsiteView(
                    website: Website(
                        relevance: null,
                        id: null,
                        isPrivate: true,
                        link: '',
                        category: category),
                  ),
                ),
              ));
            } else {
              AppToast.show(S.of(context).warningAuthenticationNeeded);
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: CircleImage(
              icon: Icon(
                Icons.add_outlined,
                color: Theme.of(context).unselectedWidgetColor,
              ),
              label: '',
              circleSize: size,
            ),
          ),
        ),
      );
}
