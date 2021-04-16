import 'package:acs_upb_mobile/pages/filter/model/filter.dart';
import 'package:acs_upb_mobile/pages/filter/service/filter_provider.dart';
import 'package:acs_upb_mobile/resources/locale_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterDropdownController {
  _FilterDropdownState _dropdownTreeState;

  List<String> get path =>
      _dropdownTreeState.nodes.map((e) => e.name).skip(1).toList();
}

class FilterDropdown extends StatefulWidget {
  const FilterDropdown({
    Key key,
    this.initialPath,
    this.leftPadding,
    this.controller,
    this.textStyle,
  }) : super(key: key);

  final List<String> initialPath;
  final double leftPadding;
  final FilterDropdownController controller;
  final TextStyle textStyle;

  @override
  _FilterDropdownState createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  FilterProvider filterProvider;
  Filter filter;
  List<FilterNode> nodes;

  List<Widget> _buildDropdowns(BuildContext context) {
    final items = <Widget>[const SizedBox(height: 10)];
    for (var i = 0; i < nodes.length; i++) {
      if (nodes[i] != null && nodes[i].children.isNotEmpty) {
        items.add(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10, left: widget.leftPadding ?? 0),
              child: Text(
                filter.localizedLevelNames[i][LocaleProvider.localeString],
                style: widget.textStyle ??
                    Theme.of(context)
                        .textTheme
                        .subtitle1
                        .apply(fontSizeFactor: 1.1),
              ),
            ),
            DropdownButtonFormField<FilterNode>(
              value: nodes.length > i + 1 ? nodes[i + 1] : null,
              items: nodes[i]
                  .children
                  .map((node) => DropdownMenuItem(
                        value: node,
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: widget.leftPadding ?? 0),
                          child: Text(node.localizedName(context)),
                        ),
                      ))
                  .toList(),
              onChanged: (selected) => setState(
                () {
                  nodes
                    ..removeRange(i + 1, nodes.length)
                    ..add(selected);
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
      future:
          Provider.of<FilterProvider>(context).fetchFilter(context: context),
      builder: (context, snap) {
        if (snap.hasData) {
          filter = snap.data;
          nodes ??= widget.initialPath == null
              ? [filter.root]
              : filter.findNodesByPath(widget.initialPath);
          return Column(
            children: _buildDropdowns(context),
          );
        }
        return const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
