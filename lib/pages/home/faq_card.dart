import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/navigation/routes.dart';
import 'package:acs_upb_mobile/pages/faq/model/question.dart';
import 'package:acs_upb_mobile/pages/faq/service/question_provider.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/auto_size_markdown.dart';
import 'package:acs_upb_mobile/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';

class FaqCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final captionStyle = Theme.of(context).textTheme.caption;
    final captionSizeFactor =
        captionStyle.fontSize / Theme.of(context).textTheme.bodyText1.fontSize;
    final captionColor = captionStyle.color;
    return InfoCard<List<Question>>(
      title: S.current.sectionFAQ,
      showMoreButtonKey: const ValueKey('show_more_faq'),
      onShowMore: () => Navigator.of(context).pushNamed(Routes.faq),
      future: Provider.of<QuestionProvider>(context).fetchQuestions(limit: 2),
      builder: (questions) => Column(
        children: questions
            .map(
              (q) => ListTile(
                title: Text(q.question),
                subtitle: AutoSizeMarkdownBody(
                  styleSheet: MarkdownStyleSheet.largeFromTheme(
                      Theme.of(context).copyWith(
                          textTheme: Theme.of(context).textTheme.apply(
                              bodyColor: captionColor,
                              displayColor: captionColor,
                              fontSizeFactor: captionSizeFactor))),
                  fitContent: false,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  onTapLink: (text, link, title) => Utils.launchURL(link),
                  /*
                  This is a workaround because the strings in Firebase represent
                  newlines as '\n' and Firebase replaces them with '\\n'. We
                  need to replace them back for them to display properly.
                  (See GitHub issue firebase/firebase-js-sdk#2366)
                  */
                  data: q.answer.replaceAll('\\n', '\n'),
                  extensionSet: md.ExtensionSet(
                      md.ExtensionSet.gitHubFlavored.blockSyntaxes, [
                    md.EmojiSyntax(),
                    ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                  ]),
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            )
            .toList(),
      ),
    );
  }
}
