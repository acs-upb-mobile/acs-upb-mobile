import 'package:acs_upb_mobile/pages/classes/model/class.dart';
import 'package:acs_upb_mobile/pages/classes/view/class_view.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchedClassesView extends StatelessWidget {
  const SearchedClassesView({this.classHeaders, this.query});

  final List<ClassHeader> classHeaders;
  final String query;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: Text(S.current.navigationSearchResults),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: classHeaders.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                  child: GestureDetector(
                      child: Row(children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Container(
                                width: 30,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: AutoSizeText(
                                    classHeaders[index].acronym,
                                    minFontSize: 0,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            )),
                        Expanded(
                          child: Text(classHeaders[index].name),
                        )
                      ]),
                      onTap: () => {
                            Navigator.of(context)
                                .push(MaterialPageRoute<ClassView>(
                              builder: (_) =>
                                  ClassView(classHeader: classHeaders[index]),
                            ))
                          }));
            }),
      ),
    );
  }
}
