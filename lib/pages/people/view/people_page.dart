import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/people/model/person.dart';
import 'package:acs_upb_mobile/pages/people/service/person_provider.dart';
import 'package:acs_upb_mobile/pages/people/view/person_view.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/search_bar.dart';
import 'package:dynamic_text_highlighting/dynamic_text_highlighting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({Key key}) : super(key: key);

  @override
  _PeoplePageState createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  String filter = '';
  bool searchClosed = true;
  Future<List<Person>> people;
  List<Person> peopleData;

  @override
  void initState() {
    super.initState();
    final personProvider = Provider.of<PersonProvider>(context, listen: false);
    people = personProvider.fetchPeople(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      actions: [
        AppScaffoldAction(
          icon: Icons.search_outlined,
          onPressed: () {
            setState(() => searchClosed = !searchClosed);
          },
        )
      ],
      title: Text(S.of(context).navigationPeople),
      body: FutureBuilder(
          future: people,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              peopleData = snapshot.data;
              return Column(
                children: [
                  SearchWidget(
                    onSearch: (searchText) {
                      setState(() => filter = searchText);
                    },
                    cancelCallback: () {
                      setState(() {
                        searchClosed = true;
                        filter = '';
                      });
                    },
                    searchClosed: searchClosed,
                  ),
                  Expanded(
                    child: PeopleList(people: filteredPeople, filter: filter),
                  )
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  List<Person> get filteredPeople => peopleData
      .where((person) => filter
          .split(' ')
          .where((element) => element != '')
          .fold(
              true,
              (previousValue, filter) =>
                  previousValue &&
                  person.name.toLowerCase().contains(filter.toLowerCase())))
      .toList();
}

class PeopleList extends StatefulWidget {
  const PeopleList({this.people, this.filter});

  final List<Person> people;
  final String filter;

  @override
  _PeopleListState createState() => _PeopleListState();
}

class _PeopleListState extends State<PeopleList> {
  @override
  Widget build(BuildContext context) {
    final List<String> filteredWords = widget.filter
        .toLowerCase()
        .split(' ')
        .where((element) => element != '')
        .toList();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.people.length,
      itemBuilder: (context, index) {
        return ListTile(
          key: ValueKey(widget.people[index].name),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.people[index].photo),
          ),
          title: filteredWords.isNotEmpty
              ? DynamicTextHighlighting(
                  text: widget.people[index].name,
                  style: Theme.of(context).textTheme.subtitle1,
                  highlights: filteredWords,
                  color: Theme.of(context).accentColor,
                  caseSensitive: false,
                )
              : Text(
                  widget.people[index].name,
                ),
          subtitle: Text(widget.people[index].email),
          onTap: () => showPersonInfo(widget.people[index]),
        );
      },
    );
  }

  void showPersonInfo(Person person) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext buildContext) => PersonView(person: person),
    );
  }
}
