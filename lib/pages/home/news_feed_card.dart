import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/navigation/routes.dart';
import 'package:acs_upb_mobile/pages/news_feed/model/news_feed_item.dart';
import 'package:acs_upb_mobile/pages/news_feed/service/news_provider.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/info_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsFeedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InfoCard<List<NewsFeedItem>>(
        title: S.of(context).navigationNewsFeed,
        showMoreButtonKey: const ValueKey('show_more_news_feed'),
        onShowMore: () => Navigator.of(context).pushNamed(Routes.newsFeed),
        future: Provider.of<NewsProvider>(context).fetchNewsFeedItems(limit: 2),
        builder: (newsFeedItems) {
          return Column(
              children: newsFeedItems
                  .map((item) => ListTile(
                        title: Text(item.title),
                        subtitle: Text(item.date),
                        trailing: const Icon(Icons.arrow_forward_ios_outlined),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onTap: () =>
                            Utils.launchURL(item.link, context: context),
                      ))
                  .toList());
        });
  }
}
