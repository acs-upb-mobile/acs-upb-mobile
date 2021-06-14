import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/faq/model/question.dart';
import 'package:acs_upb_mobile/pages/faq/service/question_provider.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/search_bar.dart';
import 'package:acs_upb_mobile/widgets/selectable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';

class FaqPage extends StatefulWidget {
  static const String routeName = '/faq';

  @override
  _FaqPageState createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  List<Question> questions = <Question>[];
  List<String> categories;
  String filter = '';
  bool searchClosed = true;
  List<String> activeTags = <String>[];
  Future<List<Question>> futureQuestions;

  @override
  void initState() {
    final QuestionProvider questionProvider =
        Provider.of<QuestionProvider>(context, listen: false);
    futureQuestions = questionProvider.fetchQuestions();
    super.initState();
  }

  Widget categoryList() => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[const SizedBox(width: 10)] +
              categories
                  .map((category) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Selectable(
                          label: category,
                          initiallySelected: false,
                          onSelected: (selection) {
                            setState(() {
                              if (selection) {
                                activeTags.add(category);
                              } else {
                                activeTags.remove(category);
                              }
                            });
                          },
                        ),
                      ))
                  .toList() +
              <Widget>[const SizedBox(width: 10)],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: Text(S.current.sectionFAQ),
      actions: [
        AppScaffoldAction(
          icon: Icons.search_outlined,
          onPressed: () {
            setState(() {
              searchClosed = !searchClosed;
            });
          },
        )
      ],
      body: FutureBuilder(
          future: futureQuestions,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            questions = snapshot.data;
            categories = questions.expand((e) => e.tags).toSet().toList();
            return ListView(
              children: [
                SearchWidget(
                  header: categoryList(),
                  onSearch: (searchText) {
                    setState(() {
                      filter = searchText;
                    });
                  },
                  cancelCallback: () {
                    setState(() {
                      searchClosed = true;
                      filter = '';
                    });
                  },
                  searchClosed: searchClosed,
                ),
                QuestionsList(questions: filteredQuestions, filter: filter),
              ],
            );
          }),
    );
  }

  List<Question> get filteredQuestions => questions
      .where((question) =>
          filter.split(' ').where((element) => element != '').fold(
              true,
              (previousValue, filter) =>
                  previousValue &&
                  question.question.toLowerCase().contains(filter)) &&
          containsTag(activeTags, question.tags))
      .toList();

  bool containsTag(List<String> activeTags, List<String> questionTags) {
    if (activeTags.isEmpty) return true;
    return questionTags.any(activeTags.contains);
  }
}

class QuestionsList extends StatefulWidget {
  const QuestionsList({this.questions, this.filter});

  final List<Question> questions;
  final String filter;

  @override
  _QuestionsListState createState() => _QuestionsListState();
}

class _QuestionsListState extends State<QuestionsList> {
  @override
  Widget build(BuildContext context) {
    final List<String> filteredWords =
        widget.filter.split(' ').where((element) => element != '').toList();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            key: ValueKey(widget.questions[index].question),
            title: filteredWords.isNotEmpty
                ? Text(
                    widget.questions[index].question,
                    style: Theme.of(context).textTheme.subtitle1,
                  )
                : Text(
                    widget.questions[index].question,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: MarkdownBody(
                  fitContent: false,
                  onTapLink: (text, link, title) => Utils.launchURL(link),
                  /*
                  This is a workaround because the strings in Firebase represent
                  newlines as '\n' and Firebase replaces them with '\\n'. We need
                  to replace them back for them to display properly.
                  (See GitHub issue firebase/firebase-js-sdk#2366)
                  */
                  data: widget.questions[index].answer.replaceAll('\\n', '\n'),
                  extensionSet: md.ExtensionSet(
                      md.ExtensionSet.gitHubFlavored.blockSyntaxes, [
                    md.EmojiSyntax(),
                    ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
