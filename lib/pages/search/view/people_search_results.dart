import 'package:acs_upb_mobile/pages/people/model/person.dart';
import 'package:acs_upb_mobile/pages/people/service/person_provider.dart';
import 'package:acs_upb_mobile/pages/people/view/person_view.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';

class PeopleSearchResults extends StatelessWidget {
  const PeopleSearchResults({this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    List<Person> peopleSearched;
    return FutureBuilder(
        future:
            Provider.of<PersonProvider>(context, listen: false).search(query),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            peopleSearched = snapshot.data;
            if (peopleSearched.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                    child: Text(
                      S.current.labelPeople,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  PeopleCircleList(
                    people: peopleSearched,
                  )
                ],
              );
            }
          }
          return Container();
        });
  }
}

class PeopleCircleList extends StatelessWidget {
  const PeopleCircleList({this.people});

  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: Theme.of(context).textTheme.headline4.fontSize * 1.1 + 60.0,
      ),
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: people.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
              child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet<dynamic>(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext buildContext) => PersonView(
                              person: people[index],
                            ));
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    child: Column(children: <Widget>[
                      CircleAvatar(
                        backgroundImage: NetworkImage(people[index].photo),
                      ),
                      AutoSizeText(
                        people[index].name,
                        maxLines: 2,
                        minFontSize: 10,
                        maxFontSize: 12,
                        textAlign: TextAlign.center,
                      )
                    ]),
                  )));
        },
      ),
    );
  }
}
