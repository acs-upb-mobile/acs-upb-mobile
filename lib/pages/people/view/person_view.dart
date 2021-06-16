import 'package:acs_upb_mobile/pages/people/model/person.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/icon_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class PersonView extends StatelessWidget {
  const PersonView({Key key, this.person}) : super(key: key);

  final Person person;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              shape: BoxShape.rectangle,
              border:
                  Border.all(color: Theme.of(context).accentColor, width: 10),
            ),
            child: Center(
              child: Text(person.name,
                  style: Theme.of(context).textTheme.headline6),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: person.photo != null
                          ? CircleAvatar(
                              maxRadius: 50,
                              backgroundImage:
                                  //CachedNetworkImageProvider(person.photo),
                                  CachedNetworkImageProvider(person.photo))
                          : const CircleAvatar(
                              radius: 50,
                              child: Icon(
                                Icons.person_outlined,
                                size: 50,
                              ),
                            ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconText(
                              icon: FeatherIcons.mail,
                              text: person.email ?? '-',
                              style: Theme.of(context).textTheme.bodyText1,
                              onTap: () =>
                                  Utils.launchURL('mailto:${person.email}'),
                            ),
                            const SizedBox(height: 16),
                            IconText(
                              icon: FeatherIcons.phone,
                              text: person.phone ?? '-',
                              style: Theme.of(context).textTheme.bodyText1,
                              onTap: () =>
                                  Utils.launchURL('tel:${person.phone}'),
                            ),
                            const SizedBox(height: 16),
                            IconText(
                                icon: FeatherIcons.mapPin,
                                text: person.office ?? '-',
                                style: Theme.of(context).textTheme.bodyText1),
                            const SizedBox(height: 16),
                            IconText(
                                icon: Icons.work_outline,
                                text: person.position ?? '-',
                                style: Theme.of(context).textTheme.bodyText1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
