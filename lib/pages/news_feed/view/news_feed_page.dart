import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/news_feed/model/news_feed_item.dart';
import 'package:acs_upb_mobile/pages/news_feed/service/news_provider.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/error_page.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsFeedPage extends StatefulWidget {
  static const String routeName = '/news_feed';

  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  @override
  Widget build(BuildContext context) {
    final newsFeedProvider = Provider.of<NewsProvider>(context);

    return AppScaffold(
      title: Text(S.of(context).navigationNewsFeed),
      body: FutureBuilder(
        future: newsFeedProvider.fetchNewsFeedItems(context: context),
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<NewsFeedItem> newsFeedItems = snapshot.data;
          if (newsFeedItems == null) {
            return ErrorPage(
              errorMessage: S.of(context).warningUnableToReachNewsFeed,
              info: [TextSpan(text: S.of(context).warningInternetConnection)],
              actionText: S.of(context).actionRefresh,
              actionOnTap: () => setState(() {}),
            );
          } else if (newsFeedItems.isEmpty) {
            return ErrorPage(
              imgPath: 'assets/illustrations/undraw_empty.png',
              errorMessage: S.of(context).warningNoNews,
            );
          }

          return ListView(
              children: ListTile.divideTiles(
            context: context,
            tiles: newsFeedItems
                .map((item) => ListTile(
                      title: Text(item.title),
                      subtitle: Text(item.date),
                      trailing: const Icon(Icons.arrow_forward_ios_outlined),
                      onTap: () => Utils.launchURL(item.link, context: context),
                      dense: true,
                    ))
                .toList(),
          ).toList());
        },
      ),
    );
  }
}
