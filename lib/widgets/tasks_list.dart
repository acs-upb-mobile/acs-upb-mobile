import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:acs_upb_mobile/widgets/event_instance_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TasksList extends StatefulWidget {
  const TasksList({
    @required this.events,
    this.title,
    this.isExpanded,
  });
  final List<UniEventInstance> events;
  final String title;
  final bool isExpanded;

  @override
  _TasksListState createState() => _TasksListState();
}

class _TasksListState extends State<TasksList>
    with SingleTickerProviderStateMixin {
  bool isExpanded;
  AnimationController expandController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded ?? false;
    prepareAnimations();
    _runExpandCheck();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.fastOutSlowIn,
    );
  }

  void _runExpandCheck() {
    if (isExpanded == true) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(TasksList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.events.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              key: ValueKey(widget.title),
              contentPadding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
              onTap: () => {
                setState(() {
                  isExpanded = !isExpanded;
                }),
                _runExpandCheck(),
              },
              trailing: widget.events.isEmpty
                  ? const Icon(Icons.remove_outlined)
                  : isExpanded
                      ? const Icon(Icons.arrow_drop_up_outlined)
                      : const Icon(
                          Icons.arrow_drop_down_outlined,
                        ),
              title: Text(
                widget.title,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          );
        } else {
          return Visibility(
            visible: isExpanded,
            child: SizeTransition(
              axisAlignment: 1,
              sizeFactor: animation,
              child: EventInstanceListTile(
                  eventInstance: widget.events[index - 1]),
            ),
          );
        }
      },
    );
  }
}
