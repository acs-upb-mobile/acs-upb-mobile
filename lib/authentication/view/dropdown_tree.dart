import 'package:acs_upb_mobile/pages/filter/model/filter.dart';
import 'package:acs_upb_mobile/pages/filter/service/filter_provider.dart';
import 'package:acs_upb_mobile/resources/locale_provider.dart';
import 'package:acs_upb_mobile/widgets/form/form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DropdownTreeController {
  _DropdownTreeState _dropdownTreeState;

  Map<String, String> get path => _dropdownTreeState?.path;
}

class DropdownTree extends StatefulWidget {
  final List<String> initialPath;
  final double leftPadding;
  final DropdownTreeController controller;

  DropdownTree({
    Key key,
    this.initialPath,
    this.leftPadding,
    this.controller,
  }) : super(key: key);

  @override
  _DropdownTreeState createState() => _DropdownTreeState();
}

class _DropdownTreeState extends State<DropdownTree> {
  List<FormItem> formItems;
  FilterProvider filterProvider;
  Filter filter;
  List<FilterNode> nodes;

  Map<String, String> get path {
    Map<String, String> path;
    if (nodes.length > 1) {
      path = Map();
      path.addAll ({
        filter.localizedLevelNames[0][LocaleProvider.localeString]:
            nodes[1].name
      });
      if (nodes.length > 2) {
        path.addAll({
          filter.localizedLevelNames[1][LocaleProvider.localeString]:
              nodes[2].name
        });
        if (nodes.length > 3) {
          path.addAll({
            filter.localizedLevelNames[2][LocaleProvider.localeString]:
                nodes[3].name
          });
          if (nodes.length > 4) {
            path.addAll({
              filter.localizedLevelNames[3][LocaleProvider.localeString]:
                  nodes[4].name
            });
            if (nodes.length > 5) {
              path.addAll({
                filter.localizedLevelNames[3][LocaleProvider.localeString]:
                    nodes[5].name
              });
              if (nodes.length > 6) {
                path.addAll({
                  filter.localizedLevelNames[5][LocaleProvider.localeString]:
                      nodes[6].name
                });
              }
            }
          }
        }
      }
    }
    return path;
  }

  List<Widget> _dropdownTree(BuildContext context) {
    List<Widget> items = [SizedBox(height: 8)];
    for (var i = 0; i < nodes.length; i++) {
      if (nodes[i] != null && nodes[i].children.isNotEmpty) {
        items.add(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  top: 8.0,
                  left: widget.leftPadding != null ? widget.leftPadding : 0.0),
              child: Text(
                filter.localizedLevelNames[i][LocaleProvider.localeString],
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .apply(color: Theme.of(context).hintColor),
              ),
            ),
            DropdownButtonFormField<FilterNode>(
              value: nodes.length > i + 1 ? nodes[i + 1] : null,
              items: nodes[i]
                  .children
                  .map((node) => DropdownMenuItem(
                        value: node,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 8.0,
                              left: widget.leftPadding != null
                                  ? widget.leftPadding
                                  : 0.0),
                          child: Text(node.name),
                        ),
                      ))
                  .toList(),
              onChanged: (selected) => setState(
                () {
                  nodes.removeRange(i + 1, nodes.length);
                  nodes.add(selected);
                },
              ),
            ),
          ],
        ));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    widget.controller?._dropdownTreeState = this;
    return FutureBuilder(
      future: Provider.of<FilterProvider>(context).fetchFilter(context),
      builder: (BuildContext context, AsyncSnapshot snap) {
        if (snap.hasData) {
          filter = snap.data;
          if (nodes == null) {
            nodes = widget.initialPath == null
                ? [filter.root]
                : filter.findNodeByPath(widget.initialPath);
          }
          return Column(
            children: _dropdownTree(context),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
