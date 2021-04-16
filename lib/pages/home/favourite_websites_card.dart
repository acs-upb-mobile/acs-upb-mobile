import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/portal/model/website.dart';
import 'package:acs_upb_mobile/pages/portal/service/website_provider.dart';
import 'package:acs_upb_mobile/pages/portal/view/website_view.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavouriteWebsitesCard extends StatelessWidget {
  const FavouriteWebsitesCard({Key key, this.onShowMore}) : super(key: key);

  final void Function() onShowMore;

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context);
    final String uid = authProvider.uid;
    final WebsiteProvider websiteProvider =
        Provider.of<WebsiteProvider>(context);
    return InfoCard<List<Website>>(
      title: S.of(context).sectionFrequentlyAccessedWebsites,
      onShowMore: onShowMore,
      future:
          websiteProvider.fetchFavouriteWebsites(uid: uid, context: context),
      builder: (websites) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: websites
              .map((website) => Expanded(
                    child: WebsiteIcon(
                      website: website,
                      onTap: () {
                        websiteProvider.incrementNumberOfVisits(website,
                            uid: uid);
                        Utils.launchURL(website.link, context: context);
                      },
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
