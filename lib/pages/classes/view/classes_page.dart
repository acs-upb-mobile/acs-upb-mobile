import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/classes/model/class.dart';
import 'package:acs_upb_mobile/pages/classes/service/class_provider.dart';
import 'package:acs_upb_mobile/pages/classes/view/class_view.dart';
import 'package:acs_upb_mobile/widgets/class_icon.dart';
import 'package:acs_upb_mobile/widgets/error_page.dart';
import 'package:acs_upb_mobile/widgets/icon_text.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/spoiler.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

class ClassesPage extends StatefulWidget {
  const ClassesPage({Key key}) : super(key: key);

  @override
  _ClassesPageState createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  Set<ClassHeader> headers;
  bool updating;

  Future<void> updateClasses() async {
    // If updating is null, classes haven't been initialized yet so they're not
    // technically "updating"
    if (updating != null) {
      updating = true;
    }

    final ClassProvider classProvider =
        Provider.of<ClassProvider>(context, listen: false);
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    headers =
        (await classProvider.fetchClassHeaders(uid: authProvider.uid)).toSet();

    updating = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    updateClasses();
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return AppScaffold(
      title: Text(S.of(context).navigationClasses),
      // TODO(IoanaAlexandru): Simply show all classes if user is not authenticated
      needsToBeAuthenticated: true,
      actions: [
        AppScaffoldAction(
          icon: Icons.edit_outlined,
          tooltip: S.of(context).actionChooseClasses,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<ChangeNotifierProvider>(
              builder: (_) => ChangeNotifierProvider.value(
                  value: classProvider,
                  child: FutureBuilder(
                    future: classProvider.fetchUserClassIds(
                      uid: authProvider.uid,
                      context: context,
                    ),
                    builder: (context, snap) {
                      if (snap.hasData) {
                        return AddClassesPage(
                            initialClassIds: snap.data,
                            onSave: (classIds) async {
                              await classProvider.setUserClassIds(
                                  classIds: classIds, uid: authProvider.uid);
                              unawaited(updateClasses());
                              Navigator.pop(context);
                            });
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )),
            ),
          ),
        ),
      ],
      body: Stack(
        children: [
          if (updating != null)
            headers != null && headers.isNotEmpty
                ? ClassList(
                    classes: headers,
                    sectioned: false,
                    onTap: (classHeader) => Navigator.of(context)
                        .push(MaterialPageRoute<ChangeNotifierProvider>(
                      builder: (context) => ChangeNotifierProvider.value(
                        value: classProvider,
                        child: ClassView(classHeader: classHeader),
                      ),
                    )),
                  )
                : ErrorPage(
                    errorMessage: S.of(context).messageNoClassesYet,
                    imgPath: 'assets/illustrations/undraw_empty.png',
                    info: [
                        TextSpan(
                            text:
                                '${S.of(context).messageGetStartedByPressing} '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.edit_outlined,
                            size:
                                Theme.of(context).textTheme.subtitle1.fontSize +
                                    2,
                          ),
                        ),
                        TextSpan(text: ' ${S.of(context).messageButtonAbove}.'),
                      ]),
          if (updating == null)
            const Center(child: CircularProgressIndicator()),
          if (updating == true)
            Container(
                color: Theme.of(context).disabledColor,
                child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}

class AddClassesPage extends StatefulWidget {
  const AddClassesPage({Key key, this.initialClassIds, this.onSave})
      : super(key: key);

  final List<String> initialClassIds;
  final void Function(List<String>) onSave;

  @override
  _AddClassesPageState createState() =>
      _AddClassesPageState(classIds: initialClassIds.toSet());
}

class _AddClassesPageState extends State<AddClassesPage> {
  _AddClassesPageState({Set<String> classIds})
      : classIds = Set<String>.from(classIds) ?? {};

  Set<String> classIds;
  Set<ClassHeader> headers;

  Future<void> updateClasses() async {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    headers = (await classProvider.fetchClassHeaders()).toSet();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    updateClasses();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: Text(S.of(context).actionChooseClasses),
      actions: [
        AppScaffoldAction(
          text: S.of(context).buttonSave,
          onPressed: () => widget.onSave(classIds.toList()),
        )
      ],
      body: ClassList(
        classes: headers,
        initiallySelected: classIds,
        selectable: true,
        onSelected: (selected, classId) {
          if (selected) {
            classIds.add(classId);
          } else {
            classIds.remove(classId);
          }
        },
      ),
    );
  }
}

class ClassList extends StatefulWidget {
  ClassList(
      {this.classes,
      void Function(bool, String) onSelected,
      Set<String> initiallySelected,
      this.selectable = false,
      this.sectioned = true,
      void Function(ClassHeader) onTap})
      : onSelected = onSelected ?? ((selected, classId) {}),
        onTap = onTap ?? ((_) {}),
        initiallySelected = initiallySelected ?? {};

  final Set<ClassHeader> classes;
  final void Function(bool, String) onSelected;
  final Set<String> initiallySelected;
  final bool selectable;
  final void Function(ClassHeader) onTap;
  final bool sectioned;

  @override
  _ClassListState createState() => _ClassListState();
}

class _ClassListState extends State<ClassList> {
  Set<String> selectedClasses;

  @override
  void initState() {
    super.initState();
    selectedClasses = widget.initiallySelected;
  }

  String sectionName(BuildContext context, String year, String semester) =>
      '${S.of(context).labelYear} $year, ${S.of(context).labelSemester} $semester';

  Map<String, dynamic> classesBySection(
      Set<ClassHeader> classes, BuildContext context) {
    final map = <String, dynamic>{};

    for (final c in classes) {
      final List<String> category = c.category.split('/');
      var currentPath = map;
      for (int i = 0; i < category.length; i++) {
        final String section = category[i].trim();

        if (!currentPath.containsKey(section)) {
          currentPath[section] = <String, dynamic>{};
        }
        currentPath = currentPath[section];
      }

      if (!currentPath.containsKey('/')) {
        currentPath['/'] = <ClassHeader>{};
      }
      currentPath['/'].add(c);
    }

    return map;
  }

  _Section buildSections(BuildContext context, Map<String, dynamic> sections,
      {int level = 0}) {
    final List<Widget> children = [const SizedBox(height: 4)];
    bool expanded = false;

    sections.forEach((section, values) {
      if (section == '/') {
        children.addAll(values.map<Widget>(buildClassItem));
        expanded = values.fold(
            false,
            (dynamic selected, ClassHeader header) =>
                selected || widget.initiallySelected.contains(header.id));
      } else {
        final s = buildSections(context, sections[section], level: level + 1);
        expanded = expanded || s.containsSelected;

        children.add(AppSpoiler(
          title: section,
          level: level,
          initiallyExpanded: s.containsSelected,
          content: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: s.widgets,
            ),
          ),
        ));
      }
    });

    return _Section(widgets: children, containsSelected: expanded);
  }

  Widget buildClassItem(ClassHeader header) => Column(
        children: [
          ClassListItem(
            selectable: widget.selectable,
            initiallySelected: selectedClasses.contains(header.id),
            classHeader: header,
            onSelected: (selected) {
              if (selected) {
                selectedClasses.add(header.id);
              } else {
                selectedClasses.remove(header.id);
              }
              setState(() {});
              widget.onSelected(selected, header.id);
            },
            onTap: () => widget.onTap(header),
          ),
          const Divider(),
        ],
      );

  @override
  Widget build(BuildContext context) {
    if (widget.classes != null) {
      return ListView(
        children: [
          if (widget.sectioned)
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: IconText(
                icon: Icons.info_outlined,
                text:
                    '${S.of(context).infoSelect} ${S.of(context).infoClasses}.',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
                children: widget.sectioned
                    ? (buildSections(
                            context, classesBySection(widget.classes, context)))
                        .widgets
                    : widget.classes.map(buildClassItem).toList()),
          ),
        ],
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}

// Utility class to allow `buildSections` to return two values
class _Section {
  _Section({this.widgets, this.containsSelected});

  List<Widget> widgets;
  bool containsSelected;
}

class ClassListItem extends StatefulWidget {
  ClassListItem(
      {Key key,
      this.classHeader,
      this.initiallySelected = false,
      void Function(bool) onSelected,
      this.selectable = false,
      void Function() onTap,
      this.hint})
      : onSelected = onSelected ?? ((_) {}),
        onTap = onTap ?? (() {}),
        super(key: key);

  final ClassHeader classHeader;
  final bool initiallySelected;
  final void Function(bool) onSelected;
  final bool selectable;
  final void Function() onTap;
  final String hint;

  @override
  _ClassListItemState createState() =>
      _ClassListItemState(selected: initiallySelected);
}

class _ClassListItemState extends State<ClassListItem> {
  _ClassListItemState({this.selected});

  bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClassIcon(
        classHeader: widget.classHeader,
        selected: widget.selectable && selected,
      ),
      title: Text(
        widget.classHeader.name,
        style: widget.selectable
            ? (selected
                ? Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontWeight: FontWeight.bold)
                : Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: Theme.of(context).disabledColor))
            : Theme.of(context).textTheme.subtitle1,
      ),
      subtitle: widget.hint != null ? Text(widget.hint) : null,
      onTap: () => setState(() {
        if (widget.selectable) {
          selected = !selected;
          widget.onSelected(selected);
        }
        widget.onTap();
      }),
    );
  }
}
