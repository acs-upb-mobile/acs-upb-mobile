import 'package:acs_upb_mobile/pages/chatbot/view/chat_page.dart';
import 'package:acs_upb_mobile/pages/search/view/classes_search_results.dart';
import 'package:acs_upb_mobile/pages/search/view/people_search_results.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  bool searchClosed = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: Text(S.current.navigationSearch),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          SearchWidget(
            onSearch: (searchText) => {setState(() => query = searchText)},
            cancelCallback: () => {setState(() => query = '')},
            searchClosed: false,
          ),
          PeopleSearchResults(query: query),
          ClassesSearchResults(query: query),
          if (query.isNotEmpty) ChatBotIntro()
        ],
      ),
    );
  }
}

class ChatBotIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Image(
            image: AssetImage('assets/illustrations/undraw_chat_image.png'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(S.current.messageAnotherQuestion)),
              GestureDetector(
                child: Text(
                  S.current.messageTalkToChatbot,
                  style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                onTap: () =>
                    Navigator.of(context).push(MaterialPageRoute<ChatPage>(
                  builder: (_) => ChatPage(),
                )),
              )
            ],
          ),
        )
      ],
    ));
  }
}
